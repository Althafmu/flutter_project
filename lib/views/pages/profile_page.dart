import 'package:flutter/material.dart';
import 'package:flutter_project/data/services/auth_services.dart';
import 'package:flutter_project/utils/colorconstants.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  // Controllers for form fields
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController zipController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginScreenController>().getCurrentUser();
    });
  }

  void _initializeControllers() {
    final authController = context.read<LoginScreenController>();
    final user = authController.currentUser;

    nameController = TextEditingController(text: user?.name ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    phoneController = TextEditingController(text: user?.phone ?? '');
    addressController = TextEditingController(text: user?.address ?? '');
    cityController = TextEditingController(text: user?.city ?? '');
    stateController = TextEditingController(text: user?.state ?? '');
    zipController = TextEditingController(text: user?.zipCode ?? '');
  }

  void _updateControllersFromUser(UserModel? user) {
    if (user != null) {
      nameController.text = user.name;
      emailController.text = user.email;
      phoneController.text = user.phone;
      addressController.text = user.address;
      cityController.text = user.city;
      stateController.text = user.state;
      zipController.text = user.zipCode;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colorconstants.blackcolor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<LoginScreenController>(
            builder: (context, authController, child) {
              return IconButton(
                onPressed: () async {
                  if (_isEditing) {
                    // Save changes
                    if (_formKey.currentState!.validate()) {
                      Map<String, String> userData = {
                        'name': nameController.text,
                        'phone': phoneController.text,
                        'address': addressController.text,
                        'city': cityController.text,
                        'state': stateController.text,
                        'zipCode': zipController.text,
                      };

                      bool success = await authController.updateUserProfile(
                        userData: userData,
                        context: context,
                      );

                      if (success) {
                        setState(() {
                          _isEditing = false;
                        });
                      }
                    }
                  } else {
                    // Start editing
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
                icon: Icon(
                  _isEditing ? Icons.save : Icons.edit,
                  color: Colorconstants.primarycolor,
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<LoginScreenController>(
        builder: (context, authController, child) {
          final user = authController.currentUser;

          if (user == null) {
            return Center(
              child: CircularProgressIndicator(
                color: Colorconstants.primarycolor,
              ),
            );
          }

          // Update controllers when user data changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateControllersFromUser(user);
          });

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile Image
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor:
                                Colorconstants.primarycolor.withOpacity(0.1),
                            backgroundImage: user.photoURL != null
                                ? NetworkImage(user.photoURL!)
                                : null,
                            child: user.photoURL == null
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colorconstants.primarycolor,
                                  )
                                : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colorconstants.primarycolor,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    // TODO: Implement image picker
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Image upload feature coming soon!'),
                                        backgroundColor:
                                            Colorconstants.primarycolor,
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colorconstants.blackcolor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colorconstants.greycolor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colorconstants.primarycolor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Member since ${_formatDate(user.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colorconstants.primarycolor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Profile Information Form
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colorconstants.blackcolor,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Name Field
                        _buildProfileField(
                          title: 'Full Name',
                          controller: nameController,
                          icon: Icons.person_outline,
                          enabled: _isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),

                        // Email Field (Read-only)
                        _buildProfileField(
                          title: 'Email',
                          controller: emailController,
                          icon: Icons.email_outlined,
                          enabled: false, // Email should not be editable
                        ),

                        // Phone Field
                        _buildProfileField(
                          title: 'Phone Number',
                          controller: phoneController,
                          icon: Icons.phone_outlined,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                value.length < 10) {
                              return 'Phone number must be at least 10 digits';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 24),
                        Text(
                          'Address Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colorconstants.blackcolor,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Address Field
                        _buildProfileField(
                          title: 'Street Address',
                          controller: addressController,
                          icon: Icons.home_outlined,
                          enabled: _isEditing,
                        ),

                        // City and State Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildProfileField(
                                title: 'City',
                                controller: cityController,
                                icon: Icons.location_city_outlined,
                                enabled: _isEditing,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildProfileField(
                                title: 'State',
                                controller: stateController,
                                icon: Icons.map_outlined,
                                enabled: _isEditing,
                              ),
                            ),
                          ],
                        ),

                        // ZIP Code Field
                        _buildProfileField(
                          title: 'ZIP Code',
                          controller: zipController,
                          icon: Icons.local_post_office_outlined,
                          enabled: _isEditing,
                          keyboardType: TextInputType.number,
                        ),

                        if (_isEditing) ...[
                          SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = false;
                                      _updateControllersFromUser(user);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    foregroundColor: Colorconstants.blackcolor,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('Cancel'),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      Map<String, String> userData = {
                                        'name': nameController.text,
                                        'phone': phoneController.text,
                                        'address': addressController.text,
                                        'city': cityController.text,
                                        'state': stateController.text,
                                        'zipCode': zipController.text,
                                      };

                                      bool success = await authController
                                          .updateUserProfile(
                                        userData: userData,
                                        context: context,
                                      );

                                      if (success) {
                                        setState(() {
                                          _isEditing = false;
                                        });
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colorconstants.primarycolor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('Save Changes'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Account Actions
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colorconstants.blackcolor,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildAccountAction(
                        title: 'Change Password',
                        subtitle: 'Update your account password',
                        icon: Icons.lock_outline,
                        onTap: () {
                          // TODO: Implement change password
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Change password feature coming soon!'),
                              backgroundColor: Colorconstants.primarycolor,
                            ),
                          );
                        },
                      ),
                      Divider(height: 32),
                      _buildAccountAction(
                        title: 'Notification Settings',
                        subtitle: 'Manage your notification preferences',
                        icon: Icons.notifications_outlined,
                        onTap: () {
                          // TODO: Implement notification settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Notification settings coming soon!'),
                              backgroundColor: Colorconstants.primarycolor,
                            ),
                          );
                        },
                      ),
                      Divider(height: 32),
                      _buildAccountAction(
                        title: 'Delete Account',
                        subtitle: 'Permanently delete your account',
                        icon: Icons.delete_outline,
                        textColor: Colors.red,
                        onTap: () {
                          _showDeleteAccountDialog();
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileField({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colorconstants.blackcolor,
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: enabled
                    ? Colorconstants.greycolor
                    : Colorconstants.greycolor.withOpacity(0.5),
              ),
              filled: true,
              fillColor: enabled
                  ? Colorconstants.greycolor.withOpacity(0.1)
                  : Colorconstants.greycolor.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colorconstants.primarycolor),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
            style: TextStyle(
              color: enabled
                  ? Colorconstants.blackcolor
                  : Colorconstants.greycolor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? Colorconstants.greycolor,
              size: 24,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? Colorconstants.blackcolor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colorconstants.greycolor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colorconstants.greycolor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<LoginScreenController>().signOut(context);
              },
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Account',
            style: TextStyle(color: Colors.red),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement account deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Account deletion feature coming soon!'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
