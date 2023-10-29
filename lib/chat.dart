import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aakash Available"),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          // Receive Message
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rooms/12345678/messages')
                  .orderBy('createdAt')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('$snapshot.error'));
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                var docs = snapshot.data!.docs;

                return docs.isEmpty
                    ? const Text("No message yet.")
                    : SingleChildScrollView(
                        reverse: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: docs.length,
                          itemBuilder: (context, i) {
                            if (docs[i]['uid'] == "1") {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Text(
                                      formatter.format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              docs[i]['createdAt'])),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: screenWidth / 2, right: 12),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                    child: Text(
                                      '${docs[i]['text']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              );
                            } else if (docs[i]['uid'] == "2") {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 12),
                                    child: Text(
                                      formatter.format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              docs[i]['createdAt'])),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    margin: EdgeInsets.only(
                                        right: screenWidth / 2, left: 12),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 206, 206, 206),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                    child: Text(
                                      '${docs[i]['text']}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      );
              },
            ),
          ),

          // Send Message TextField
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              width: MediaQuery.of(context).size.width,
              color: const Color.fromARGB(255, 231, 231, 231),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      minLines: 1,
                      maxLines: 5,
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: "Send Message (Min. 200 characters)",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Send Message to firestore
                      sendMessage();
                    },
                    child: const Center(
                        child: Icon(
                      Icons.send,
                      color: Colors.blue,
                    )),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "text": messageController.text,
        "isSeen": false,
        "uid": "2"
      };

      FirebaseFirestore.instance
          .collection('rooms/12345678/messages')
          .add(chatMessageMap);

      messageController.clear();
    }
  }
}
