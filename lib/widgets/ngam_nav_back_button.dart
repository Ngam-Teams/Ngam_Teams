import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Ngam-style circular liquid glass back button with springy tap feedback.
/// Replicates the exact frosted glass aesthetics from the Ngam App.
class NgamNavBackButton extends StatefulWidget {
  final VoidCallback? onTap;
  final dynamic icon;
  final double size;

  const NgamNavBackButton({
    super.key,
    this.onTap,
    this.icon = HugeIcons.strokeRoundedArrowLeft01,
    this.size = 44.0,
  });

  @override
  State<NgamNavBackButton> createState() => _NgamNavBackButtonState();
}

class _NgamNavBackButtonState extends State<NgamNavBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        _handleTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.size / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.55),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.65),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: widget.icon is IconData
                    ? Icon(
                        widget.icon as IconData,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        size: 20,
                      )
                    : HugeIcon(
                        icon: widget.icon,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        size: 20,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
