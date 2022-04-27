import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/utilty.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:swipe_to/swipe_to.dart';

import '../auth_provider.dart';

final _firestore = FirebaseFirestore.instance;
var providerWatch, providerRead;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  const ChatScreen({Key? key}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final focusNode = FocusNode();
  String replyMessage = '';
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    providerWatch = Provider.of<AuthProvider>(context, listen: true);
    providerRead = Provider.of<AuthProvider>(context, listen: false);
    return WillPopScope(
      onWillPop: () => onBackPressed(context, "ُExit App", () {
        SystemNavigator.pop();
        exit(0);
      }),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '⚡️Chat',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            InkWell(
                child: const Icon(
                  Icons.logout_rounded,
                  size: 28,
                  color: Colors.white,
                ),
                onTap: () {
                  providerRead.logout(context);
                }),
            const SizedBox(width: 16),
          ],
        ),
        backgroundColor: Colors.blue,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: MessagesWidget(
                    emailUser: providerWatch.prefs.getString('email'),
                    onSwipedMessage: (message) {
                      replyToMessage(message);
                      focusNode.requestFocus();
                    },
                  ),
                ),
              ),
              NewMessageWidget(
                focusNode: focusNode,
                emailUser: providerWatch.prefs.getString('email'),
                onCancelReply: cancelReply,
                replyMessage: replyMessage,
              )
            ],
          ),
        ),
      ),
    );
  }

  void replyToMessage(String message) {
    setState(() {
      replyMessage = message;
    });
  }

  void cancelReply() {
    setState(() {
      replyMessage = '';
    });
  }
}

class NewMessageWidget extends StatefulWidget {
  final FocusNode focusNode;
  final String emailUser;
  final String replyMessage;
  final VoidCallback onCancelReply;

  const NewMessageWidget({
    required this.focusNode,
    required this.emailUser,
    required this.replyMessage,
    required this.onCancelReply,
  }) : super();

  @override
  _NewMessageWidgetState createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  final _controller = TextEditingController();
  String message = '';

  static const inputTopRadius = Radius.circular(12);
  static const inputBottomRadius = Radius.circular(24);

  void sendMessage() async {
    FocusScope.of(context).unfocus();
    widget.onCancelReply();

    try {
      _firestore.collection('messages').add({
        'text': message,
        'sender': widget.emailUser,
        'Time': DateTime.now(),
        'name': providerWatch.prefs.getString('name') ?? 'hide_name',
        'replyMessage': widget.replyMessage
      });
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have been banned for using bad words'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isReplying = widget.replyMessage.isNotEmpty;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: [
                if (isReplying) buildReply(isReplying),
                TextField(
                  focusNode: widget.focusNode,
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: 'Type a message',
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.only(
                        topLeft: isReplying ? Radius.zero : inputBottomRadius,
                        topRight: isReplying ? Radius.zero : inputBottomRadius,
                        bottomLeft: inputBottomRadius,
                        bottomRight: inputBottomRadius,
                      ),
                    ),
                  ),
                  onChanged: (value) => setState(() {
                    message = value;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: message.trim().isEmpty ? null : sendMessage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReply(bool isReplying) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: const BorderRadius.only(
            topLeft: inputTopRadius,
            topRight: inputTopRadius,
          ),
        ),
        child: ReplyMessageWidget(
          message: widget.replyMessage,
          onCancelReply: widget.onCancelReply,
          isReplying: isReplying,
          sender: ' ',
          isMe: false,
        ),
      );
}

class ReplyMessageWidget extends StatelessWidget {
  final String message;
  final bool isReplying;
  final bool isMe;
  final bool isCancelReply;
  final String sender;
  final VoidCallback onCancelReply;

  const ReplyMessageWidget(
      {required this.message,
      required this.isReplying,
      required this.onCancelReply,
      this.isCancelReply=false,
      required this.sender,
      required this.isMe})
      : super();

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          children: [
            Container(
              color: Colors.green[700],
              width: 4,
            ),
            const SizedBox(width: 8),
            Expanded(child: buildReplyMessage()),
          ],
        ),
      );

  Widget buildReplyMessage() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: isMe
                    ? const SizedBox()
                    : Text(
                        sender,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
              if (!isCancelReply)
                GestureDetector(
                  child: const Icon(Icons.close, color: Colors.black, size: 16),
                  onTap: onCancelReply,
                )
            ],
          ),
          const SizedBox(height: 8),
          Text(message.toString(),
              style: TextStyle(color: isMe ? Colors.white70 : Colors.black54)),
        ],
      );
}

class MessagesWidget extends StatelessWidget {
  final String emailUser;
  final ValueChanged onSwipedMessage;

