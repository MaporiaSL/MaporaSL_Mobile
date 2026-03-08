import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: IconButton(
        icon: icon,
        onPressed: onPressed ?? () {},
      ),
    );
  }
}
