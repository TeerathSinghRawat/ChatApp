import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;


  MessageModel(
      {this.messageid, this.sender, this.text, this.seen, this.createdon});


  MessageModel.fromMap(Map<String,dynamic> map){
    sender=map["sender"];
    text=map["text"];
    seen=map["seen"];
    createdon=map["createdon"].toDate();
    messageid=map["messageid"];
  }

  Map<String,dynamic> tomap(){
    return {
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdon": createdon,
      "messageid": messageid
    };
  }
}