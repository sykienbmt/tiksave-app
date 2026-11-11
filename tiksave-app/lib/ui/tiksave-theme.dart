import 'package:flutter/material.dart';

class TikSaveTheme {
  static const Color bgObsidian = Color(0xFF07080D);
  static const Color cardTop = Color(0xFF151929);
  static const Color cardBottom = Color(0xFF0D101B);
  static const Color surfaceRecessed = Color(0xFF090B13);
  static const Color borderGlass = Color(0xFF252B42);

  static const Color neonCyan = Color(0xFF00F2FE);
  static const Color neonRose = Color(0xFFFF0050);
  static const Color neonCoral = Color(0xFFFF3366);
  static const Color neonEmerald = Color(0xFF00E676);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const LinearGradient primaryCtaGradient = LinearGradient(
    colors: [neonRose, neonCoral],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandDualGradient = LinearGradient(
    colors: [neonCyan, neonRose],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration bentoCardDecoration({
    Color? borderColor,
    double radius = 22,
    Color? glowColor,
  }) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [cardTop, cardBottom],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? borderGlass, width: 1.1),
      boxShadow: [
        BoxShadow(
          color: (glowColor ?? Colors.black).withValues(
            alpha: glowColor != null ? 0.16 : 0.45,
          ),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static Widget pillBadge(String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.42)),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          color: accent,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgObsidian,
        colorScheme: const ColorScheme.dark(
          primary: neonCyan,
          secondary: neonRose,
          surface: cardTop,
        ),
        splashFactory: InkSparkle.splashFactory,
      );
}

class TikSaveLogoMark extends StatelessWidget {
  final double size;
  const TikSaveLogoMark({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: TikSaveTheme.brandDualGradient,
        borderRadius: BorderRadius.circular(size * 0.30),
        boxShadow: [
          BoxShadow(
            color: TikSaveTheme.neonCyan.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(-3, -2),
          ),
          BoxShadow(
            color: TikSaveTheme.neonRose.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.26),
        child: Image.asset(
          'assets/icon/app-icon.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: TikSaveTheme.bgObsidian,
            alignment: Alignment.center,
            child: Icon(
              Icons.play_for_work_rounded,
              color: TikSaveTheme.neonCyan,
              size: size * 0.58,
            ),
          ),
        ),
      ),
    );
  }
}

class TikSaveGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final double verticalPadding;

  const TikSaveGradientButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.verticalPadding = 14,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1.0 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: TikSaveTheme.primaryCtaGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: TikSaveTheme.neonRose.withValues(alpha: 0.38),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
