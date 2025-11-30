// Custom image widget placeholder
import 'package:flutter/material.dart';

class CustomImageWidget extends StatelessWidget {
  final String src;
  final BoxFit fit;

  const CustomImageWidget({
    Key? key,
    required this.src,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(src, fit: fit);
  }
}
