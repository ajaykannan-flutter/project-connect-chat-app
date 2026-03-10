import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/services/user_service.dart';  // Add this
import 'package:cloud_firestore/cloud_firestore.dart';      // Add this
import 'package:flutter_auth/pages/chats_list_page.dart'; // Add this line
import 'package:flutter_auth/pages/chat_page.dart'; // Add this line

import 'package:flutter_auth/pages/groups_list_page.dart';  // ← ADD THIS
import 'package:flutter_auth/pages/group_chat_page.dart';    // ← ADD THIS
import 'package:flutter_auth/pages/create_group_page.dart';
import 'package:flutter_auth/theme.dart';  // ← ADD THIS

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  final UserService _userService = UserService();
  List<Map<String, dynamic>> allUsers = [];  // Store all users
  List<Map<String, dynamic>> filteredUsers = [];  // Store filtered users
  TextEditingController searchController = TextEditingController();  // Search controller
  bool isLoading = true;  // Loading state

    @override
  void initState() {
    super.initState();
    loadAllUsers();
  }

  // Load all users from Firestore
  Future<void> loadAllUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      List<Map<String, dynamic>> users = [];
      for (var doc in querySnapshot.docs) {
        users.add({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }

      setState(() {
        allUsers = users;
        filteredUsers = users;  // Initially show all users
        isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Search/filter users
  void searchUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredUsers = allUsers;
      });
      return;
    }

    String searchText = query.toLowerCase();
    List<Map<String, dynamic>> results = allUsers.where((user) {
      String email = user['email']?.toString().toLowerCase() ?? '';
      return email.contains(searchText);
    }).toList();

    setState(() {
      filteredUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Update ONLY the AppBar section in home_page.dart (around line 50-100)
appBar: AppBar(
  title: Row(
    children: [
      Icon(
        Icons.connect_without_contact,
        color: Colors.white,
        size: 28,
      ),
      SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ProjectConnect",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            "Welcome, ${user?.email?.split('@')[0] ?? 'User'}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    ],
  ),
  backgroundColor: AppTheme.primaryColor,
  elevation: 10,
  shadowColor: AppTheme.primaryColor.withOpacity(0.3),
  centerTitle: false,
  actions: [
    // Groups button
    Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.2),
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GroupsListPage(),
              ),
            );
          },
          icon: Icon(Icons.groups, color: Colors.white),
          tooltip: 'Group Chats',
        ),
      ),
    ),
    
    // Messages button
    Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.2),
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatsListPage(),
              ),
            );
          },
          icon: Icon(Icons.message, color: Colors.white),
          tooltip: 'Private Messages',
        ),
      ),
    ),
    
    // Logout button
    Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.2),
        child: IconButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
          icon: Icon(Icons.logout, color: Colors.white),
          tooltip: 'Logout',
        ),
      ),
    ),
  ],
),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search users by email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchUsers('');
                        },
                      )
                    : null,
              ),
              onChanged: searchUsers,
            ),
          ),

          // SEARCH RESULTS
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 60, color: Colors.grey),
                            const SizedBox(height: 20),
                            Text(
                              searchController.text.isEmpty
                                  ? 'No users found'
                                  : 'No users found for "${searchController.text}"',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> userData = filteredUsers[index];
                          return UserCard(userData: userData);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
// User Card Widget
class UserCard extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserCard({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(
          userData['email'] ?? 'No email',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'User ID: ${userData['id']?.substring(0, 8)}...',  // Show first 8 chars of ID
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (userData['createdAt'] != null)
              Text(
                'Joined: ${DateTime.parse(userData['createdAt'].toDate().toString()).toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        // Replace the trailing IconButton in UserCard widget (around line 150-160):
trailing: IconButton(
  icon: const Icon(Icons.message, color: Colors.blue),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          receiverId: userData['id'],
          receiverEmail: userData['email'] ?? 'User',
        ),
      ),
    );
  },
),
      ),
    );
  }
}