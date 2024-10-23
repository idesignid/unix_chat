import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/providers/message_reply_provider.dart';
import 'package:whatsapp_ui/common/utils/colors.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_ui/features/auth/screens/profile_screen.dart';
import 'package:whatsapp_ui/features/chat/screens/chatai.dart';
import 'package:whatsapp_ui/features/chat/widgets/providers.dart';
import 'package:whatsapp_ui/features/group/screens/create_group_screen.dart';
import 'package:whatsapp_ui/features/select_contacts/screens/select_contacts_screen.dart';
import 'package:whatsapp_ui/features/chat/widgets/contacts_list.dart';
import 'package:whatsapp_ui/features/status/screens/confirm_status_screen.dart';
import 'package:whatsapp_ui/features/status/screens/status_contacts_screen.dart';
import 'features/chat/widgets/search_screen.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  const MobileLayoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController tabBarController;
  bool showFab = true;
  IconData fabIcon = Icons.comment;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 4, vsync: this); // Updated length
    tabBarController.addListener(_tabListener);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    tabBarController.removeListener(_tabListener);
    tabBarController.dispose();
    searchController.dispose();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _tabListener() {
    setState(() {
      // Hide FAB for Profile (index 2) and ChatAi (index 3) screens
      if (tabBarController.index == 2 || tabBarController.index == 3) {
        showFab = false;
      } else {
        showFab = true;
        fabIcon = tabBarController.index == 0 ? Icons.comment : Icons.add;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        ref.read(authControllerProvider).setUserState(false);
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
    }
  }

  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      ref.read(searchQueryProvider.notifier).state = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appBarColor,
        centerTitle: false,
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  ref.read(searchQueryProvider.notifier).state = query;
                },
              )
            : const Text(
                'Chatty',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          if (isSearching)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: stopSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: startSearch,
            ),
          PopupMenuButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.grey,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Create Group'),
                onTap: () => Future(
                  () => Navigator.pushNamed(context, CreateGroupScreen.routeName),
                ),
              ),
            ],
          ),
        ],
      ),
      body: isSearching
          ? const SearchScreen()
          : TabBarView(
              controller: tabBarController,
              children: [
                ContactsList(),
                StatusContactsScreen(),
                SignOutScreen(),
                ChatScreen(),  // Ensure the ChatScreen is the last one
              ],
            ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () async {
                if (tabBarController.index == 0) {
                  Navigator.pushNamed(context, SelectContactsScreen.routeName);
                } else {
                  File? pickedImage = await pickImageFromGallery(context);
                  if (pickedImage != null) {
                    Navigator.pushNamed(
                      context,
                      ConfirmStatusScreen.routeName,
                      arguments: pickedImage,
                    );
                  }
                }
              },
              backgroundColor: tabColor,
              child: Icon(
                fabIcon,
                color: Colors.white,
              ),
            )
          : null,
      bottomNavigationBar: BottomAppBar(
        height: 70,
  color: appBarColor,
  shape: const CircularNotchedRectangle(),
  notchMargin: 6.0,
  child: Container(
    height: 50, // Adjust the height of the TabBar here
    child: TabBar(
      controller: tabBarController,
      indicatorColor: tabColor,
      indicatorWeight: 4,
      labelColor: tabColor,
      unselectedLabelColor: Colors.grey,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12, // Adjust font size
      ),
      tabs: const [
        Tab(
          text: 'CHATS',
          icon: Icon(Icons.chat, size: 20), // Adjust icon size
        ),
        Tab(
          text: 'STORY',
          icon: Icon(Icons.image, size: 20), // Adjust icon size
        ),
        Tab(
          text: 'PROFILE',
          icon: Icon(Icons.person, size: 20), // Adjust icon size
        ),
        Tab(
          text: 'ChatAi',
          icon: Icon(Icons.chat_bubble_outline_sharp, size: 20), // Adjust icon size
        ),
      ],
    ),
  ),
),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
