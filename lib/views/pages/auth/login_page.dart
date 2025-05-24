import 'package:flutter/material.dart';
import 'package:flutter_project/data/services/auth_services.dart';
import 'package:flutter_project/utils/colorconstants.dart';
import 'package:flutter_project/utils/image_constants.dart';
import 'package:flutter_project/views/pages/auth/signup_page.dart';
import 'package:flutter_project/views/pages/home_page.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  final formKey1 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LoginScreenController>(
        builder: (context, loginController, child) => LayoutBuilder(
          builder: (context, constraints) {
            // Determine if we're on a large screen (web/desktop)
            bool isLargeScreen = constraints.maxWidth > 800;
            bool isTablet =
                constraints.maxWidth > 600 && constraints.maxWidth <= 800;

            return SingleChildScrollView(
              child: SafeArea(
                child: Center(
                  child: Container(
                    width: isLargeScreen
                        ? 400 // Fixed width for large screens
                        : isTablet
                            ? constraints.maxWidth *
                                0.7 // 70% width for tablets
                            : double.infinity, // Full width for mobile
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 40 : 24,
                      vertical: 24,
                    ),
                    child: Form(
                      key: formKey1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Add some top spacing for better centering
                          if (isLargeScreen) SizedBox(height: 60),

                          // Logo/Title section
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                // Optional: Add a logo here if you have one
                                // Image.asset(
                                //   'assets/images/logo.png',
                                //   height: 80,
                                // ),
                                // SizedBox(height: 20),
                                Text(
                                  'Buyit Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isLargeScreen ? 32 : 28,
                                    color: Colorconstants.primarycolor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (isLargeScreen) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    'Welcome back! Please sign in to your account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colorconstants.greycolor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Email field
                          TextFormField(
                            controller: emailcontroller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              RegExp emailreg = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                              if (!emailreg.hasMatch(value)) {
                                return 'Invalid Email Address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Email',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colorconstants.greycolor,
                              ),
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colorconstants.greycolor,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colorconstants.primarycolor,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colorconstants.redcolor,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colorconstants.redcolor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  Colorconstants.greycolor.withOpacity(0.1),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      Colorconstants.greycolor.withOpacity(0.3),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isLargeScreen ? 18 : 16,
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Password field
                          TextFormField(
                            controller: passwordcontroller,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              if (value.length < 6) {
                                return 'Password length must be atleast 6';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colorconstants.greycolor,
                              ),
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colorconstants.greycolor,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colorconstants.primarycolor,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colorconstants.redcolor,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colorconstants.redcolor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  Colorconstants.greycolor.withOpacity(0.1),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      Colorconstants.greycolor.withOpacity(0.3),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isLargeScreen ? 18 : 16,
                              ),
                            ),
                          ),

                          SizedBox(height: 32),

                          // Login button
                          InkWell(
                            onTap: () async {
                              if (formKey1.currentState!.validate()) {
                                var success = await loginController.loginUser(
                                    email: emailcontroller.text,
                                    password: passwordcontroller.text,
                                    context: context);
                                if (success) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomePage(),
                                    ),
                                  );
                                  emailcontroller.clear();
                                  passwordcontroller.clear();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Login failed. Please check your email and password.',
                                      ),
                                      backgroundColor:
                                          Colorconstants.primarycolor,
                                    ),
                                  );
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              height: isLargeScreen ? 56 : 50,
                              decoration: BoxDecoration(
                                color: loginController.islogined
                                    ? Colorconstants.greycolor
                                    : Colorconstants.primarycolor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isLargeScreen
                                    ? [
                                        BoxShadow(
                                          color: Colorconstants.primarycolor
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: loginController.islogined
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colorconstants.whitecolor,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Login',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: isLargeScreen ? 18 : 16,
                                          color: Colorconstants.whitecolor,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          SizedBox(height: 24),

                          // Sign up link
                          Center(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignupScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  "Don't have an account? Sign up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: isLargeScreen ? 16 : 14,
                                    color: Colorconstants.primarycolor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 32),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color:
                                      Colorconstants.greycolor.withOpacity(0.3),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colorconstants.greycolor,
                                    fontSize: isLargeScreen ? 16 : 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color:
                                      Colorconstants.greycolor.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 32),

                          // Google sign in button
                          InkWell(
                            onTap: () async {
                              var success =
                                  await loginController.googleSignin();
                              if (success) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Google Sign-In failed. Please try again.'),
                                    backgroundColor:
                                        Colorconstants.primarycolor,
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              height: isLargeScreen ? 56 : 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      Colorconstants.greycolor.withOpacity(0.3),
                                  width: 1,
                                ),
                                color: Colors.white,
                                boxShadow: isLargeScreen
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: loginController.googleislogined
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colorconstants.primarycolor,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            ImageConstants.googlepng,
                                            height: isLargeScreen ? 26 : 24,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Continue with Google',
                                            style: TextStyle(
                                              color: Colorconstants.blackcolor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: isLargeScreen ? 18 : 16,
                                            ),
                                          )
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          // Add bottom spacing for better centering
                          if (isLargeScreen) SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
