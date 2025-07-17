import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:login_page/login_page.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  File? _profileImagePicked;
  static const String _imageKey = 'profile_image_path';
  Uint8List? _webImageBytes;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _cardAnimations;

  // Student details
  String? roll;
  String? branch;
  String? batch;
  String? email;
  String? degree;

  final Map<String, String> branchName = {
    'ucs': 'Computer Science and Engineering',
    'ucc': 'Communication and Computer Engineering',
    'uec': 'Electronics and Communication Engineering',
    'ume': 'Mechanical Engineering',
    'dcs': 'Computer Science and Engineering',
    'dec': 'Electronics and Communication Engineering',
  };

  final Map<String, String> degreeType = {
    'ucs': 'B.Tech',
    'ucc': 'B.Tech',
    'uec': 'B.Tech',
    'ume': 'B.Tech',
    'dcs': 'B.Tech - M.Tech (Dual)',
    'dec': 'B.Tech - M.Tech (Dual)',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
    email = FirebaseAuth.instance.currentUser?.email;
    if (email != null) extractUsername(email!);
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Create staggered card animations
    _cardAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardController,
          curve: Interval(
            index * 0.15,
            0.4 + (index * 0.15),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    // Start animations with proper timing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _fadeController.forward();
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) _slideController.forward();
          });
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) _cardController.forward();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void extractUsername(String email) {
    final username = email.split('@').first;
    if (username.length >= 8) {
      roll = username;
      final code = username.substring(2, 5);
      branch = branchName[code];
      degree = degreeType[code];

      final year = int.tryParse(username.substring(0, 2));
      if (year != null) {
        if (branch == 'dec' || branch == 'dcs') {
          batch = '20$year - 20${year + 5}';
        } else {
          batch = '20$year - 20${year + 4}';
        }
      }
    }
  }

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString(_imageKey);
    if (imagePath != null) {
      if (kIsWeb) {
        final imageBytes = base64Decode(imagePath);
        setState(() {
          _webImageBytes = imageBytes;
        });
      } else {
        setState(() {
          _profileImagePicked = File(imagePath);
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_imageKey, base64Encode(bytes));
        setState(() {
          _webImageBytes = bytes;
        });
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_imageKey, pickedFile.path);
        setState(() {
          _profileImagePicked = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 768 && size.width < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : (isTablet ? 32 : 20),
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 48 : 32),
                    _buildProfileCard(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 32 : 24),
                    _buildAcademicInfo(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 32 : 24),
                    _buildActionButtons(isDesktop, isTablet),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isDesktop, bool isTablet) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 32,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 32 : 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Manage your account and preferences',
                style: GoogleFonts.inter(
                  fontSize: isDesktop ? 16 : 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(bool isDesktop, bool isTablet) {
    return AnimatedBuilder(
      animation: _cardAnimations[0],
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimations[0].value,
          child: Opacity(
            opacity: _cardAnimations[0].value,
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 32 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E293B).withOpacity(0.8),
                    const Color(0xFF334155).withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: isDesktop
                  ? Row(
                      children: [
                        _buildProfileImage(isDesktop),
                        const SizedBox(width: 32),
                        Expanded(child: _buildUserInfo(isDesktop)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildProfileImage(isDesktop),
                        const SizedBox(height: 24),
                        _buildUserInfo(isDesktop),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImage(bool isDesktop) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: isDesktop ? 120 : 100,
        height: isDesktop ? 120 : 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _getProfileImage(),
        ),
      ),
    );
  }

  Widget _getProfileImage() {
    if (kIsWeb && _webImageBytes != null) {
      return Image.memory(_webImageBytes!, fit: BoxFit.cover);
    } else if (!kIsWeb && _profileImagePicked != null) {
      return Image.file(_profileImagePicked!, fit: BoxFit.cover);
    } else {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.camera_alt_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
      );
    }
  }

  Widget _buildUserInfo(bool isDesktop) {
    final user = FirebaseAuth.instance.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user?.displayName ?? 'Student',
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        if (roll != null) ...[
          _buildInfoRow(Icons.badge_rounded, 'Roll Number', roll!, const Color(0xFF10B981)),
          const SizedBox(height: 12),
        ],
        _buildInfoRow(Icons.email_rounded, 'Email', user?.email ?? 'Not available', const Color(0xFF3B82F6)),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.verified_user_rounded, 'Status', 'Verified Student', const Color(0xFF8B5CF6)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicInfo(bool isDesktop, bool isTablet) {
    if (branch == null && degree == null && batch == null) return const SizedBox();

    return AnimatedBuilder(
      animation: _cardAnimations[1],
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimations[1].value,
          child: Opacity(
            opacity: _cardAnimations[1].value,
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 24 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E40AF).withOpacity(0.1),
                    const Color(0xFF3B82F6).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 24,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Academic Information',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 20 : 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (degree != null) ...[
                    _buildAcademicRow('Degree', degree!, Icons.military_tech_rounded),
                    const SizedBox(height: 16),
                  ],
                  if (branch != null) ...[
                    _buildAcademicRow('Branch', branch!, Icons.engineering_rounded),
                    const SizedBox(height: 16),
                  ],
                  if (batch != null) ...[
                    _buildAcademicRow('Batch', batch!, Icons.calendar_today_rounded),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAcademicRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDesktop, bool isTablet) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _cardAnimations[2],
          builder: (context, child) {
            return Transform.scale(
              scale: _cardAnimations[2].value,
              child: Opacity(
                opacity: _cardAnimations[2].value,
                child: _buildActionButton(
                  'Change Profile Picture',
                  'Update your profile image',
                  Icons.camera_alt_rounded,
                  const Color(0xFF10B981),
                  _pickImage,
                  isDesktop,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _cardAnimations[3],
          builder: (context, child) {
            return Transform.scale(
              scale: _cardAnimations[3].value,
              child: Opacity(
                opacity: _cardAnimations[3].value,
                child: _buildActionButton(
                  'Sign Out',
                  'Logout from your account',
                  Icons.logout_rounded,
                  const Color(0xFFEF4444),
                  _signOut,
                  isDesktop,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDesktop,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 20 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}