import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    print(e);
  }

  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int countUnSeenMsg = 0;

  @override
  void initState() {
    super.initState();

    // Count UnSeen Message and display how many are
    FirebaseFirestore.instance
        .collection('rooms/12345678/messages')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        print(doc["isSeen"]);
        if (doc["isSeen"] == false) {
          setState(() {
            countUnSeenMsg++;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Chat()),
                    );

                    // Update all messages to isSeen = true
                    QuerySnapshot<Map<String, dynamic>> roomsSnapshot =
                        await FirebaseFirestore.instance
                            .collection('rooms/12345678/messages')
                            .get();

                    for (QueryDocumentSnapshot<Map<String, dynamic>> roomDoc
                        in roomsSnapshot.docs) {
                      String roomId = roomDoc.id;

                      await FirebaseFirestore.instance
                          .collection('rooms/12345678/messages')
                          .doc(roomId)
                          .update({
                        'isSeen': true,
                      });
                    }
                  },
                  child: const Icon(
                    Icons.chat,
                    color: Colors.blue,
                    size: 50,
                  ),
                ),
                Text(
                  countUnSeenMsg == 0 ? "" : "($countUnSeenMsg)",
                  style: const TextStyle(
                    color: Colors.blue,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
