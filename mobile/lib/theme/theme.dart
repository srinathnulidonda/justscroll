// lib/theme/theme.dart
import 'package:flutter/material.dart';
import 'package:justscroll/theme/colors.dart';

class AppTheme {
  static ThemeData light() {
    return _build(
      brightness: Brightness.light,
      background: AppColors.lightBackground,
      foreground: AppColors.lightForeground,
      card: AppColors.lightCard,
      cardForeground: AppColors.lightCardForeground,
      primary: AppColors.lightPrimary,
      primaryForeground: AppColors.lightPrimaryForeground,
      secondary: AppColors.lightSecondary,
      secondaryForeground: AppColors.lightSecondaryForeground,
      muted: AppColors.lightMuted,
      mutedForeground: AppColors.lightMutedForeground,
      accent: AppColors.lightAccent,
      accentForeground: AppColors.lightAccentForeground,
      border: AppColors.lightBorder,
      destructive: AppColors.lightDestructive,
      ring: AppColors.lightRing,
    );
  }

  static ThemeData dark() {
    return _build(
      brightness: Brightness.dark,
      background: AppColors.darkBackground,
      foreground: AppColors.darkForeground,
      card: AppColors.darkCard,
      cardForeground: AppColors.darkCardForeground,
      primary: AppColors.darkPrimary,
      primaryForeground: AppColors.darkPrimaryForeground,
      secondary: AppColors.darkSecondary,
      secondaryForeground: AppColors.darkSecondaryForeground,
      muted: AppColors.darkMuted,
      mutedForeground: AppColors.darkMutedForeground,
      accent: AppColors.darkAccent,
      accentForeground: AppColors.darkAccentForeground,
      border: AppColors.darkBorder,
      destructive: AppColors.darkDestructive,
      ring: AppColors.darkRing,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color foreground,
    required Color card,
    required Color cardForeground,
    required Color primary,
    required Color primaryForeground,
    required Color secondary,
    required Color secondaryForeground,
    required Color muted,
    required Color mutedForeground,
    required Color accent,
    required Color accentForeground,
    required Color border,
    required Color destructive,
    required Color ring,
  }) {
    const fontFamily = 'Inter';

    final baseTextTheme = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    final textTheme = baseTextTheme.apply(fontFamily: fontFamily);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: primaryForeground,
        secondary: secondary,
        onSecondary: secondaryForeground,
        error: destructive,
        onError: primaryForeground,
        surface: card,
        onSurface: foreground,
        outline: border,
        surfaceContainerHighest: muted,
      ),
      textTheme: textTheme.apply(
        bodyColor: foreground,
        displayColor: foreground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background.withOpacity(0.9),
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: foreground,
          fontFamily: fontFamily,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border.withOpacity(0.5)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border.withOpacity(0.5),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: muted.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: destructive),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: mutedForeground.withOpacity(0.5),
          fontFamily: fontFamily,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryForeground,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: mutedForeground,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: muted,
        labelStyle: textTheme.bodySmall?.copyWith(
          color: foreground,
          fontFamily: fontFamily,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: border.withOpacity(0.3)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: foreground,
        unselectedLabelColor: mutedForeground,
        indicatorColor: primary,
        dividerColor: Colors.transparent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      extensions: [
        AppColorsExtension(
          mutedForeground: mutedForeground,
          muted: muted,
          border: border,
          card: card,
          cardForeground: cardForeground,
          ring: ring,
          accent: accent,
          accentForeground: accentForeground,
        ),
      ],
    );
  }
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color mutedForeground;
  final Color muted;
  final Color border;
  final Color card;
  final Color cardForeground;
  final Color ring;
  final Color accent;
  final Color accentForeground;

  const AppColorsExtension({
    required this.mutedForeground,
    required this.muted,
    required this.border,
    required this.card,
    required this.cardForeground,
    required this.ring,
    required this.accent,
    required this.accentForeground,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? mutedForeground, Color? muted, Color? border,
    Color? card, Color? cardForeground, Color? ring,
    Color? accent, Color? accentForeground,
  }) {
    return AppColorsExtension(
      mutedForeground: mutedForeground ?? this.mutedForeground,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      ring: ring ?? this.ring,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other, double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardForeground: Color.lerp(cardForeground, other.cardForeground, t)!,
      ring: Color.lerp(ring, other.ring, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentForeground: Color.lerp(accentForeground, other.accentForeground, t)!,
    );
  }
}

extension ThemeDataX on ThemeData {
  AppColorsExtension get appColors => extension<AppColorsExtension>()!;
}