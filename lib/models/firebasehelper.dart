import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'usermodel.dart';
class FirebaseHelper{
  static Future<UserModel?> getusermodelbyid(String uid) async{
    UserModel? usermodel;
    DocumentSnapshot docSnap=await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if(docSnap!=null){
      usermodel=UserModel.fromMap(docSnap.data() as Map<String,dynamic>);
    }
    return usermodel;
  }
}