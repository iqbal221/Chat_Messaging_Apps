import 'package:flutter/material.dart';

class MessageOptionsBottomSheet extends StatelessWidget {
  final bool isMe;
  final VoidCallback onDeleteForMe;
  final VoidCallback onDeleteForEveryone;

  const MessageOptionsBottomSheet({
    super.key,
    required this.isMe,
    required this.onDeleteForMe,
    required this.onDeleteForEveryone,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text("Delete for me"),
            onTap: () {
              Navigator.pop(context);
              onDeleteForMe();
            },
          ),

          if (isMe)
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Delete for everyone"),
              onTap: () {
                Navigator.pop(context);
                onDeleteForEveryone.call();
              },
            ),
        ],
      ),
    );
  }
}
