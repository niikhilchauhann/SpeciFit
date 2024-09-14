import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomPopupMenu extends StatelessWidget {
  const CustomPopupMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: 0,
            child: Text(
              "Report Bugs",
            ),
          ),
          const PopupMenuItem(
            value: 1,
            child: Text(
              "Sign Out",
            ),
          ),
        ];
      },
      onSelected: (value) async {
        if (value == 0) {
          final Uri params = Uri(
            scheme: 'mailto',
            path: 'isedenlive@gmail.com',
            query:
                'subject=App Feedback&body=Hey there, I found a bug in SpeciFit App.\nHere are the details:\n', //add subject and body here
          );
          await launchUrl(params);
        } else if (value == 1) {
          await FirebaseAuth.instance.signOut();
        }
      },
    );
  }
}
