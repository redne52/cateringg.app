// Custom icon widget placeholder
import 'package:flutter/material.dart';

class CustomIconWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const CustomIconWidget({
    Key? key,
    required this.icon,
    this.color = Colors.black,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color, size: size);
  }
}
