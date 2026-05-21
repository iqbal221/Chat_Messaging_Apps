// import 'package:flutter/material.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   static const String name = '/chat_screen';

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController messageController = TextEditingController();

//   final List<Map<String, dynamic>> messages = [
//     {"message": "Hello!", "isMe": false},
//     {"message": "Hi! How are you?", "isMe": true},
//     {"message": "I'm good. You?", "isMe": false},
//   ];

//   void sendMessage() {
//     if (messageController.text.trim().isEmpty) return;

//     setState(() {
//       messages.add({"message": messageController.text.trim(), "isMe": true});
//     });

//     messageController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F8FA),

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         title: const Row(
//           children: [
//             CircleAvatar(
//               radius: 25,
//               backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=5"),
//             ),
//             SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "John Doe",
//                   style: TextStyle(color: Colors.black, fontSize: 16),
//                 ),
//                 Text(
//                   "online",
//                   style: TextStyle(color: Colors.green, fontSize: 12),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),

//       body: Column(
//         children: [
//           // CHAT LIST
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final msg = messages[index];
//                 final isMe = msg["isMe"];

//                 return Align(
//                   alignment: isMe
//                       ? Alignment.centerRight
//                       : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 10,
//                     ),
//                     constraints: const BoxConstraints(maxWidth: 250),
//                     decoration: BoxDecoration(
//                       color: isMe ? Colors.blue : Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 4,
//                         ),
//                       ],
//                     ),
//                     child: Text(
//                       msg["message"],
//                       style: TextStyle(
//                         color: isMe ? Colors.white : Colors.black,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // INPUT BOX
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: messageController,
//                     decoration: InputDecoration(
//                       hintText: "Type a message...",
//                       filled: true,
//                       fillColor: const Color(0xFFF2F4F7),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 10,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(width: 8),

//                 GestureDetector(
//                   onTap: sendMessage,
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: const BoxDecoration(
//                       color: Colors.blue,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.send,
//                       color: Colors.white,
//                       size: 18,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:chat_messaging/core/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecentChatScreen extends StatelessWidget {
  const RecentChatScreen({
    super.key,
    required String receiverId,
    required String receiverName,
    required String receiverImage,
  });

  static const String name = '/recent_chat';

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: const Text(
          "Chats",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),

          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUser.uid)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No chats yet", style: TextStyle(fontSize: 16)),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,

            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;

              final participants = List<String>.from(chat['participants']);

              /// REMOVE CURRENT USER
              participants.remove(currentUser.uid);

              final receiverId = participants.first;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(receiverId)
                    .get(),

                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox();
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  final firstName = userData['firstName'] ?? '';

                  final lastName = userData['lastName'] ?? '';

                  final image = userData['profileImage'] ?? '';

                  final fullName = "$firstName $lastName";

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),

                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade300,

                      backgroundImage: image.isNotEmpty
                          ? NetworkImage(image)
                          : null,

                      child: image.isEmpty ? const Icon(Icons.person) : null,
                    ),

                    title: Text(
                      fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),

                    subtitle: Text(
                      chat['lastMessage'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    trailing: Text(
                      formatTime(chat['lastMessageTime']),

                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            receiverId: 'demo',
                            receiverName: 'Chats',
                            receiverImage: '',
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

  /// FORMAT TIME
  String formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();

    final hour = date.hour > 12 ? date.hour - 12 : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');

    final amPm = date.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $amPm";
  }
}
