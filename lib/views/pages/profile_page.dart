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

  // Responsive breakpoints
  bool get isMobile => MediaQuery.of(context).size.width < 768;
  bool get isTablet =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1024;

  double get maxContentWidth {
    if (isDesktop) return 1200;
    if (isTablet) return 800;
    return double.infinity;
  }

  EdgeInsets get horizontalPadding {
    if (isDesktop) return EdgeInsets.symmetric(horizontal: 32);
    if (isTablet) return EdgeInsets.symmetric(horizontal: 24);
    return EdgeInsets.symmetric(horizontal: 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
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

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: SingleChildScrollView(
                padding: horizontalPadding,
                child: isDesktop
                    ? _buildDesktopLayout(user)
                    : _buildMobileLayout(user),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Profile',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colorconstants.blackcolor,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: !isDesktop,
      actions: [
        Consumer<LoginScreenController>(
          builder: (context, authController, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDesktop) ...[
                  TextButton.icon(
                    onPressed: () async {
                      if (_isEditing) {
                        // Save changes
                        if (_formKey.currentState!.validate()) {
                          await _saveProfile(authController);
                        }
                      } else {
                        setState(() {
                          _isEditing = true;
                        });
                      }
                    },
                    icon: Icon(
                      _isEditing ? Icons.save : Icons.edit,
                      color: Colorconstants.primarycolor,
                    ),
                    label: Text(
                      _isEditing ? 'Save' : 'Edit',
                      style: TextStyle(color: Colorconstants.primarycolor),
                    ),
                  ),
                  SizedBox(width: 8),
                ] else ...[
                  IconButton(
                    onPressed: () async {
                      if (_isEditing) {
                        if (_formKey.currentState!.validate()) {
                          await _saveProfile(authController);
                        }
                      } else {
                        setState(() {
                          _isEditing = true;
                        });
                      }
                    },
                    icon: Icon(
                      _isEditing ? Icons.save : Icons.edit,
                      color: Colorconstants.primarycolor,
                    ),
                  ),
                ],
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(UserModel user) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column - Profile header and photo
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildProfileHeader(user, isDesktopSidebar: true),
                SizedBox(height: 24),
                _buildAccountSettings(),
              ],
            ),
          ),
          SizedBox(width: 32),
          // Right column - Profile form
          Expanded(
            flex: 2,
            child: _buildProfileForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(UserModel user) {
    return Column(
      children: [
        _buildProfileHeader(user),
        SizedBox(height: 16),
        _buildProfileForm(),
        SizedBox(height: 16),
        _buildAccountSettings(),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProfileHeader(UserModel user, {bool isDesktopSidebar = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktopSidebar ? 32 : 24),
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
        children: [
          // Profile Image
          Stack(
            children: [
              CircleAvatar(
                radius: isDesktopSidebar ? 50 : 60,
                backgroundColor: Colorconstants.primarycolor.withOpacity(0.1),
                backgroundImage:
                    user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child: user.photoURL == null
                    ? Icon(
                        Icons.person,
                        size: isDesktopSidebar ? 50 : 60,
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Image upload feature coming soon!'),
                            backgroundColor: Colorconstants.primarycolor,
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
              fontSize: isDesktopSidebar ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colorconstants.blackcolor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              color: Colorconstants.greycolor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
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

            // Personal Info Fields
            if (isDesktop) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildProfileField(
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
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildProfileField(
                      title: 'Email',
                      controller: emailController,
                      icon: Icons.email_outlined,
                      enabled: false,
                    ),
                  ),
                ],
              ),
            ] else ...[
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
              _buildProfileField(
                title: 'Email',
                controller: emailController,
                icon: Icons.email_outlined,
                enabled: false,
              ),
            ],

            _buildProfileField(
              title: 'Phone Number',
              controller: phoneController,
              icon: Icons.phone_outlined,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.isNotEmpty && value.length < 10) {
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

            _buildProfileField(
              title: 'Street Address',
              controller: addressController,
              icon: Icons.home_outlined,
              enabled: _isEditing,
            ),

            // City, State, ZIP Row - responsive layout
            if (isDesktop) ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildProfileField(
                      title: 'City',
                      controller: cityController,
                      icon: Icons.location_city_outlined,
                      enabled: _isEditing,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildProfileField(
                      title: 'State',
                      controller: stateController,
                      icon: Icons.map_outlined,
                      enabled: _isEditing,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildProfileField(
                      title: 'ZIP Code',
                      controller: zipController,
                      icon: Icons.local_post_office_outlined,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ] else ...[
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
              _buildProfileField(
                title: 'ZIP Code',
                controller: zipController,
                icon: Icons.local_post_office_outlined,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
              ),
            ],

            if (_isEditing) ...[
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          final user =
                              context.read<LoginScreenController>().currentUser;
                          _updateControllersFromUser(user);
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colorconstants.greycolor),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colorconstants.blackcolor),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final authController =
                              context.read<LoginScreenController>();
                          await _saveProfile(authController);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colorconstants.primarycolor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  Widget _buildAccountSettings() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Change password feature coming soon!'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notification settings coming soon!'),
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

  Future<void> _saveProfile(LoginScreenController authController) async {
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
