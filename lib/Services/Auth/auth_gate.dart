import 'package:chats/Services/Auth/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Pages/home_page.dart';


// handle user auth state using firebase
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            //User is logged in
            if(snapshot.hasData){
              return const HomePage();
            }
            //User aint logged in
            else{
              return const LoginOrRegister();
            }

          }
      ),
    );
  }
}
