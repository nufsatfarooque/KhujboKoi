import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:khujbokoi/chat%20screen/models/chat.dart';
import 'package:khujbokoi/chat%20screen/models/message.dart';
import 'package:khujbokoi/chat%20screen/models/user_profile.dart';
import 'package:khujbokoi/chat%20screen/utils.dart';
import 'package:khujbokoi/services/auth_service.dart';

class DatabaseService {
  DatabaseService() {
    _authService = _getIt.get<AuthService>();
    _setupCollectionReference();
  }

  final GetIt _getIt = GetIt.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late AuthService _authService;
  late CollectionReference<UserProfile> _usersCollection;
  late CollectionReference<Chat> _chatsCollection;

  void _setupCollectionReference() {
    try {
      print("Initializing collection reference...");
      _usersCollection =
          _firebaseFirestore.collection('users').withConverter<UserProfile>(
                fromFirestore: (snapshots, _) =>
                    UserProfile.fromJson(snapshots.data()!),
                toFirestore: (userProfile, _) => userProfile.toJson(),
              );
      print("Collection reference initialized.");
    } catch (e) {
      print("Error initializing collection reference: $e");
    }

    _chatsCollection = _firebaseFirestore
        .collection('chats')
        .withConverter<Chat>(
            fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
            toFirestore: (chat, _) => chat.toJson());
  }

  // Future<void> createUserProfile({required UserProfile userProfile}) async {
  //   try {
  //     print("Creating user profile for UID: ${userProfile.uid}");
  //     await _usersCollection.doc(userProfile.uid).set(userProfile);
  //     print("User profile created successfully.");
  //   } catch (e) {
  //     print("Error creating user profile: $e");
  //     throw Exception("Error creating user profile: $e");
  //   }
  // }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    print("Cleared on line 47");
    print("Current User UID: ${_authService.user?.uid}");
    print("cleared line 107");

    return _usersCollection
        .where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots();
  }

  Future<bool> checkChatExists(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final result = await _chatsCollection.doc(chatID).get();

    return result.exists;
      return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection.doc(chatID);
    final chat = Chat(id: chatID, participants: [uid1, uid2], messages: []);

    await docRef.set(chat);
  }

  // Future<void> sendChatMessage(
  //     String uid1, String uid2, Message message) async {
  //   String chatID = generateChatID(uid1: uid1, uid2: uid2);
  //   final docRef = _chatsCollection!.doc(chatID);
  //   await docRef.update({
  //     "message": FieldValue.arrayUnion([message.toJson()])
  //   });
  // }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    DocumentReference chatRef = _chatsCollection.doc(chatID);

    await chatRef.update({
      'messages': FieldValue.arrayUnion([message.toJson()]),
    });
  }

  // Stream getChatData(String uid1, String uid2) {
  //   String chatID = generateChatID(uid1: uid1, uid2: uid2);
  //   return _chatsCollection.doc(chatID).snapshots()
  //     as Stream<DocumentSnapshot<Chat>>;
  // }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatsCollection.doc(chatID).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot; // The snapshot is guaranteed to be non-null.
      } else {
        throw Exception("Chat document does not exist");
      }
    });
  }
}
