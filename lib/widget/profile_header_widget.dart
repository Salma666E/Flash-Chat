import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final auth;

  const ProfileHeaderWidget({this.auth, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        height: 80,
        padding: const EdgeInsets.all(16).copyWith(left: 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(color: Colors.white),
                const Expanded(
                  child: Text(
                    '⚡️Chat',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onTap: () {
                      auth.signOut();
                      Navigator.pop(context);
                    }),
                const SizedBox(width: 4),
              ],
            )
          ],
        ),
      );

  Widget buildIcon(IconData icon) => Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white54,
        ),
        child: Icon(icon, size: 25, color: Colors.white),
      );
}
