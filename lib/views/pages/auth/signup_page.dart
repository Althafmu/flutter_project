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
            child: _buildResponsiveLayout(context, providerobj),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(
      BuildContext context, SignupScreenController providerobj) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final isMobile = screenWidth < 768;

    if (isDesktop) {
      return _buildDesktopLayout(context, providerobj);
    } else if (isTablet) {
      return _buildTabletLayout(context, providerobj);
    } else {
      return _buildMobileLayout(context, providerobj);
    }
  }

  Widget _buildDesktopLayout(
      BuildContext context, SignupScreenController providerobj) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 1200),
        child: Row(
          children: [
            // Left side - Welcome section
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(48),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colorconstants.primarycolor,
                      Colorconstants.primarycolor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Our Platform',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colorconstants.whitecolor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Join thousands of users who trust our platform for their needs. Create your account and start your journey with us today.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colorconstants.whitecolor.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right side - Form
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(48),
                child: _buildForm(context, providerobj, isDesktop: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(
      BuildContext context, SignupScreenController providerobj) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        padding: EdgeInsets.all(32),
        child: _buildForm(context, providerobj, isTablet: true),
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, SignupScreenController providerobj) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      child: _buildForm(context, providerobj),
    );
  }

  Widget _buildForm(BuildContext context, SignupScreenController providerobj,
      {bool isDesktop = false, bool isTablet = false}) {
    final titleSize = isDesktop ? 32.0 : (isTablet ? 28.0 : 28.0);
    final subtitleSize = isDesktop ? 18.0 : (isTablet ? 16.0 : 16.0);
    final buttonHeight = isDesktop ? 56.0 : (isTablet ? 52.0 : 50.0);
    final spacing = isDesktop ? 24.0 : (isTablet ? 20.0 : 16.0);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isDesktop) SizedBox(height: 40),
          Text(
            'Create Account',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: titleSize,
              color: Colorconstants.primarycolor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Fill in your details to get started',
            style: TextStyle(
              fontSize: subtitleSize,
              color: Colorconstants.greycolor,
            ),
          ),
          SizedBox(height: isDesktop ? 40 : 32),

          // Name Field
          _buildTextFormField(
            controller: nameController,
            hintText: 'Full Name',
            icon: Icons.person_outline,
            isDesktop: isDesktop,
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
          SizedBox(height: spacing),

          // Email and Phone Row (for desktop/tablet)
          if (isDesktop || isTablet)
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    isDesktop: isDesktop,
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
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTextFormField(
                    controller: phoneController,
                    hintText: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    isDesktop: isDesktop,
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
                ),
              ],
            )
          else ...[
            // Email Field (Mobile)
            _buildTextFormField(
              controller: emailController,
              hintText: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                RegExp emailRegexp =
                    RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
                if (!emailRegexp.hasMatch(value)) {
                  return 'Invalid Email Address';
                }
                return null;
              },
            ),
            SizedBox(height: spacing),

            // Phone Field (Mobile)
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
          ],
          SizedBox(height: spacing),

          // Address Field
          _buildTextFormField(
            controller: addressController,
            hintText: 'Street Address',
            icon: Icons.home_outlined,
            isDesktop: isDesktop,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          SizedBox(height: spacing),

          // City, State, and ZIP Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextFormField(
                  controller: cityController,
                  hintText: 'City',
                  icon: Icons.location_city_outlined,
                  isDesktop: isDesktop,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter city';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: _buildTextFormField(
                  controller: stateController,
                  hintText: 'State',
                  icon: Icons.map_outlined,
                  isDesktop: isDesktop,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'State';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: _buildTextFormField(
                  controller: zipController,
                  hintText: 'ZIP',
                  icon: Icons.local_post_office_outlined,
                  keyboardType: TextInputType.number,
                  isDesktop: isDesktop,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ZIP';
                    }
                    if (value.length < 5) {
                      return 'Invalid ZIP';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),

          // Password Fields Row (for desktop/tablet)
          if (isDesktop || isTablet)
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: passwordController,
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    isDesktop: isDesktop,
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
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTextFormField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    isDesktop: isDesktop,
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
                ),
              ],
            )
          else ...[
            // Password Field (Mobile)
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
            SizedBox(height: spacing),

            // Confirm Password Field (Mobile)
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
          ],
          SizedBox(height: isDesktop ? 40 : 32),

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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                  _clearAllFields();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Registration failed. Please try again.'),
                      backgroundColor: Colorconstants.primarycolor,
                    ),
                  );
                }
              }
            },
            child: providerobj.islogined
                ? SizedBox(
                    height: buttonHeight,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Container(
                    width: double.infinity,
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      color: Colorconstants.primarycolor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isDesktop ? 18 : 16,
                          color: Colorconstants.whitecolor,
                        ),
                      ),
                    ),
                  ),
          ),
          SizedBox(height: spacing),

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
                fontSize: isDesktop ? 16 : 14,
                color: Colorconstants.blackcolor,
              ),
            ),
          ),
          SizedBox(height: spacing),

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
          SizedBox(height: spacing),

          // Google Sign In Button
          context.watch<LoginScreenController>().googleislogined
              ? SizedBox(
                  height: buttonHeight,
                  child: Center(child: CircularProgressIndicator()),
                )
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
                          content:
                              Text('Google Sign-In failed. Please try again.'),
                          backgroundColor: Colorconstants.primarycolor,
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: buttonHeight,
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
                            fontSize: isDesktop ? 18 : 16,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
          if (!isDesktop) SizedBox(height: 24),
        ],
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
    bool isDesktop = false,
  }) {
    final height = isDesktop ? 56.0 : 50.0;
    final fontSize = isDesktop ? 16.0 : 14.0;

    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colorconstants.greycolor),
          hintStyle: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colorconstants.greycolor,
            fontSize: fontSize,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isDesktop ? 16 : 12,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colorconstants.primarycolor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colorconstants.redcolor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colorconstants.redcolor),
          ),
          filled: true,
          fillColor: Colorconstants.greycolor.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorStyle: TextStyle(fontSize: 12),
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
