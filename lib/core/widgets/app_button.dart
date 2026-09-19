import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

enum AppButtonType { primary, secondary, outlined, ghost }

enum AppButtonSize { small, medium, large }

/// Ilovaning asosiy tugmasi
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool enabled = !isLoading && !isDisabled && onPressed != null;

    final EdgeInsets padding = switch (size) {
      AppButtonSize.small =>
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      AppButtonSize.medium =>
        const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      AppButtonSize.large =>
        const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    };

    final TextStyle textStyle = switch (size) {
      AppButtonSize.small => AppTextStyles.labelMedium,
      AppButtonSize.medium => AppTextStyles.labelLarge,
      AppButtonSize.large => AppTextStyles.labelLarge.copyWith(fontSize: 16),
    };

    final double iconSize = switch (size) {
      AppButtonSize.small => 16,
      AppButtonSize.medium => 18,
      AppButtonSize.large => 20,
    };

    Widget buildContent(Color textColor) {
      if (isLoading) {
        return SizedBox(
          height: iconSize,
          width: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefixIcon != null) ...[
            IconTheme(
              data: IconThemeData(color: textColor, size: iconSize),
              child: prefixIcon!,
            ),
            const SizedBox(width: 8),
          ],
          Text(label, style: textStyle.copyWith(color: textColor)),
          if (suffixIcon != null) ...[
            const SizedBox(width: 8),
            IconTheme(
              data: IconThemeData(color: textColor, size: iconSize),
              child: suffixIcon!,
            ),
          ],
        ],
      );
    }

    Widget button;

    switch (type) {
      case AppButtonType.primary:
        final bgColor = enabled
            ? colorScheme.primary
            : colorScheme.primary.withValues(alpha: 0.4);
        button = ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: buildContent(Colors.white),
        );
        break;

      case AppButtonType.secondary:
        button = ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.primary,
            elevation: 0,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: buildContent(colorScheme.primary),
        );
        break;

      case AppButtonType.outlined:
        button = OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary,
            side: BorderSide(
              color: enabled
                  ? colorScheme.primary
                  : colorScheme.outline,
            ),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: buildContent(
            enabled ? colorScheme.primary : colorScheme.outline,
          ),
        );
        break;

      case AppButtonType.ghost:
        button = TextButton(
          onPressed: enabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: buildContent(
            enabled ? colorScheme.primary : AppColors.textHintLight,
          ),
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