  const MessagesWidget({
    required this.emailUser,
    required this.onSwipedMessage,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('messages')
          .orderBy('Time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              return buildText('Something Went Wrong Try later');
            } else {
              var messages = snapshot.data;
              return messages!.docs.isEmpty
                  ? buildText('Say Hi..')
                  : ListView.builder(
                      reverse: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return SwipeTo(
                          onRightSwipe: () => onSwipedMessage(
                              snapshot.data!.docs[index]['text']),
                          child: MessageWidget(
                              message: snapshot.data!.docs[index]['text'],
                              replyMsg: snapshot.data!.docs[index]
                                  ['replyMessage'],
                              timeMsg: snapshot.data!.docs[index]['Time'],
                              isMe: providerWatch.prefs.getString('email') ==
                                  snapshot.data!.docs[index]['sender'],
                              sender: snapshot.data!.docs[index]['name']),
                        );
                      },
                    );
            }
        }
      },
    );
  }

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 24),
        ),
      );
}

class MessageWidget extends StatelessWidget {
  final String message;
  final String replyMsg;
  final bool isMe;
  final String sender;
  final Timestamp timeMsg;

  const MessageWidget(
      {required this.message,
      required this.sender,
      required this.isMe,
      required this.timeMsg,
      required this.replyMsg});

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(15);
    const borderRadius = BorderRadius.all(radius);
    final width = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            margin: isMe
                ? const EdgeInsets.only(left: 98, top: 16, right: 16, bottom: 8)
                : const EdgeInsets.only(
                    right: 98, top: 16, left: 16, bottom: 8),
            constraints: BoxConstraints(maxWidth: width * 3 / 4),
            decoration: BoxDecoration(
              color: isMe ? Colors.grey[800] : Colors.green[100],
              borderRadius: isMe
                  ? borderRadius
                      .subtract(const BorderRadius.only(bottomRight: radius))
                  : borderRadius
                      .subtract(const BorderRadius.only(bottomLeft: radius)),
            ),
            child: buildMessage(replyMsg, sender),
          ),
        ),
      ],
    );
  }

  Widget buildMessage(String replyMsg, String sender) {
    final messageWidget = Text(
      message.toString(),
      textAlign: TextAlign.left,
      style: TextStyle(color: isMe ? Colors.white : Colors.black),
    );
    if (replyMsg.isEmpty) {
      return Column(
        children: [
          isMe
              ? const SizedBox()
              : Text(
                  '$sender:',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
          messageWidget,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: isMe && replyMsg.isEmpty
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          buildReplyMessage(isMe, replyMsg, sender),
          messageWidget,
        ],
      );
    }
  }

  Widget buildReplyMessage(bool isMe, String replyMsg, String sender) {
    final replyMessage = replyMsg;
    final isReplying = replyMessage != '';
    log(isMe.toString());
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ReplyMessageWidget(
          message: replyMessage,
          onCancelReply: () {},
          isCancelReply: true,
          isReplying: isReplying,
          sender: sender,
          isMe: isMe),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flash_chat/auth_provider.dart';
// import 'package:flash_chat/widget/profile_header_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../constants.dart';

// final _firestore = FirebaseFirestore.instance;
// dynamic loggedInUser;
// String replyMessage = '';
// String messageText = '';
// var providerWatch;
// final focusNode = FocusNode();

// class ChatScreen extends StatefulWidget {
//   static const String id = 'chat_screen';
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final messageTextController = TextEditingController();
//   final _auth = FirebaseAuth.instance;

//   @override
//   void initState() {
//     super.initState();
//     getCurrentUser();
//   }

//   void getCurrentUser() async {
//     try {
//       final user = (await _auth.currentUser)!;
//       if (user != null) {
//         setState(() {
//           loggedInUser = user;
//         });
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     providerWatch = Provider.of<AuthProvider>(context, listen: true);
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.blue,
//       body: SafeArea(
//         child: loggedInUser == null
//             ? const Center(
//                 child: CircularProgressIndicator(
//                 color: Colors.white,
//               ))
//             : Column(
//                 children: [
//                   ProfileHeaderWidget(auth: _auth),
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(25),
//                           topRight: Radius.circular(25),
//                         ),
//                       ),
//                       child: MessagesStream(
//                         name: providerWatch.prefs.getString('name') ??
//                             'hide_name',
//                         providerWatch: providerWatch,
//                       ),
//                     ),
//                   ),
//                   Column(
//                     children: [
//                       if (replyMessage.isNotEmpty)
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.withOpacity(0.2),
//                             borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(12),
//                               topRight: Radius.circular(12),
//                             ),
//                           ),
//                           child: IntrinsicHeight(
//                             child: Row(
//                               children: [
//                                 Container(
//                                   color: Colors.green,
//                                   width: 4,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                     child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             '${providerWatch.prefs.getString('name') ?? 'hide_name'}',
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                         ),
//                                         // if (cancelReply != null)
//                                         //   GestureDetector(
//                                         //     child: const Icon(Icons.close,
//                                         //         size: 16),
//                                         //     onTap: ()=>cancelReply(setState),
//                                         //   )
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(replyMessage.toString(),
//                                         style: const TextStyle(
//                                             color: Colors.black54)),
//                                   ],
//                                 )),
//                               ],
//                             ),
//                           ),
//                         ),
//                       Container(
//                         decoration: kMessageContainerDecoration,
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: <Widget>[
//                             Expanded(
//                               child: TextField(
//                                 controller: messageTextController,
//                                 onChanged: (String value) {
//                                   messageText = value;
//                                 },
//                                 decoration: kMessageTextFieldDecoration,
//                                 focusNode: focusNode,
//                                 textCapitalization:
//                                     TextCapitalization.sentences,
//                                 autocorrect: true,
//                                 enableSuggestions: true,
//                               ),
//                             ),
//                             FlatButton(
//                               onPressed: () {
//                                 messageTextController.clear();
//                                 _firestore.collection('messages').add({
//                                   'text': messageText,
//                                   'sender': loggedInUser.email,
//                                   'Time': DateTime.now(),
//                                   'name':
//                                       providerWatch.prefs.getString('name') ??
//                                           'hide_name',
//                                 });
//                               },
//                               child: const Text(
//                                 'Send',
//                                 style: kSendButtonTextStyle,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }

// class MessagesStream extends StatefulWidget {
//   MessagesStream({required this.name, required this.providerWatch, Key? key})
//       : super(key: key);
//   String name;
//   var providerWatch;

//   @override
//   State<MessagesStream> createState() => _MessagesStreamState();
// }
//   void cancelReply(setState) {
//     setState(() {
//       replyMessage = '';
//     });
//   }
// class _MessagesStreamState extends State<MessagesStream> {
//   void replyToMessage(String message) {
//     setState(() {
//       replyMessage = message;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore
//           .collection('messages')
//           .orderBy('Time', descending: false)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(
//             child: CircularProgressIndicator(
//               backgroundColor: Colors.lightBlueAccent,
//             ),
//           );
//         }
//         final messages = snapshot.data!.docs.reversed;
//         List<MessageBubble> messageBubbles = [];
//         for (var message in messages) {
//           final messageText = message.get('text');
//           final String messageSender = message.get('name') ?? 'hide_name';
//           final messageBubble = MessageBubble(
//             sender: messageSender,
//             text: messageText,
//             isMe: message.get('sender') == loggedInUser.email,
//             onSwipedMessage: (String message) {
//               replyToMessage(message);
//               focusNode.requestFocus();
//             },
//           );

//           messageBubbles.add(messageBubble);
//         }
//         return Expanded(
//           child: ListView(
//             reverse: true,
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
//             children: messageBubbles,
//           ),
//         );
//       },
//     );
//   }
// }

// class MessageBubble extends StatefulWidget {
//   MessageBubble(
//       {required this.sender,
//       required this.text,
//       required this.isMe,
//       onSwipedMessage});

//   final String sender;
//   final String text;
//   final bool isMe;

//   @override
//   State<MessageBubble> createState() => _MessageBubbleState();
// }

// class _MessageBubbleState extends State<MessageBubble> {
//   var onSwipedMessage;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: Column(
//         crossAxisAlignment:
//             widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             widget.sender,
//             style: const TextStyle(
//               fontSize: 12.0,
//               color: Colors.black54,
//             ),
//           ),
//           Material(
//             borderRadius: widget.isMe
//                 ? const BorderRadius.only(
//                     topLeft: Radius.circular(30.0),
//                     bottomLeft: Radius.circular(30.0),
//                     bottomRight: Radius.circular(30.0))
//                 : const BorderRadius.only(
//                     bottomLeft: Radius.circular(30.0),
//                     bottomRight: Radius.circular(30.0),
//                     topRight: Radius.circular(30.0),
//                   ),
//             elevation: 5.0,
//             color: widget.isMe ? Colors.lightBlueAccent : Colors.white,
//             child: Padding(
//               padding:
//                   const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//               child: buildMessage(setState),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildMessage(setState) {
//     final messageWidget = Text(messageText.toString());
//     if (replyMessage == null) {
//       return messageWidget;
//     } else {
//       return Column(
//         crossAxisAlignment: widget.isMe && replyMessage == null
//             ? CrossAxisAlignment.end
//             : CrossAxisAlignment.start,
//         children: <Widget>[
//           buildReplyMessage(setState),
//           messageWidget,
//         ],
//       );
//     }
//   }

//   Widget buildReplyMessage(setState) {
//     final String replyMsg = replyMessage.toString();
//     final isReplying = replyMsg != null;

//     if (!isReplying) {
//       return Container();
//     } else {
//       return Container(
//           margin: const EdgeInsets.only(bottom: 8),
//           child: IntrinsicHeight(
//             child: Row(
//               children: [
//                 Container(
//                   color: Colors.green,
//                   width: 4,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                     child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             replyMsg,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         // if (cancelReply != null)
//                           GestureDetector(
//                             child: const Icon(Icons.close, size: 16),
//                             onTap: ()=>cancelReply(setState),
//                           )
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(messageText.toString(),
//                         style: const TextStyle(color: Colors.black54)),
//                   ],
//                 )),
//               ],
//             ),
//           )
//           // ReplyMessageWidget(message: replyMsg, onCancelReply: () {  },),
//           );
//     }
//   }
// }
