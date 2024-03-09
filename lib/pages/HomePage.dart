import 'package:chat_app_original/models/ChatRoom.dart';
import 'package:chat_app_original/models/firebasehelper.dart';
import 'package:chat_app_original/models/uihelper.dart';
import 'package:chat_app_original/models/usermodel.dart';
import 'package:chat_app_original/pages/chatroompage.dart';
import 'package:chat_app_original/pages/loginpage.dart';
import 'package:chat_app_original/pages/searchpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel usermodel;
  final User firebaseuser;

  const HomePage({super.key, required this.usermodel, required this.firebaseuser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat App"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () async{
            await FirebaseAuth.instance.signOut();
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
              return LoginPage();
            }));
          }, icon: Icon(Icons.exit_to_app)),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("chatrooms").
            where("participants.${widget.usermodel.uid}",isEqualTo: true).snapshots(),
            builder: (context,snapshot){
              if(snapshot.connectionState==ConnectionState.active){
                if(snapshot.hasData){
                  QuerySnapshot chatroomssnapshot=snapshot.data as QuerySnapshot;
                  return ListView.builder(
                    itemBuilder: (context,index){
                      ChatRoomModel chatRoomModel=ChatRoomModel.
                      fromMap(chatroomssnapshot.docs[index].data() as Map<String,dynamic>);
                      Map<String,dynamic> participants=chatRoomModel.participants!;
                      List<String> participantskeys=participants.keys.toList();
                      participantskeys.remove(widget.usermodel.uid);
                      return FutureBuilder(
                          future: FirebaseHelper.getusermodelbyid(participantskeys[0]),
                          builder: (context,userdata){
                            if(userdata.connectionState==ConnectionState.done){
                              if(userdata.data!=null){
                                UserModel targetUser=userdata.data as UserModel;
                                return ListTile(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context){
                                      return ChatroomPage(targetuser: targetUser, chatroom: chatRoomModel, userModel: widget.usermodel, firebaseuser: widget.firebaseuser);
                                    }));
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(targetUser.profilepic.toString()),
                                  ),
                                  title: Text(targetUser.fullname.toString()),
                                  subtitle: (chatRoomModel.lastmessage.toString()!="")?Text(chatRoomModel.lastmessage.toString()): Text("Say hi to your friend",style: TextStyle(color: Colors.blue),),

                                );
                              }else{
                                return Container();
                              }

                            }else{
                              return Container();
                            }

                          }
                      );
                    },
                    itemCount: chatroomssnapshot.docs.length,);
                }
                else if(snapshot.hasError){
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                else{
                  return Center(
                    child: Text("NO TEXT"),
                  );
                }
              }
              else{
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return SearchPage(usermodel: widget.usermodel, firebaseUser: widget.firebaseuser);
          }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
