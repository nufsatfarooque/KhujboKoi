
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_projects/services/storage_service.dart';
import 'package:get_it/get_it.dart';
import 'package:khujbokoi/chat%20screen/models/chat.dart';
import 'package:khujbokoi/chat%20screen/models/message.dart';
import 'package:khujbokoi/chat%20screen/models/user_profile.dart';
import 'package:khujbokoi/chat%20screen/services/database_service.dart';
import 'package:khujbokoi/chat%20screen/utils.dart';
import 'package:khujbokoi/services/auth_service.dart';
import  'package:khujbokoi/services/database.dart';
class ChatPage extends StatefulWidget {
  final UserProfile chatUser;
  const ChatPage({
    super.key,
    required this.chatUser,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final GetIt _getIt = GetIt.instance;
  late MueedDatabaseService _databaseService;
  late AuthService _authService;
  //late MediaService _mediaService;
  //late StorageService _storageService;
  ChatUser? currentUser, otherUser;
  @override
  void initState() {
    super.initState();
   /* _authService = _getIt.get<AuthService>();
   // _storageService = _getIt.get<StorageService>();
    //_mediaService = _getIt.get<MediaService>();
    _databaseService = _getIt.get<MueedDatabaseService>();
    currentUser = ChatUser(
        id: _authService.user!.uid, firstName: _authService.user!.displayName);
    otherUser =
        ChatUser(id: widget.chatUser.uid, firstName: widget.chatUser.name);
    */
    DatabaseService database = DatabaseService();
     currentUser?.firstName = FirebaseAuth.instance.currentUser as String?;

     if (currentUser != null && currentUser?.firstName != null) {
       var currentuserUid = database.getUIDbyUserName(currentUser!.firstName!);
     }

     

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUser.name),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder<DocumentSnapshot<Chat>>(
      stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No messages yet.'));
        }

        Chat? chat = snapshot.data!.data();
        List<ChatMessage> messages = [];
        if (chat != null && chat.messages != null) {
          messages = _generateChatMessageList(chat.messages!);
        }

        return DashChat(
          messageOptions: MessageOptions(
            showOtherUsersAvatar: true,
            showTime: true,
          ),
          inputOptions: InputOptions(
            alwaysShowSend: true,
            trailing: [
              _mediaMessageButton(),
            ],
          ),
          currentUser: currentUser!,
          onSend: _sendMessage,
          messages: messages, // Pass the generated messages list
        );
      },
    );
    // return StreamBuilder(
    //     stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
    //     builder: (context, snapshot) {
    //       Chat? chat = snapshot.data?.data();
    //       List<ChatMessage> messages = [];
    //       if (chat != null && chat.messages != null) {
    //         messages = _generateChatMessageList(
    //           chat.messages!,
    //         );
    //       }
    //       return DashChat(
    //           messageOptions: MessageOptions(
    //             showOtherUsersAvatar: true,
    //             showTime: true,
    //           ),
    //           inputOptions: InputOptions(alwaysShowSend: true),
    //           currentUser: currentUser!,
    //           onSend: _sendMessage,
    //           messages: []);
    //     });
    // return DashChat(
    //     messageOptions: MessageOptions(
    //       showOtherUsersAvatar: true,
    //       showTime: true,
    //     ),
    //     inputOptions: InputOptions(alwaysShowSend: true),
    //     currentUser: currentUser!,
    //     onSend: _sendMessage,
    //     messages: []);
  }

  // Future<void> _sendMessage(ChatMessage chatMessage) async {
  //   Message message = Message(
  //     senderID: currentUser!.id,
  //     content: chatMessage.text,
  //     messageType: MessageType.Text,
  //     sentAt: Timestamp.fromDate(chatMessage.createdAt),
  //   );

  //   await _databaseService.sendChatMessage(
  //       currentUser!.id, otherUser!.id, message);
  // }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias!.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(chatMessage.createdAt));
        await _databaseService.sendChatMessage(
            currentUser!.id, otherUser!.id, message);
      }
    } else {
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );

      try {
        await _databaseService.sendChatMessage(
          currentUser!.id,
          otherUser!.id,
          message,
        );
        print("Message sent successfully");
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  List<ChatMessage> _generateChatMessageList(List<Message> messages) {
  List<ChatMessage> chatMessages = messages.map((m) {
    if (m.messageType == MessageType.Image) {
      return ChatMessage(
        user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
        createdAt: m.sentAt!.toDate(),
        medias: [
          ChatMedia(
            url: m.content!,
            fileName: "",
            type: MediaType.image,
          ),
        ],
      );
    } else {
      return ChatMessage(
        user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
        text: m.content!,
        createdAt: m.sentAt!.toDate(),
      );
    }
  }).toList();

  chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return chatMessages;
}

  Widget _mediaMessageButton() {
    return IconButton(
        onPressed: () async {
          //File? file = await _mediaService.getImageFromGallery();
          String chatID =
              generateChatID(uid1: currentUser!.id, uid2: otherUser!.id);
          // String? downloadURL = await _storageService.uploadImageToChat(
          //     file: file, chatID: chatID);
          // if (downloadURL != null) {
          //   ChatMessage chatMessage = ChatMessage(
          //       user: currentUser!,
          //       createdAt: DateTime.now(),
          //       medias: [
          //         ChatMedia(
          //             url: downloadURL, fileName: "", type: MediaType.image)
          //       ]);
          //   _sendMessage(chatMessage);
          // }
                },
        icon: Icon(
          Icons.image,
          color: Theme.of(context).colorScheme.primary,
        ));
  }
}
