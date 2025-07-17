import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:login_page/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'checklist.dart';

class AntiRaggingScreen extends StatefulWidget {
  const AntiRaggingScreen({super.key});

  @override
  State<AntiRaggingScreen> createState() => _AntiRaggingScreenState();
}

class _AntiRaggingScreenState extends State<AntiRaggingScreen>
    with TickerProviderStateMixin {
  bool allDone = false;
  bool isDone = false;
  
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _loadDoneStatus();
    _checkAllDone();
    _initializeAnimations();
  }

  void _initializeAnimations() {
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
    _cardAnimations = List.generate(5, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardController,
          curve: Interval(
            index * 0.12,
            0.4 + (index * 0.12),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    // Start animations after a delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _fadeController.forward();
          _slideController.forward();
          _cardController.forward();
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

  Future<void> _loadDoneStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDone = prefs.getBool('anti_ragging_done') ?? false;
    });
  }

  Future<void> _checkAllDone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      allDone = (prefs.getBool('hostel_registration_done') ?? false) &&
          (prefs.getBool('document_verification_done') ?? false) &&
          (prefs.getBool('biometric_done') ?? false) &&
          (prefs.getBool('credential_collection_done') ?? false) &&
          (prefs.getBool('anti_ragging_done') ?? false);
    });
  }

  static const String antiRaggingLocation = 'Admin Office, Room 101, LNM Institute, Jaipur';

  Future<void> _launchMapUrl(BuildContext context) async {
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(antiRaggingLocation)}';
    final Uri url = Uri.parse(googleMapsUrl);
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch map';
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not open map: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _setDone(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('anti_ragging_done', value);
    if (!mounted) return;
    
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    setState(() {
      isDone = value;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              value ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(value ? 'Anti-ragging declaration completed!' : 'Marked as pending'),
          ],
        ),
        backgroundColor: value ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    _checkAllDone();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 768 && size.width < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: isDesktop ? 200 : 160,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Final Step - Anti-Ragging',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: isDesktop ? 20 : 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF8B5CF6),
                          Color(0xFFA855F7),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          bottom: -30,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        // Celebration confetti effect if all done
                        if (allDone)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF10B981).withOpacity(0.3),
                                    const Color(0xFF059669).withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Main Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: EdgeInsets.all(isDesktop ? 32 : 24),
                      child: Column(
                        children: [
                          // Hero Section
                          AnimatedBuilder(
                            animation: _cardAnimations[0],
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 0.5 + (_cardAnimations[0].value * 0.5),
                                child: Opacity(
                                  opacity: _cardAnimations[0].value,
                                  child: _buildHeroSection(isDesktop, isTablet),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: isDesktop ? 48 : 32),

                          // Checklist Steps
                          AnimatedBuilder(
                            animation: _cardAnimations[1],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - _cardAnimations[1].value)),
                                child: Opacity(
                                  opacity: _cardAnimations[1].value,
                                  child: _buildStepsCard(isDesktop, isTablet),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: isDesktop ? 40 : 32),

                          // Action Buttons
                          AnimatedBuilder(
                            animation: _cardAnimations[2],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - _cardAnimations[2].value)),
                                child: Opacity(
                                  opacity: _cardAnimations[2].value,
                                  child: _buildActionButtons(isDesktop, isTablet),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: isDesktop ? 40 : 32),

                          // Completion Status
                          if (allDone)
                            AnimatedBuilder(
                              animation: _cardAnimations[3],
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, 30 * (1 - _cardAnimations[3].value)),
                                  child: Opacity(
                                    opacity: _cardAnimations[3].value,
                                    child: _buildCompletionCard(isDesktop),
                                  ),
                                );
                              },
                            ),

                          SizedBox(height: isDesktop ? 40 : 32),

                          // Navigation Button
                          AnimatedBuilder(
                            animation: _cardAnimations[4],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - _cardAnimations[4].value)),
                                child: Opacity(
                                  opacity: _cardAnimations[4].value,
                                  child: _buildNavigationButton(isDesktop),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.1),
            const Color(0xFFA855F7).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.assignment_turned_in_rounded,
              size: isDesktop ? 48 : 40,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: isDesktop ? 24 : 20),
          
          // Title
          Text(
            'Anti-Ragging Declaration',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: isDesktop ? 16 : 12),
          
          // Description
          Text(
            'Complete the final step of your admission process by submitting the anti-ragging declaration form.',
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.grey[300],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard(bool isDesktop, bool isTablet) {
    final steps = [
      {
        'number': '1',
        'title': 'Fill Anti-Ragging Form',
        'description': 'Complete the mandatory anti-ragging declaration form',
        'icon': Icons.edit_document,
      },
      {
        'number': '2',
        'title': 'Collect Student ID Card',
        'description': 'Pick up your official student ID card from Admin Office',
        'icon': Icons.badge_rounded,
      },
    ];

    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Required Steps',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isDesktop ? 24 : 20),
          ...steps.map((step) => _buildStepItem(step, isDesktop)),
        ],
      ),
    );
  }

  Widget _buildStepItem(Map<String, dynamic> step, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          // Step Number
          Container(
            width: isDesktop ? 48 : 40,
            height: isDesktop ? 48 : 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                step['number'] as String,
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          SizedBox(width: isDesktop ? 20 : 16),
          
          // Step Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['title'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isDesktop ? 6 : 4),
                Text(
                  step['description'] as String,
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 14 : 12,
                    color: Colors.grey[400],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDesktop, bool isTablet) {
    return Column(
      children: [
        // Directions Button
        _buildActionButton(
          onPressed: () => _launchMapUrl(context),
          icon: Icons.map_rounded,
          label: 'Get Directions to Admin Office',
          backgroundColor: const Color(0xFF3B82F6),
          isDesktop: isDesktop,
        ),
        
        const SizedBox(height: 16),
        
        // Mark Done Button
        _buildActionButton(
          onPressed: () => _setDone(!isDone),
          icon: isDone ? Icons.cancel_rounded : Icons.check_circle_rounded,
          label: isDone ? 'Mark as Not Done' : 'Mark as Done',
          backgroundColor: isDone ? const Color(0xFFEF4444) : const Color(0xFF10B981),
          isDesktop: isDesktop,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required bool isDesktop,
  }) {
    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 56 : 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: backgroundColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isDesktop ? 24 : 20),
            SizedBox(width: isDesktop ? 12 : 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF059669).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.celebration_rounded,
            size: isDesktop ? 48 : 40,
            color: const Color(0xFF10B981),
          ),
          SizedBox(height: isDesktop ? 20 : 16),
          Text(
            'Congratulations! 🎉',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF10B981),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isDesktop ? 12 : 8),
          Text(
            'You have completed all admission steps successfully!',
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.grey[300],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(bool isDesktop) {
    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 56 : 52,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          if (allDone) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ChecklistScreen()),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: allDone ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: (allDone ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (allDone) ...[
              Text(
                'Finish & Proceed to Login',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: isDesktop ? 12 : 8),
              Icon(Icons.login_rounded, size: isDesktop ? 24 : 20),
            ] else ...[
              Icon(Icons.arrow_back_rounded, size: isDesktop ? 24 : 20),
              SizedBox(width: isDesktop ? 12 : 8),
              Text(
                'Back to Checklist',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}