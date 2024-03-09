import 'package:chat_app_original/models/uihelper.dart';
import 'package:chat_app_original/models/usermodel.dart';
import 'package:chat_app_original/pages/completeprofile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
  TextEditingController cpasswordController=TextEditingController();

  void checkvalues(){
    String email=emailController.text.trim();
    String password=passwordController.text.trim();
    String cpassword=cpasswordController.text.trim();
    if(email=="" || password=="" || cpassword==""){

      UIhelper.showAlertDialogue(context, "Incomplete data", "please fill all the fields");
    }else if(password!=cpassword){
      UIhelper.showAlertDialogue(context, "Passwords Mismatch", "The password you entered does not match");

    }else{
      print("sign up successfully");
      signup(email, password);
    }
  }

  void signup(String email,String password) async{
    UserCredential? credential;
    UIhelper.showloadingdialogue(context, "Creating new account...");
    try{
      credential=await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(ex){
      Navigator.pop(context);
      UIhelper.showAlertDialogue(context, "An error occured", ex.code.toString());
    }
    if(credential!=null){
      String uid=credential.user!.uid;

      UserModel newuser=UserModel(uid,"", email, "");
      await FirebaseFirestore.instance.collection("users").doc(uid).set
        (newuser.toMap()).then((value){
          print("new user created");
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
            return
            CompleteProfilePage(userModel: newuser,firebaseuser: credential!.user!,);
          }));
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 40
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Chat App",style: TextStyle(
                    color: Colors.blue,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Password"
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: cpasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Confirm Password"
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CupertinoButton(
                      child: Text("Sign Up"),
                      color: Colors.blue,
                      onPressed: (){
                        checkvalues();
                      }
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Already have an account?" ,
              style: TextStyle(fontSize: 16),),

            CupertinoButton(
                child: Text("Log In",
                  style: TextStyle(fontSize: 16),),
                onPressed: (){
                  Navigator.pop(context);
                })
          ],
        ),
      ),
    );;
  }
}
