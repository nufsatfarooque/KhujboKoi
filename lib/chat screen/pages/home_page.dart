import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:khujbokoi/chat%20screen/models/user_profile.dart';
import 'package:khujbokoi/chat%20screen/pages/chat_page.dart';
import 'package:khujbokoi/chat%20screen/services/database_service.dart';
import 'package:khujbokoi/chat%20screen/services/navigation_service.dart';
import 'package:khujbokoi/chat%20screen/widgets/chat_tile.dart';
import 'package:khujbokoi/services/auth_service.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          // IconButton(
          //     onPressed: () async {
          //       bool result = await _authService.logout();
          //       if (result) {
                 
          //         _navigationService.pushReplacementNamed("/login");
          //       }
          //     },
          //     color: Colors.red,
          //     icon: const Icon(
          //       Icons.logout,
          //     ))
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    print("Cleared on line 58");
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 20.0,
        ),
        child: _chatsList(),
      ),
    );
  }

  Widget _chatsList() {
    //print("Current User UID from homepage: ${_authService.user?.uid}");
    print("Cleared on line 74");
    return StreamBuilder(
        stream: _databaseService.getUserProfiles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Error fetching data: ${snapshot.error}");
            return const Center(
              child: Text("Unable to load data"),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            print("Cleared on line 85");
            final users = snapshot.data!.docs;
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  UserProfile user = users[index].data();
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChatTile(
                        userProfile: user,
                        onTap: () async {
                          final chatExists =
                              await _databaseService.checkChatExists(
                                  _authService.user!.uid, user.uid);
                          if (!chatExists) {
                            await _databaseService.createNewChat(
                                _authService.user!.uid, user.uid);
                          }
                          _navigationService
                              .push(MaterialPageRoute(builder: (context) {
                            return ChatPage(chatUser: user);
                          }));
                        }),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
