import 'package:chat_messaging/core/constants/app_text_styles.dart';
import 'package:chat_messaging/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_messaging/core/screens/chat_screen.dart';

class RecentChatScreen extends StatelessWidget {
  const RecentChatScreen({super.key});

  static const String name = "/recent_chats";

  String get myId => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: myId)
        .orderBy('updatedAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        title: const Text("Recent Contact", style: AppTextStyles.appBarTitle),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No recent chats"));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final data = chats[index].data() as Map<String, dynamic>;

              final participants = List<String>.from(data['participants']);
              final lastMessage = data['lastMessage'] ?? "";

              /// find receiver id
              final receiverId = participants.firstWhere((id) => id != myId);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(receiverId)
                    .get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  final user = userSnap.data!.data() as Map<String, dynamic>;

                  final name =
                      "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}"
                          .trim();

                  final image = user['image'] ?? "";

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: image.isNotEmpty
                          ? NetworkImage(image)
                          : null,
                      child: image.isEmpty ? const Icon(Icons.person) : null,
                    ),

                    title: Text(name),
                    subtitle: Text(lastMessage),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            receiverId: receiverId,
                            receiverName: name,
                            receiverImage: image,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
