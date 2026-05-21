import 'package:chat_messaging/core/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_messaging/core/screens/add_new_contact.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static const String name = '/contacts';

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final contactStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Select Contact",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.pushNamed(context, AddNewContactScreen.name);
        },
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: contactStream,
        builder: (context, snapshot) {
          final contacts = snapshot.data?.docs ?? [];

          return ListView(
            children: [
              const SizedBox(height: 10),

              // ================= TOP ACTIONS (ALWAYS SHOW) =================
              buildTopOption(
                icon: Icons.group,
                title: "New Group",
                color: Colors.green,
                onTap: () {},
              ),

              buildTopOption(
                icon: Icons.person_add,
                title: "New Contact",
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, AddNewContactScreen.name);
                },
              ),

              buildTopOption(
                icon: Icons.groups,
                title: "New Community",
                color: Colors.orange,
                onTap: () {},
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Text(
                  "Contacts on Chat",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // ================= LOADING =================
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator()),
                ),

              // ================= EMPTY STATE =================
              if (snapshot.hasData && contacts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "No contacts yet. Add new contact 👆",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),

              // ================= CONTACT LIST =================
              if (contacts.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contactId = contacts[index].id;
                    final data = contacts[index].data() as Map<String, dynamic>;

                    final firstName = data['firstName'] ?? '';
                    final lastName = data['lastName'] ?? '';
                    final phone = data['phoneNumber'] ?? '';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          firstName.isNotEmpty ? firstName[0] : "?",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        "$firstName $lastName",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(phone),

                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          ChatScreen.name,
                          arguments: {
                            'contactId': contactId,
                            'firstName': firstName,
                            'lastName': lastName,
                            'phoneNumber': phone,
                          },
                        );
                      },
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget buildTopOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
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
