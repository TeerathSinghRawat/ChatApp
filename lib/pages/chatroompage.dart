import 'dart:developer';
import 'dart:ffi';
import 'package:chat_app_original/models/ChatRoom.dart';
import 'package:chat_app_original/models/messagemodel.dart';
import 'package:chat_app_original/models/usermodel.dart';
import 'package:chat_app_original/pages/searchpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
class ChatroomPage extends StatefulWidget {
  final UserModel targetuser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseuser;

  const ChatroomPage({super.key, required this.targetuser, required this.chatroom, required this.userModel, required this.firebaseuser});

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  TextEditingController messagecontroller=TextEditingController();

  void sendMessage()async{
    String message=messagecontroller.text.trim();
    messagecontroller.clear();
    if(message!=""){
      //send message
      MessageModel newmessage=MessageModel(messageid: uuid.v1(),sender: widget.userModel.uid,text: message,createdon: DateTime.now(),seen: false);
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).collection("messages").doc(newmessage.messageid).set(newmessage.tomap());
      widget.chatroom.lastmessage=message;
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.
      chatroom.chatroomid).set(widget.chatroom.toMap());
      log("message sent");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(widget.targetuser.profilepic.toString()),
            ),
            SizedBox(width: 15,),
            Text(widget.targetuser.fullname.toString()),

          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Expanded(child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("chatrooms")
                      .doc(widget.chatroom.chatroomid).collection("messages").orderBy("createdon",descending: true).snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState==ConnectionState.active){
                      if(snapshot.hasData){
                        QuerySnapshot datasnapshot=snapshot.data as QuerySnapshot;
                        return ListView.builder(
                          reverse: true,
                            itemCount: datasnapshot.docs.length
                            ,itemBuilder: (context,index){
                              MessageModel currentmessage=MessageModel.
                              fromMap(datasnapshot.docs[index].data() as
                              Map<String,dynamic>);
                          return Row(
                            mainAxisAlignment: (currentmessage.sender==widget.userModel.uid)?
                            MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 10,
                                horizontal: 10),
                                margin: EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11),
                                  color: (currentmessage.sender==widget.userModel.uid)?
                                  Theme.of(context).colorScheme.secondary:Colors.green.shade700,
                                ),
                                  child: Text(currentmessage.text.toString(),
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ],
                          );
                        });
                      }else if(snapshot.hasError){
                        return Center(
                          child: Text("An error occured! please check your internet connectiom"),
                        );
                      }else{
                        return Center(
                          child: Text("Say Hi to your new friend"),
                        );
                      }
                    }else{
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }
                ),
              )),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                child: Row(
                  children: [
                    Flexible(child: TextField(
                      maxLines: null,
                      controller: messagecontroller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter message"
                      ),
                    )),
                    IconButton(
                        onPressed: (){
                          sendMessage();
                        },
                        icon: Icon(Icons.send, color: Theme.of(context).
                        colorScheme.secondary,))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
