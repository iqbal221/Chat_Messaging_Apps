import 'package:chat_messaging/core/screens/add_new_contact.dart';
import 'package:chat_messaging/core/screens/chat_screen.dart';
import 'package:chat_messaging/core/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  static const String name = '/contacts';

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  bool isSearchVisible = false;

  final TextEditingController searchController = TextEditingController();

  String searchText = '';

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

      /// APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: isSearchVisible
            ? TextField(
                controller: searchController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  hintText: "Search contact...",
                  border: InputBorder.none,
                ),
              )
            : const Text(
                "Select Contact",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

        actions: [
          /// SEARCH BUTTON ALWAYS SHOW
          IconButton(
            onPressed: () {
              setState(() {
                isSearchVisible = !isSearchVisible;

                if (!isSearchVisible) {
                  searchController.clear();
                  searchText = '';
                }
              });
            },
            icon: Icon(isSearchVisible ? Icons.close : Icons.search),
          ),

          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),

      /// FLOATING BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.pushNamed(context, AddNewContactScreen.name);
        },
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ),

      /// BODY
      body: StreamBuilder<QuerySnapshot>(
        stream: contactStream,

        builder: (context, snapshot) {
          final contacts = snapshot.data?.docs ?? [];

          /// FILTER CONTACTS
          final filteredContacts = contacts.where((contact) {
            final data = contact.data() as Map<String, dynamic>;

            final firstName = (data['firstName'] ?? '')
                .toString()
                .toLowerCase();

            final lastName = (data['lastName'] ?? '').toString().toLowerCase();

            final phone = (data['phoneNumber'] ?? '').toString().toLowerCase();

            return firstName.contains(searchText) ||
                lastName.contains(searchText) ||
                phone.contains(searchText);
          }).toList();

          return ListView(
            children: [
              const SizedBox(height: 10),

              /// ================= TOP OPTIONS =================
              buildTopOption(
                icon: Icons.group,
                title: "New Group",
                color: Colors.green,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Create Group Coming Soon")),
                  );
                },
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Create Community Coming Soon"),
                    ),
                  );
                },
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

              /// ================= LOADING =================
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator()),
                ),

              /// ================= EMPTY =================
              if (snapshot.hasData && filteredContacts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "No contacts found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),

              /// ================= CONTACT LIST =================
              if (filteredContacts.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredContacts.length,

                  itemBuilder: (context, index) {
                    final data =
                        filteredContacts[index].data() as Map<String, dynamic>;

                    final firstName = data['firstName'] ?? '';

                    final lastName = data['lastName'] ?? '';

                    final phone = data['phoneNumber'] ?? '';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,

                        child: Text(
                          firstName.isNotEmpty
                              ? firstName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      title: Text(
                        "$firstName $lastName",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),

                      subtitle: Text(phone),

                      /// OPEN CHAT
                      onTap: () async {
                        final receiverId = await UserService.getUserIdByPhone(
                          phone,
                        );

                        if (receiverId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("User not found in system"),
                            ),
                          );

                          return;
                        }

                        Navigator.pushNamed(
                          context,
                          ChatScreen.name,
                          arguments: {
                            "receiverId": receiverId,
                            "receiverName": "$firstName $lastName".trim(),
                            "receiverImage": "",
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

  /// TOP OPTION TILE
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
