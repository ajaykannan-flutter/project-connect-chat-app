import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/pages/chat_page.dart';
import 'package:flutter_auth/services/chat_service.dart';
import 'package:flutter_auth/theme.dart';

class ChatsListPage extends StatelessWidget {
  const ChatsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // Update the AppBar in chats_list_page.dart
appBar: AppBar(
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () => Navigator.pop(context),
  ),
  title: Row(
    children: [
      Icon(Icons.message, size: 24),
      SizedBox(width: 10),
      Text(
        'Messages',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    ],
  ),
  backgroundColor: AppTheme.primaryColor,
  elevation: 5,
  actions: [
    IconButton(
      icon: Icon(Icons.search, color: Colors.white),
      onPressed: () {
        // Add search functionality
      },
      tooltip: 'Search Messages',
    ),
    IconButton(
      icon: Icon(Icons.more_vert, color: Colors.white),
      onPressed: () {},
      tooltip: 'More Options',
    ),
  ],
),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getUserChats(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat, size: 60, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'No messages yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Find users to chat with'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              final users = chat['users'] as List<dynamic>;
              final userNames = chat['userNames'] as Map<String, dynamic>;
              
              // Get the other user's ID and name
              final otherUserId = users.firstWhere(
                (userId) => userId != currentUser!.uid,
              );
              final otherUserName = userNames[otherUserId] ?? 'Unknown User';

              return ChatListItem(
                userName: otherUserName,
                lastMessage: chat['lastMessage'] ?? '',
                time: chat['lastMessageTime'] != null
                    ? (chat['lastMessageTime'] as Timestamp).toDate()
                    : DateTime.now(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        receiverId: otherUserId,
                        receiverEmail: otherUserName,
                      ),
                    ),
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

// Chat List Item Widget
class ChatListItem extends StatelessWidget {
  final String userName;
  final String lastMessage;
  final DateTime time;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.userName,
    required this.lastMessage,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          lastMessage.length > 30 
            ? '${lastMessage.substring(0, 30)}...' 
            : lastMessage,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}