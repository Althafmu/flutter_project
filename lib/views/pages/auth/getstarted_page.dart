import 'package:flutter/material.dart';
import 'package:flutter_project/utils/colorconstants.dart';
import 'package:flutter_project/utils/image_constants.dart';
import 'package:flutter_project/views/pages/auth/login_page.dart';
import 'package:flutter_project/views/pages/auth/signup_page.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticInOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _bounceController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildResponsiveLayout(context),
    );
  }

  Widget _buildResponsiveLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    if (isDesktop) {
      return _buildDesktopLayout(context);
    } else if (isTablet) {
      return _buildTabletLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Container(
      decoration: _buildGradientBackground(),
      child: Row(
        children: [
          // Left side - Hero content
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroContent(context, isDesktop: true),
                  const SizedBox(height: 60),
                  _buildActionButtons(context, isDesktop: true),
                ],
              ),
            ),
          ),
          // Right side - Features
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(60),
              child: _buildFeaturesList(context, isDesktop: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Container(
      decoration: _buildGradientBackground(),
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              _buildHeroContent(context, isTablet: true),
              const SizedBox(height: 60),
              _buildFeaturesList(context, isTablet: true),
              const SizedBox(height: 60),
              _buildActionButtons(context, isTablet: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Container(
      decoration: _buildGradientBackground(),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildHeroContent(context),
                const SizedBox(height: 80),
                _buildActionButtons(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colorconstants.primarycolor.withOpacity(0.08),
          Colors.white,
          Colors.orange.withOpacity(0.05),
          Colorconstants.primarycolor.withOpacity(0.03),
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context,
      {bool isDesktop = false, bool isTablet = false}) {
    final titleSize = isDesktop ? 52.0 : (isTablet ? 40.0 : 36.0);
    final subtitleSize = isDesktop ? 22.0 : (isTablet ? 20.0 : 18.0);
    final descriptionSize = isDesktop ? 18.0 : (isTablet ? 16.0 : 14.0);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment:
              isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            // Shopping bag icon with animation
            ScaleTransition(
              scale: _bounceAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colorconstants.primarycolor.withOpacity(0.15),
                      Colors.orange.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colorconstants.primarycolor.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: isDesktop ? 65 : (isTablet ? 55 : 45),
                  color: Colorconstants.primarycolor,
                ),
              ),
            ),
            const SizedBox(height: 35),
            // Main Title with gradient text effect
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colorconstants.primarycolor,
                  Colors.orange,
                ],
              ).createShader(bounds),
              child: Text(
                'Welcome to BuyIt',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: isDesktop ? TextAlign.left : TextAlign.center,
              ),
            ),
            const SizedBox(height: 18),
            // Subtitle
            Text(
              'Shop Smart, Shop Easy',
              style: TextStyle(
                fontSize: subtitleSize,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
            ),
            const SizedBox(height: 26),
            // Description
            Text(
              'Discover millions of products at unbeatable prices. From electronics to fashion, home essentials to trending gadgets - find everything you need in one place with fast delivery and secure payments.',
              style: TextStyle(
                fontSize: descriptionSize,
                color: Colorconstants.greycolor.withOpacity(0.8),
                height: 1.6,
              ),
              textAlign: isDesktop ? TextAlign.left : TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Stats row
            _buildStatsRow(isDesktop, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(bool isDesktop, bool isTablet) {
    final stats = [
      {'number': '10M+', 'label': 'Products'},
      {'number': '5M+', 'label': 'Happy Customers'},
      {'number': '200+', 'label': 'Categories'},
    ];

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment:
            isDesktop ? MainAxisAlignment.start : MainAxisAlignment.spaceEvenly,
        children: stats.map((stat) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 8),
            child: Column(
              children: [
                Text(
                  stat['number']!,
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
                    fontWeight: FontWeight.bold,
                    color: Colorconstants.primarycolor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['label']!,
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : (isTablet ? 12 : 11),
                    color: Colorconstants.greycolor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context,
      {bool isDesktop = false, bool isTablet = false}) {
    final features = [
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'Free Delivery',
        'description': 'Free shipping on orders over \$50 with fast delivery',
      },
      {
        'icon': Icons.security_outlined,
        'title': 'Secure Payments',
        'description': 'Safe and secure payment methods with buyer protection',
      },
      {
        'icon': Icons.assignment_return_outlined,
        'title': 'Easy Returns',
        'description': '30-day hassle-free returns and exchange policy',
      },
      {
        'icon': Icons.support_agent_outlined,
        'title': '24/7 Support',
        'description': 'Round-the-clock customer support for all your needs',
      },
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop)
            Text(
              'Why Shop With BuyIt?',
              style: TextStyle(
                fontSize: isTablet ? 26 : 22,
                fontWeight: FontWeight.bold,
                color: Colorconstants.blackcolor,
              ),
              textAlign: TextAlign.center,
            ),
          if (!isDesktop) const SizedBox(height: 30),
          if (isDesktop)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 4,
                mainAxisSpacing: 20,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                return _buildFeatureCard(features[index], isDesktop: true);
              },
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 2 : 1,
                childAspectRatio: isTablet ? 1.5 : 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                return _buildFeatureCard(features[index], isTablet: isTablet);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature,
      {bool isDesktop = false, bool isTablet = false}) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colorconstants.greycolor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colorconstants.primarycolor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: isDesktop
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colorconstants.primarycolor.withOpacity(0.15),
                        Colors.orange.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    feature['icon'],
                    size: 32,
                    color: Colorconstants.primarycolor,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        feature['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colorconstants.blackcolor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feature['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colorconstants.greycolor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colorconstants.primarycolor.withOpacity(0.15),
                        Colors.orange.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    feature['icon'],
                    size: isTablet ? 36 : 32,
                    color: Colorconstants.primarycolor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  feature['title'],
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colorconstants.blackcolor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  feature['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colorconstants.greycolor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  Widget _buildActionButtons(BuildContext context,
      {bool isDesktop = false, bool isTablet = false}) {
    final buttonHeight = isDesktop ? 58.0 : (isTablet ? 54.0 : 52.0);
    final fontSize = isDesktop ? 18.0 : (isTablet ? 16.0 : 16.0);

    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: _buildPrimaryButton(
                    context,
                    'Start Shopping',
                    () => _navigateToSignup(context),
                    height: buttonHeight,
                    fontSize: fontSize,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildSecondaryButton(
                    context,
                    'Sign In',
                    () => _navigateToLogin(context),
                    height: buttonHeight,
                    fontSize: fontSize,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildPrimaryButton(
                  context,
                  'Start Shopping Now',
                  () => _navigateToSignup(context),
                  height: buttonHeight,
                  fontSize: fontSize,
                ),
                const SizedBox(height: 16),
                _buildSecondaryButton(
                  context,
                  'Already have an account? Sign In',
                  () => _navigateToLogin(context),
                  height: buttonHeight,
                  fontSize: fontSize,
                ),
              ],
            ),
          const SizedBox(height: 4),
          // Terms and Privacy
          Text(
            'By continuing, you agree to our Terms of Service and Privacy Policy',
            style: TextStyle(
              fontSize: 12,
              color: Colorconstants.greycolor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    String text,
    VoidCallback onTap, {
    required double height,
    required double fontSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colorconstants.primarycolor,
              Colors.orange.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colorconstants.primarycolor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: fontSize,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                  color: Colorconstants.whitecolor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    String text,
    VoidCallback onTap, {
    required double height,
    required double fontSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colorconstants.primarycolor,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              color: Colorconstants.primarycolor,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSignup(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignupScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
