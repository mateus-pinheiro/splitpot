import 'package:flutter/material.dart';

import '../tokens.dart';

/// Tipo do toast — define o par de cores fundo/texto.
enum SpToastType { info, error, success }

/// Toast ancorado no TOPO da tela, via [Overlay]. Diferente do `SnackBar`
/// (sempre no rodapé e com fundo que se mistura ao felt), aqui usamos um fundo
/// sólido e cor de texto de alto contraste para o aviso não ficar apagado.
///
/// Use para validações rápidas (email/senha) e erros de login.
void showSpToast(
  BuildContext context,
  String message, {
  SpToastType type = SpToastType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  final (bg, fg) = switch (type) {
    SpToastType.info => (SpColors.gold, SpColors.ink),
    SpToastType.error => (SpColors.danger, SpColors.ivory),
    SpToastType.success => (SpColors.success, SpColors.ivory),
  };

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _SpToastWidget(
      message: message,
      background: bg,
      foreground: fg,
      duration: duration,
      onDismissed: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _SpToastWidget extends StatefulWidget {
  const _SpToastWidget({
    required this.message,
    required this.background,
    required this.foreground,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final Color background;
  final Color foreground;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_SpToastWidget> createState() => _SpToastWidgetState();
}

class _SpToastWidgetState extends State<_SpToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _controller,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: widget.background,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55000000),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: SpTypography.uiFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.foreground,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
