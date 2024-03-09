import 'dart:developer';
import 'dart:io';

import 'package:chat_app_original/models/uihelper.dart';
import 'package:chat_app_original/models/usermodel.dart';
import 'package:chat_app_original/pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';


class CompleteProfilePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseuser;

  const CompleteProfilePage({super.key,required this.userModel,required this.firebaseuser});


  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  File? imageFile;

  TextEditingController fullnamecontroller=TextEditingController();

  void selectimage(ImageSource source)async{
    XFile? pickedfile=await ImagePicker().pickImage(source: source);
    if(pickedfile!=null){
      cropImage(pickedfile);
    }
  }

  void cropImage(XFile file) async{
    CroppedFile? croppedimage=await ImageCropper().cropImage(
        sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20
    );
    if(croppedimage!=null){
      setState(() {
        imageFile=File(croppedimage.path);
      });
    }
  }

  void showphotooptions(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Upload Profile Picture"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: (){
                Navigator.pop(context);
                selectimage(ImageSource.gallery);
              },
              leading: Icon(Icons.photo_album),
              title: Text("Select from Gallery"),
            ),
            ListTile(

              onTap: (){
                Navigator.pop(context);

                selectimage(ImageSource.camera);
              },
              leading: Icon(Icons.camera_alt),
              title: Text("Take a picture"),
            ),

          ],
        ),
      );
    });
  }

  void checkvalues(){
    String fullname=fullnamecontroller.text.trim();

    if(fullname== "" || imageFile==null ){
      UIhelper.showAlertDialogue(context, "Incomplete Data","Please fill all the fields and uplaod a profile picture");
    }else{
      log("Uploading data");
      uploaddata();
    }
  }
  void uploaddata() async{

    UIhelper.showloadingdialogue(context, "Uploading Image..");
    UploadTask uploadtask=FirebaseStorage.instance.ref("Profile pictures").
    child(widget.userModel!.uid.toString()).putFile(imageFile!);
    TaskSnapshot snapshot=await uploadtask;
    String imageurl=await snapshot.ref.getDownloadURL();
    String fullname=fullnamecontroller.text.trim();
    widget.userModel!.fullname=fullname;
    widget.userModel!.profilepic=imageurl;

    await FirebaseFirestore.instance.collection("users").
    doc(widget.userModel!.uid).set(widget.userModel!.toMap()).then((value) {
      log("data uploaded");
      print("data uploaded");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return HomePage(usermodel: widget.userModel, firebaseuser: widget.firebaseuser);
      }));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: (){
                  showphotooptions();
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: imageFile==null?null:FileImage(imageFile!),
                  child: imageFile==null? Icon(Icons.person,size: 60,):null,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: fullnamecontroller,
                decoration: InputDecoration(
                  labelText: "Full Name"
                ),
              ),
              CupertinoButton(
                color: Colors.blue,
                  child: Text("Submit"),
                  onPressed: (){
                  checkvalues();
                  })
            ],
          ),
        ),
      ),
    );
  }
}
