import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 18)),
            ],
          ),
          Row(
            children: [
              _circleButton(Icons.remove, onMinus),
              const SizedBox(width: 16),
              _circleButton(Icons.add, onPlus),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: const Color(0xFFF1F1F1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 60,
          height: 60,
          child: Icon(icon, size: 36),
        ),
      ),
    );
  }
}
