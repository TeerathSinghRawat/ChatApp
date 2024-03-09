import 'package:chat_app_original/models/uihelper.dart';
import 'package:chat_app_original/models/usermodel.dart';
import 'package:chat_app_original/pages/HomePage.dart';
import 'package:chat_app_original/pages/signuppage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailcontroller=TextEditingController();
  TextEditingController passwordcontroller=TextEditingController();
  void checkvalues(){
    String email=emailcontroller.text.trim();
    String password=passwordcontroller.text.trim();

    if(email=="" || password==""){
      UIhelper.showAlertDialogue(context, "Incomplete Data", "Please fill all the fields");

    }else{
      login(email,password);
    }
  }

  void login(String email,String password)async{
    UserCredential? credentials;
    UIhelper.showloadingdialogue(context, "Logging IN...");
    try{
      credentials=await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

    }on FirebaseAuthException catch(ex){
      //close the loading dialogue
      Navigator.pop(context);

      //Show alert dialogue
      UIhelper.showAlertDialogue(context, "An error occured", ex.message.toString());
      print(ex.message.toString());
    }

    if(credentials!=null){
      String uid=credentials.user!.uid;

      DocumentSnapshot userData=await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel=UserModel.fromMap(userData.data() as Map<String,dynamic>);

      print("Log in Successful");
      Navigator.popUntil(context, (route) => route.isFirst);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return HomePage(usermodel: userModel, firebaseuser: credentials!.user!);
      }));
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
                    controller: emailcontroller,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: passwordcontroller,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password"
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CupertinoButton(
                      child: Text("Log In"),
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
            Text("Don't have an account?" ,
              style: TextStyle(fontSize: 16),),

            CupertinoButton(
                child: Text("Sign Up",
                  style: TextStyle(fontSize: 16),),
                onPressed: (){
                  Navigator.push(context,
                MaterialPageRoute(
                    builder: (context){
                      return SignUpPage();
                    }));})
          ],
        ),
      ),
    );
  }
}
