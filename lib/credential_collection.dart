import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'anti_ragging.dart';

class CredentialCollectionScreen extends StatefulWidget {
  const CredentialCollectionScreen({super.key});

  @override
  State<CredentialCollectionScreen> createState() => _CredentialCollectionScreenState();
}

class _CredentialCollectionScreenState extends State<CredentialCollectionScreen>
    with TickerProviderStateMixin {
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
      isDone = prefs.getBool('credential_collection_done') ?? false;
    });
  }

  Future<void> _setDone(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('credential_collection_done', value);
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
            Text(value ? 'Credential collection marked complete!' : 'Marked as pending'),
          ],
        ),
        backgroundColor: value ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _launchMapUrl(BuildContext context) async {
    const String query = 'IT Office, LNM Institute, Jaipur';
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
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
                      'Credential Collection',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: isDesktop ? 24 : 20,
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
                          Color(0xFFF59E0B),
                          Color(0xFFEAB308),
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

                          // Information Cards
                          AnimatedBuilder(
                            animation: _cardAnimations[1],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - _cardAnimations[1].value)),
                                child: Opacity(
                                  opacity: _cardAnimations[1].value,
                                  child: _buildInfoCards(isDesktop, isTablet),
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

                          // Next Button
                          AnimatedBuilder(
                            animation: _cardAnimations[3],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - _cardAnimations[3].value)),
                                child: Opacity(
                                  opacity: _cardAnimations[3].value,
                                  child: _buildNextButton(isDesktop),
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
            const Color(0xFFF59E0B).withOpacity(0.1),
            const Color(0xFFEAB308).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.2),
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
                colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.badge_rounded,
              size: isDesktop ? 48 : 40,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: isDesktop ? 24 : 20),
          
          // Title
          Text(
            'Collect Your Credentials',
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
            'Collect your LNMIIT email credentials and app login details from the IT Office.',
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

  Widget _buildInfoCards(bool isDesktop, bool isTablet) {
    final items = [
      {
        'icon': Icons.email_rounded,
        'title': 'LNMIIT Email',
        'description': 'Get your official institute email account',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.login_rounded,
        'title': 'App Login',
        'description': 'Receive credentials for mobile app access',
        'color': const Color(0xFF10B981),
      },
    ];

    return isDesktop
        ? Row(
            children: items.map((item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildInfoCard(item, isDesktop),
              ),
            )).toList(),
          )
        : Column(
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildInfoCard(item, isDesktop),
            )).toList(),
          );
  }

  Widget _buildInfoCard(Map<String, dynamic> item, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (item['color'] as Color).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (item['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item['icon'] as IconData,
              color: item['color'] as Color,
              size: isDesktop ? 24 : 20,
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Text(
            item['title'] as String,
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isDesktop ? 8 : 6),
          Text(
            item['description'] as String,
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 14 : 12,
              color: Colors.grey[400],
              height: 1.4,
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
          label: 'Get Directions to IT Office',
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

  Widget _buildNextButton(bool isDesktop) {
    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 56 : 52,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AntiRaggingScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: const Color(0xFFF59E0B).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue to Next Step',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: isDesktop ? 12 : 8),
            Icon(Icons.arrow_forward_rounded, size: isDesktop ? 24 : 20),
          ],
        ),
      ),
    );
  }
}
