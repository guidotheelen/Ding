import 'package:flutter/material.dart';
import 'app_theme.dart';

class SettingRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const SettingRow({
    super.key,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.cardElevation,
      color: AppTheme.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Padding(
        padding: AppTheme.cardPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppTheme.settingValueFontSize,
                    fontWeight: AppTheme.bold,
                    color: AppTheme.settingValue,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTheme.settingLabelFontSize,
                    color: AppTheme.settingLabel,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _circleButton(Icons.remove, onMinus),
                const SizedBox(width: 12),
                _circleButton(Icons.add, onPlus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: AppTheme.circleButtonBg,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Icon(
            icon,
            size: 28,
            color: AppTheme.circleButtonIcon,
          ),
        ),
      ),
    );
  }
}
