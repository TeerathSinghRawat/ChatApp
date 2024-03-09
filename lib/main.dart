import 'package:chat_app_original/firebase_options.dart';
import 'package:chat_app_original/models/usermodel.dart';
import 'package:chat_app_original/pages/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_original/pages/HomePage.dart';
import 'pages/signuppage.dart';
import 'pages/completeprofile.dart';
import 'models/firebasehelper.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? currentuser=FirebaseAuth.instance.currentUser;
  if(currentuser!=null) {
    UserModel? thisusermodel=await FirebaseHelper.getusermodelbyid(currentuser.uid);
    if(thisusermodel!=null){
      runApp(MyApploggedin(usermodel: thisusermodel, firebaseuser: currentuser));
    }else
      runApp(MyApp());
  }else
  runApp(MyApp());
}
// Already logged in 
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// not logged in
class MyApploggedin extends StatelessWidget {
  final UserModel usermodel;
  final User firebaseuser;

  const MyApploggedin({super.key, required this.usermodel, required this.firebaseuser});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(usermodel: usermodel, firebaseuser: firebaseuser),
    );
  }
}