import 'package:flutter/material.dart';

class ContactGroup extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const ContactGroup({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),

      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

      onTap: onTap,
    );
  }
}
