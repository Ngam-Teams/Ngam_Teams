import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../core/theme/app_colors.dart';

/// Frosted-glass statistic card with hover micro-interactions.
/// Mirrors Ngam Business's StatCard exactly (compact horizontal glass card).
class StatCard extends StatefulWidget {
  final String label;
  final String value;
  final String? subtitle;
  final dynamic icon;
  final Color accentColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    required this.icon,
    this.accentColor = AppColors.primary,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: GlassContainer(
          useOwnLayer: true,
          quality: GlassQuality.standard,
          shape: const LiquidRoundedSuperellipse(borderRadius: 24.0),
          settings: LiquidGlassSettings(
            thickness: 0.1,
            blur: 15.0,
            refractiveIndex: 1.0,
            glassColor: Colors.transparent,
            lightAngle: 45.0,
            lightIntensity: isDark ? 0.1 : 0.2,
            ambientStrength: 1.0,
            saturation: 1.0,
            chromaticAberration: 0.0,
          ),
          child: AnimatedContainer(
            width: double.infinity,
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(
                      alpha: _isHovered ? 0.08 : 0.05,
                    )
                  : Colors.white.withValues(
                      alpha: _isHovered ? 0.6 : 0.45,
                    ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _isHovered
                    ? widget.accentColor.withValues(alpha: 0.4)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.65)),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withValues(
                    alpha: _isHovered ? 0.15 : 0.0,
                  ),
                  blurRadius: _isHovered ? 24 : 16,
                  offset: Offset(0, _isHovered ? 12 : 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Icon (Left) + Subtitle Pill (Right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: widget.accentColor
                            .withValues(alpha: isDark ? 0.18 : 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.accentColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: HugeIcon(
                        icon: widget.icon,
                        color: widget.accentColor,
                        size: 20,
                        strokeWidth: 2.1,
                      ),
                    ),
                    if (widget.subtitle != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent
                              .withValues(alpha: isDark ? 0.12 : 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.greenAccent
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.greenAccent,
                              size: 10,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? Colors.greenAccent
                                        .withValues(alpha: 0.9)
                                    : Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Value (Placed under icon, prominent & full width)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color:
                          isDark ? Colors.white : const Color(0xFF1E293B),
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 3),

                // Label (Full width, no more truncation)
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.65)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
