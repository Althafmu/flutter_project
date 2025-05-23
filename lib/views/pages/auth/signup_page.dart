import 'package:flutter/material.dart';
import 'package:flutter_project/data/services/auth_services.dart';
import 'package:flutter_project/utils/colorconstants.dart';
import 'package:flutter_project/utils/image_constants.dart';
import 'package:flutter_project/views/pages/auth/login_page.dart';
import 'package:flutter_project/views/pages/home_page.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all form fields
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipController = TextEditingController();

  @override
  void dispose() {
    // Dispose all controllers
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SignupScreenController>(
        builder: (context, providerobj, child) => SingleChildScrollView(
          child: SafeArea(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Colorconstants.primarycolor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fill in your details to get started',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colorconstants.greycolor,
                      ),
                    ),
                    SizedBox(height: 32),

                    // Name Field
                    _buildTextFormField(
                      controller: nameController,
                      hintText: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (value.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Email Field
                    _buildTextFormField(
                      controller: emailController,
                      hintText: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        RegExp emailRegexp = RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
                        if (!emailRegexp.hasMatch(value)) {
                          return 'Invalid Email Address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Phone Field
                    _buildTextFormField(
                      controller: phoneController,
                      hintText: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 10) {
                          return 'Phone number must be at least 10 digits';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Address Field
                    _buildTextFormField(
                      controller: addressController,
                      hintText: 'Street Address',
                      icon: Icons.home_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // City and State Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            controller: cityController,
                            hintText: 'City',
                            icon: Icons.location_city_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter city';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTextFormField(
                            controller: stateController,
                            hintText: 'State',
                            icon: Icons.map_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter state';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // ZIP Code Field
                    _buildTextFormField(
                      controller: zipController,
                      hintText: 'ZIP Code',
                      icon: Icons.local_post_office_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter ZIP code';
                        }
                        if (value.length < 5) {
                          return 'ZIP code must be at least 5 digits';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Password Field
                    _buildTextFormField(
                      controller: passwordController,
                      hintText: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Confirm Password Field
                    _buildTextFormField(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),

                    // Sign Up Button
                    GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          Map<String, String> userData = {
                            'name': nameController.text,
                            'email': emailController.text,
                            'phone': phoneController.text,
                            'address': addressController.text,
                            'city': cityController.text,
                            'state': stateController.text,
                            'zipCode': zipController.text,
                          };

                          var success = await providerobj.registerUser(
                            password: passwordController.text,
                            email: emailController.text,
                            userData: userData,
                            context: context,
                          );

                          if (success) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                            _clearAllFields();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Registration failed. Please try again.'),
                                backgroundColor: Colorconstants.primarycolor,
                              ),
                            );
                          }
                        }
                      },
                      child: providerobj.islogined
                          ? CircularProgressIndicator()
                          : Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colorconstants.primarycolor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colorconstants.whitecolor,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    SizedBox(height: 16),

                    // Login Link
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colorconstants.blackcolor,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colorconstants.blackcolor,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Google Sign In Button
                    context.watch<LoginScreenController>().googleislogined
                        ? CircularProgressIndicator()
                        : InkWell(
                            onTap: () async {
                              var success = await context
                                  .read<LoginScreenController>()
                                  .googleSignin();
                              if (success) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                  ),
                                  (route) => false,
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
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colorconstants.primarycolor,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    ImageConstants.googlepng,
                                    height: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      color: Colorconstants.whitecolor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colorconstants.greycolor),
        hintStyle: TextStyle(
          fontWeight: FontWeight.normal,
          color: Colorconstants.greycolor,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colorconstants.redcolor),
        ),
        filled: true,
        fillColor: Colorconstants.greycolor.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _clearAllFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    phoneController.clear();
    addressController.clear();
    cityController.clear();
    stateController.clear();
    zipController.clear();
  }
}
