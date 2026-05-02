import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design/design_system.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/google_sign_in_web_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: BlocListener<AuthCubit, AuthState>(
            listener: _handleErrorSnackBar,
            listenWhen: (p, c) => c is AuthError,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Expanded(child: _LoginHero()),
                  _LoginFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleErrorSnackBar(BuildContext context, AuthState state) {
    if (state is! AuthError) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: SpColors.danger,
        content: Text('Não foi possível entrar. Tente novamente.'),
      ),
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

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          if (kIsWeb)
            const _LoginWebGoogle()
          else
            const _LoginMobileButtons(),
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
                TextSpan(text: 'Termos', style: TextStyle(color: SpColors.gold)),
                TextSpan(text: ' e '),
                TextSpan(
                  text: 'Política de Privacidade',
                  style: TextStyle(color: SpColors.gold),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoginMobileButtons extends StatelessWidget {
  const _LoginMobileButtons();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final loading = state is AuthAuthenticating;
        return Column(
          children: [
            // _AuthButton(
            //   onPressed: loading ? null : () {}, // Apple a definir
            //   bg: Colors.black,
            //   fg: Colors.white,
            //   borderColor: Colors.white.withValues(alpha: 0.15),
            //   icon: const Icon(Icons.apple, color: Colors.white, size: 20),
            //   label: 'Continue with Apple',
            // ),
            const SizedBox(height: 12),
            _AuthButton(
              onPressed: loading
                  ? null
                  : () => context.read<AuthCubit>().signInWithGoogle(),
              bg: SpColors.cream,
              fg: const Color(0xFF222222),
              borderColor: Colors.white.withValues(alpha: 0.3),
              icon: const _GoogleGlyph(),
              label: loading ? 'Entrando...' : 'Continue with Google',
            ),
          ],
        );
      },
    );
  }
}

class _LoginWebGoogle extends StatelessWidget {
  const _LoginWebGoogle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // _AuthButton(
        //   onPressed: () {},
        //   bg: Colors.black,
        //   fg: Colors.white,
        //   borderColor: Colors.white.withValues(alpha: 0.15),
        //   icon: const Icon(Icons.apple, color: Colors.white, size: 20),
        //   label: 'Continue with Apple',
        // ),
        // const SizedBox(height: 12),
        Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: SpColors.cream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: buildGoogleSignInWebButton(),
        ),
        const SizedBox(height: 8),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticating) {
              return const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: SpColors.goldBright,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
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
    // Círculo com "G" colorido (simplificado — o SVG oficial não cabe aqui).
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
