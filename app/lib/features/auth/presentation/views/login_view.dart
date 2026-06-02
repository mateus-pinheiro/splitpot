import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/usecases.dart';
import '../cubit/cubit.dart';
import '../widgets/google_sign_in_web_button.dart';

/// Mostra Apple Sign-In apenas em iOS native (web/Android escondem).
bool get _showAppleButton {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.iOS;
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Sinaliza a fase de verificação do email (lookup no backend) para o loader
  // de tela cheia. Vive aqui — acima do `SpLoadingScreen` — porque o flag é
  // setado lá dentro, em `_LoginBody`. Depois do lookup, o estado
  // `AuthAuthenticating` do cubit assume e mantém o loader até o redirect.
  final _busy = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _busy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _busy,
      builder: (context, busy, _) {
        return BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (p, c) =>
              (p is AuthAuthenticating) != (c is AuthAuthenticating),
          builder: (context, state) {
            return SpLoadingScreen(
              loading: busy || state is AuthAuthenticating,
              child: Scaffold(
                // Controlamos o espaço do teclado manualmente em `_LoginBody`
                // (reservando padding e rolando), em vez de deixar o Scaffold
                // encolher o body — o FeltBackground/Stack não propagava bem o resize.
                resizeToAvoidBottomInset: false,
                body: FeltBackground(
                  child: SafeArea(
                    child: BlocListener<AuthCubit, AuthState>(
                      listener: _handleErrorToast,
                      listenWhen: (p, c) => c is AuthError,
                      child: _LoginBody(busy: _busy),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleErrorToast(BuildContext context, AuthState state) {
    if (state is! AuthError) return;
    final message = switch (state.failure) {
      UnauthorizedFailure(:final message) =>
        message ?? 'Não foi possível entrar.',
      ValidationFailure(:final message) => message,
      NetworkFailure() => 'Sem conexão com o servidor.',
      SignInCancelledFailure() => 'Login cancelado.',
      _ => 'Não foi possível entrar. Tente novamente.',
    };
    showSpToast(context, message, type: SpToastType.error);
  }
}

/// Corpo do login. Tudo (hero + social + divider + campos + botão + termos) mora
/// num único scroll. Quando o teclado abre, a tela inteira sobe acima dele:
/// reservamos um padding inferior do tamanho do teclado e rolamos até o fim
/// (em `didChangeMetrics`), deixando o rodapé colado acima do teclado, sem nada
/// escondido. Fazemos isso manualmente (resizeToAvoidBottomInset: false) porque
/// o Stack do FeltBackground não propagava bem o resize automático do Scaffold.
///
/// O botão "Entrar" faz lookup do email via `accounts:createAuthUri` e despacha
/// pro fluxo certo:
/// - email já existe com Google/Apple → auto-trigger daquele provider
/// - email já existe com password → tenta sign-in com a senha digitada
/// - email não existe → vai pra CompleteProfile (modo signup) com email
///   e senha carregados em `AuthNeedsProfile.draftEmail/draftPassword`
class _LoginBody extends StatefulWidget {
  const _LoginBody({required this.busy});

  /// Compartilhado com `_LoginViewState` para acionar o loader de tela cheia
  /// durante a verificação do email.
  final ValueNotifier<bool> busy;

  @override
  State<_LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<_LoginBody> with WidgetsBindingObserver {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scrollController = ScrollController();
  bool _submitting = false;
  bool _obscure = true;
  // Realça o botão "Continue with Google" por alguns segundos quando o email
  // digitado pertence a uma conta Google e estamos na web (onde não dá pra
  // abrir o Google programaticamente — só pelo botão renderizado pela GIS).
  bool _highlightGoogle = false;

  // Regex prática (não exaustiva) — Firebase faz a validação final.
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Chamado em cada passo da animação do teclado (e no frame final). Mantém o
  // fim da tela (senha + botão + termos) colado acima do teclado, rolando o
  // conteúdo pra cima conforme o teclado sobe.
  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (MediaQuery.of(context).viewInsets.bottom <= 0) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_emailRegex.hasMatch(email)) {
      _toast('Digite um email válido.');
      return;
    }
    if (password.length < 6) {
      _toast('A senha precisa ter pelo menos 6 caracteres.');
      return;
    }

    final cubit = context.read<AuthCubit>();
    final lookupUsecase = appDI.get<LookupEmailProviders>();

    _setBusy(true);
    try {
      final lookup = await lookupUsecase(email);

      if (lookup.registered) {
        // Auto-trigger do provider quando o email já está em Google/Apple.
        // Senha digitada é ignorada nesses casos — o OAuth do provider
        // assume o lugar dela.
        if (lookup.hasGoogle) {
          // Na web não dá pra abrir o popup do Google programaticamente — ele
          // só dispara no clique do botão renderizado pela GIS. Em vez de
          // travar num loader, guiamos o usuário até o botão (com destaque).
          if (kIsWeb) {
            _toast('Essa conta usa Google. Toque em "Continue with Google".');
            _flashGoogleHighlight();
            return;
          }
          _toast('Detectamos conta Google — abrindo login...');
          await cubit.signInWithGoogle();
          return;
        }
        if (lookup.hasApple && _showAppleButton) {
          _toast('Detectamos conta Apple — abrindo login...');
          await cubit.signInWithApple();
          return;
        }
        if (lookup.hasPassword) {
          await cubit.signInWithPassword(email: email, password: password);
          return;
        }
        // Email registrado mas em provider que não suportamos (raro).
        _toast('Esse email usa um provedor não suportado.');
        return;
      }

      // Email novo → fluxo de cadastro password. Carrega draft no state e
      // o router leva pra /complete-profile.
      cubit.beginPasswordSignup(
        email: email,
        password: password,
        suggestedName: _deriveNameFromEmail(email),
      );
    } on Object catch (e) {
      _toast(_messageFor(e));
    } finally {
      _setBusy(false);
    }
  }

  // Liga/desliga o loader de tela cheia (via `widget.busy`) e o estado de
  // desabilitar campos/botão (via `_submitting`) num só ponto.
  void _setBusy(bool value) {
    if (!mounted) return;
    widget.busy.value = value;
    setState(() => _submitting = value);
  }

  // Rola até o topo e acende o destaque do botão Google por alguns segundos.
  void _flashGoogleHighlight() {
    if (!mounted) return;
    // Fecha o teclado pra revelar o botão Google (fica no topo da tela).
    FocusManager.instance.primaryFocus?.unfocus();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    setState(() => _highlightGoogle = true);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _highlightGoogle = false);
    });
  }

  void _toast(String message) {
    if (!mounted) return;
    showSpToast(context, message, duration: const Duration(seconds: 2));
  }

  String _messageFor(Object error) {
    if (error is ApiException) {
      return switch (error.failure) {
        UnauthorizedFailure(:final message) =>
          message ?? 'Não foi possível verificar o email.',
        NetworkFailure() => 'Sem conexão com o servidor.',
        _ => 'Não foi possível verificar o email.',
      };
    }
    return 'Erro inesperado. Tente novamente.';
  }

  String _deriveNameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return '';
    return local[0].toUpperCase() + local.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Reservamos `keyboard` no fim do scroll (espaço atrás do teclado) e
        // damos ao conteúdo no mínimo a altura visível acima dele. Ao rolar até
        // o fim, o rodapé (botão + termos) para exatamente acima do teclado.
        final available = (constraints.maxHeight - keyboard).clamp(0.0, double.infinity);
        return SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(left: 32, right: 32, bottom: keyboard),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: available),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Expanded(child: _LoginHero()),
                  const SizedBox(height: 24),
                  _SocialButtons(highlightGoogle: _highlightGoogle),
                  const SizedBox(height: 20),
                  const _OrDivider(),
                  const SizedBox(height: 20),
                  SpInput(
                    controller: _emailController,
                    hintText: 'seu@email.com',
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    enabled: !_submitting,
                  ),
                  const SizedBox(height: 10),
                  SpInput(
                    controller: _passwordController,
                    hintText: 'senha (mínimo 6 caracteres)',
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.password],
                    enabled: !_submitting,
                    onSubmitted: (_) => _submit(),
                    suffix: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: SpColors.muted,
                        size: 20,
                      ),
                      splashRadius: 18,
                      tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                    ),
                  ),
                  const SizedBox(height: 14),
                  SpGoldButton(
                    label: 'Entrar com email',
                    loading: _submitting,
                    onPressed: _submitting ? null : _submit,
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      text: 'Ao continuar, você concorda com os\n',
                      style: const TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 11,
                        color: SpColors.muted,
                        height: 1.5,
                      ),
                      children: const [
                        TextSpan(
                            text: 'Termos',
                            style: TextStyle(color: SpColors.gold)),
                        TextSpan(text: ' e '),
                        TextSpan(
                          text: 'Política de Privacidade',
                          style: TextStyle(color: SpColors.gold),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ChipTower(),
          const SizedBox(height: 28),
          GoldFoilText(
            'SplitPot',
            style: const TextStyle(
              fontFamily: SpTypography.displayFamily,
              fontSize: 52,
              fontWeight: FontWeight.w800,
              height: 1.0,
              letterSpacing: -1.04,
            ),
          ),
          const SizedBox(height: 10),
          Opacity(
            opacity: 0.75,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SuitGlyph(suit: Suit.spade, size: 14),
                SizedBox(width: 10),
                SuitGlyph(suit: Suit.heart, size: 14),
                SizedBox(width: 10),
                SuitGlyph(suit: Suit.diamond, size: 14),
                SizedBox(width: 10),
                SuitGlyph(suit: Suit.club, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Opacity(
            opacity: 0.8,
            child: Text(
              'Caixa transparente\npara seu home game',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: 15,
                height: 1.5,
                color: SpColors.cream.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipTower extends StatelessWidget {
  const _ChipTower();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        children: const [
          Positioned(
            left: 0,
            top: 35,
            child: PokerChipStack(
              size: 72,
              color: SpColors.danger,
              count: 4,
            ),
          ),
          Positioned(
            right: 0,
            top: 20,
            child: PokerChipStack(
              size: 72,
              color: Color(0xFF1F3F6B),
              count: 5,
            ),
          ),
          Positioned(
            left: 30,
            top: 0,
            child: PokerChipStack(
              size: 72,
              color: Color(0xFF2A2A2A),
              count: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons({this.highlightGoogle = false});

  /// Acende um contorno dourado no botão Google (web) quando o login detecta
  /// que o email digitado pertence a uma conta Google.
  final bool highlightGoogle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showAppleButton) ...[
          _AuthButton(
            onPressed: () => context.read<AuthCubit>().signInWithApple(),
            bg: Colors.black,
            fg: Colors.white,
            borderColor: Colors.white.withValues(alpha: 0.15),
            icon: const Icon(Icons.apple, color: Colors.white, size: 22),
            label: 'Continue with Apple',
          ),
          const SizedBox(height: 12),
        ],
        if (kIsWeb)
          _LoginWebGoogle(highlight: highlightGoogle)
        else
          _AuthButton(
            onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
            bg: SpColors.cream,
            fg: const Color(0xFF222222),
            borderColor: Colors.white.withValues(alpha: 0.3),
            icon: const _GoogleGlyph(),
            label: 'Continue with Google',
          ),
      ],
    );
  }
}

class _LoginWebGoogle extends StatelessWidget {
  const _LoginWebGoogle({this.highlight = false});

  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: SpColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? SpColors.gold : Colors.white.withValues(alpha: 0.3),
          width: highlight ? 2 : 1,
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: SpColors.gold.withValues(alpha: 0.45),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: buildGoogleSignInWebButton(),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(
        height: 1,
        color: SpColors.cream.withValues(alpha: 0.15),
      ),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou',
            style: TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 11,
              color: SpColors.muted,
              letterSpacing: 1.0,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.onPressed,
    required this.bg,
    required this.fg,
    required this.borderColor,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onPressed;
  final Color bg;
  final Color fg;
  final Color borderColor;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: onPressed == null ? 0.6 : 1.0,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: SpTypography.uiFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontFamily: SpTypography.displayFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4285F4),
      ),
    );
  }
}
