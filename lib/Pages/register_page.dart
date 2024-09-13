import 'package:chats/Services/Auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Components/my_button.dart';
import '../Components/my_text_field.dart';

class RegisterPage extends StatefulWidget {
  // Go to login page
  final void Function()? onTap;
  
  const RegisterPage({
    super.key, 
    required this.onTap
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Sign up user
  void signUp (BuildContext context) {
    // Get auth service
    final _auth = AuthService();

    // Passwords match --> create user
    if (passwordController.text == confirmPasswordController.text) {
      try {
        _auth.signUpWithEmailandPassword(
          emailController.text, 
          passwordController.text, 
          nameController.text
        );
      } catch(e) {
        showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ));
      }
    }

    //passwords dont match 
    else{
      showDialog(
        context: context, 
        builder: (context) => const AlertDialog(
          title: Text("Passwords don't match"),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff10497E),
                    Color(0xff281537),
                  ],
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(top: 60.0, left: 22),
                child: Text(
                  'Create\nAccount!',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: Colors.white,
                ),
                height: double.infinity,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Name text field
                      MyTextField(
                        focusNode: FocusNode(),
                        controller: nameController,
                        hintText: "Name",
                        obscureText: false,
                      ),
                      const SizedBox(height: 15),

                      // Email text field
                      MyTextField(
                        focusNode: FocusNode(),
                        controller: emailController,
                        hintText: "Email",
                        obscureText: false,
                      ),
                      const SizedBox(height: 15),

                      // Password text field
                      MyTextField(
                        focusNode: FocusNode(),
                        controller: passwordController,
                        hintText: "Password",
                        obscureText: true,
                      ),
                      const SizedBox(height: 15),

                      // Confirm Password text field
                      MyTextField(
                        focusNode: FocusNode(),
                        controller: confirmPasswordController,
                        hintText: "Confirm Password",
                        obscureText: true,
                      ),

                      const SizedBox(height: 20),

                      // Forgot Password link
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color(0xff281537),
                          ),
                        ),
                      ),
                      const SizedBox(height: 70),

                      // Sign Up Button
                      MyButton(
                        onTap: () => signUp,
                        text: "Sign Up", 
                      ),
                      const SizedBox(height: 150),

                      // Sign Up link
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Non-clickable text
                            const Text(
                              "Already have an account?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Clickable text
                            GestureDetector(
                              onTap: widget.onTap,
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
