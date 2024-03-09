import 'dart:developer';

import 'package:chat_app_original/models/usermodel.dart';
import 'package:chat_app_original/pages/chatroompage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_original/models/ChatRoom.dart';
import 'package:uuid/uuid.dart';

var uuid=Uuid();
class SearchPage extends StatefulWidget {

  final UserModel usermodel;
  final User firebaseUser;

  const SearchPage({super.key, required this.usermodel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController emailcontroller=TextEditingController();

  Future<ChatRoomModel?>  getChatRoomModel(UserModel targetuser) async {
    ChatRoomModel? chatRomm;
    QuerySnapshot snapshot=await FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.usermodel.uid}",isEqualTo: true).where("participants.${targetuser.uid}",isEqualTo: true).get();
    if(snapshot.docs.length>0){
      //fetch the existing one
      var docData=snapshot.docs[0].data();
      ChatRoomModel existingChatroom=ChatRoomModel.fromMap(docData as Map<String,dynamic>);
      chatRomm=existingChatroom;
    }else{
      //create a new one
      ChatRoomModel newchatroom=ChatRoomModel(
          uuid.v1(), {
            widget.usermodel.uid.toString(): true,
        targetuser.uid.toString(): true
      },"",DateTime.now());

      await FirebaseFirestore.instance.collection("chatrooms").doc(newchatroom.chatroomid).set(newchatroom.toMap());

      chatRomm=newchatroom;

    }
    return chatRomm;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20
          ),
          child: Column(
            children: [
              TextField(
                controller: emailcontroller,
                decoration: InputDecoration(
                  labelText: "Email Address"
                ),

              ),
              SizedBox(height: 20,),
              CupertinoButton(
                  child: Text("Search"),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: (){
                    setState(() {

                    });
              }),
              SizedBox(height: 20,),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection("users").
                where("email",isGreaterThanOrEqualTo: emailcontroller.text).where("email", isNotEqualTo: widget.usermodel.email).snapshots(),
                builder: (context,snapshot){
                  if(snapshot.connectionState==ConnectionState.active){
                    if(snapshot.hasData){
                      QuerySnapshot datasnapshot=snapshot.data as QuerySnapshot;
                      if(datasnapshot.docs.length>0){
                        Map<String,dynamic> userMap=datasnapshot.docs[0].data()
                        as Map<String,dynamic>;
                        UserModel searcheduser=UserModel.fromMap(userMap);
                        return ListTile(
                          onTap: () async{
                            ChatRoomModel? chatroommodel=await getChatRoomModel(searcheduser);
                            if(chatroommodel!=null){
                              Navigator.pop(context);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context){
                                    return ChatroomPage(
                                      targetuser: searcheduser,
                                      chatroom: chatroommodel,
                                      userModel: widget.usermodel,
                                      firebaseuser: widget.firebaseUser,
                                    );
                                  }));
                            }

                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(searcheduser.profilepic.toString()),
                          ),
                          title: Text(searcheduser.fullname.toString()),
                          subtitle: Text(searcheduser.email.toString()),
                          trailing: Icon(Icons.keyboard_arrow_right),
                        );
                      }else{
                        return Text("No results found");
                      }


                    }else if(snapshot.hasError){
                      return Text("An error occured");
                    }else{
                      return Text("No results found");
                    }
                  }
                  else{
                    return CircularProgressIndicator();
                  }
                }
              )
              // StreamBuilder(),
            ],

          ),
        ),
      ),
    );
  }
}
