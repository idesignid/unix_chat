import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/utils/colors.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/common/widgets/custom_button.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_ui/models/user_model.dart';

class SignOutScreen extends ConsumerWidget {
  static const routeName = '/signout-screen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userDataAuthProvider);

    return Scaffold(
      body: userAsyncValue.when(
        data: (user) => Center(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                CircleAvatar(
                  backgroundImage: user?.profilePic == null
                      ? const NetworkImage(
                          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                        )
                      : NetworkImage(user!.profilePic!),
                  radius: 64,
                ),
                const SizedBox(height: 20),
                // User Name
                Text(
                  user!.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Sign Out Button
                SizedBox(
                  width: 150,
                  child: CustomButton(
                    onPressed: () {
                      ref.read(authControllerProvider).signOut(context);
                    },
                    text: 'SIGN OUT',
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
