// import 'package:chity/apis/messages_api.dart';
// import 'package:chity/apis/messages_api.dart' as NotificationService;
import 'package:chity/constants/app_colors.dart';
import 'package:chity/models/message_model.dart';
import 'package:chity/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatView extends StatelessWidget {
  static String id = 'ChatId';
  static CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');
  static TextEditingController textController = TextEditingController();
  static ScrollController scrollController = ScrollController();
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, String> map =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    return StreamBuilder<QuerySnapshot>(
        stream: messages.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<MessageModel> messagesList = [];
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              messagesList.add(MessageModel(
                id: snapshot.data!.docs[i]['id'] ?? '',
                body: snapshot.data!.docs[i]['message'] ?? '',
                sender: snapshot.data!.docs[i]['sender'] ?? '',
                senderEmail: snapshot.data!.docs[i]['sender'] ?? '',
                receiver: map['username'] ?? '',
                receiverEmail: map['email'] ?? '',
                timestamp: snapshot.data!.docs[i]['createdAt']?.toDate() ??
                    DateTime.now(),
              ));
            }
            return Scaffold(
              backgroundColor: const Color(0xff005073),
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                backgroundColor: const Color(0xff189ad3),
                title: Text(
                  "@${map['username']}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      controller: scrollController,
                      itemCount: messagesList.length,
                      itemBuilder: (context, idex) {
                        if ((messagesList[idex].id == map['email'] &&
                                messagesList[idex].sender ==
                                    map['userEmail']) ||
                            (messagesList[idex].sender == map['email'] &&
                                messagesList[idex].id == map['userEmail'])) {
                          if (messagesList[idex].sender == map['userEmail']) {
                            return ChatBubble(
                              username: map['userUserName']!,
                              message: messagesList[idex],
                            );
                          } else {
                            return ChatBubbleForFriend(
                              message: messagesList[idex],
                              username: map['username']!,
                            );
                          }
                        } else {
                          return const SizedBox(
                            height: 0,
                          );
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      style: const TextStyle(color: AppColors.textDark),
                      controller: textController,
                      onSubmitted: (data) async {
                        messages.add({
                          'message': data,
                          'createdAt': DateTime.now(),
                          'id': map['email'],
                          'sender': map['userEmail'],
                        });

                        // Send notification to recipient
                        // await NotificationService.sendMessageNotification(
                        //     recipientToken: map['fcmToken'] ?? '',
                        //     senderName: map['userUserName']!,
                        //     message: data);
                        textController.clear();
                        scrollController.animateTo(0,
                            duration: const Duration(seconds: 1),
                            curve: Curves.fastOutSlowIn);
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          color: AppColors.iconWhite,
                          icon: const Icon(Icons.send),
                          onPressed: () async {
                            messages.add({
                              'message': textController.text,
                              'createdAt': DateTime.now(),
                              'id': map['email'],
                              'sender': map['userEmail'],
                            });
                            textController.clear();
                            scrollController.animateTo(0,
                                duration: const Duration(seconds: 1),
                                curve: Curves.fastOutSlowIn);
                            // await NotificationService.sendMessageNotification(
                            //     recipientToken: map['fcmToken'] ?? '',
                            //     senderName: map['userUserName']!,
                            //     message: textController.text);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        hintText: 'Send message',
                        hintStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Scaffold(
                backgroundColor: Color(0xff005073),
                body: Center(
                    child: CircularProgressIndicator(
                  color: Colors.white,
                )));
          }
        });
  }
}
