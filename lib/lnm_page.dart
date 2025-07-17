import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'pages/impContacts.dart';
import 'pages/hods.dart';
import 'pages/hostelContacts.dart';
import 'pages/impLinks.dart';
import 'pages/curriculum.dart';

class LNMPage extends StatefulWidget {
  const LNMPage({super.key});

  @override
  State<LNMPage> createState() => _LNMPageState();
}

class _LNMPageState extends State<LNMPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _cardAnimations;

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
    _cardAnimations = List.generate(6, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardController,
          curve: Interval(
            index * 0.1,
            0.6 + (index * 0.1),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _cardController.dispose();
    super.dispose();
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
                    _buildHeroSection(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 64 : 48),
                    _buildFacultiesSection(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 64 : 48),
                    _buildMiscellaneousSection(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 64 : 48),
                    _buildDirectorMessageSection(isDesktop, isTablet),
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

  Widget _buildHeroSection(bool isDesktop, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 48 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
            Color(0xFF1E40AF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.school_rounded,
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
                      'LNMIIT Campus',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 32 : 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Your comprehensive campus guide',
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 16 : 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Access all campus information, contacts, and essential resources in one place.',
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFacultiesSection(bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Faculty Information',
          'Connect with faculty members and departments',
          Icons.people_rounded,
        ),
        _buildModernCardGrid([
          _CardData('Important Contacts', 'Essential campus contacts and phone numbers', Icons.contact_phone_rounded, const Color(0xFF10B981), () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => const ImportantContactsPage(),
            ));
          }),
          _CardData('HODs', 'Heads of Departments contact information', Icons.person_rounded, const Color(0xFF8B5CF6), () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => HODsPage(),
            ));
          }),
          _CardData('Hostel Contacts', 'Hostel wardens and staff contacts', Icons.home_rounded, const Color(0xFFF59E0B), () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => const HostelPage(),
            ));
          }),
        ], isDesktop, isTablet, 0),
      ],
    );
  }

  Widget _buildMiscellaneousSection(bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Campus Resources',
          'Maps, curriculum, and essential links',
          Icons.explore_rounded,
        ),
        _buildModernCardGrid([
          _CardData('Campus Map', 'Interactive campus location guide', Icons.map_rounded, const Color(0xFFEF4444), () async {
            const url = 'https://lnmiit.ac.in/campus-map/';
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open campus map')),
              );
            }
          }),
          _CardData('Academic Area Map', 'Navigate academic buildings and facilities', Icons.school_rounded, const Color(0xFF06B6D4), () async {
            const url = 'https://lnmiit.ac.in/campus-map/';
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open academic map')),
              );
            }
          }),
          _CardData('Curriculum', 'Course curriculum and academic structure', Icons.book_rounded, const Color(0xFF8B5CF6), () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => const CurriculumPage(),
            ));
          }),
          _CardData('Important Links', 'Quick access to essential online resources', Icons.link_rounded, const Color(0xFF10B981), () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => const LinksPage(),
            ));
          }),
        ], isDesktop, isTablet, 3),
      ],
    );
  }

  Widget _buildDirectorMessageSection(bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Director\'s Message',
          'Welcome message from Prof. Rahul Banerjee',
          Icons.message_rounded,
        ),
        Container(
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: isDesktop ? 80 : 60,
                    height: isDesktop ? 80 : 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                      ),
                      image: const DecorationImage(
                        image: AssetImage('assets/pages/faces/rahul_banerjee_2.jpg'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isDesktop ? 20 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prof. Rahul Banerjee',
                          style: GoogleFonts.poppins(
                            fontSize: isDesktop ? 24 : 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Director, LNMIIT',
                          style: GoogleFonts.inter(
                            fontSize: isDesktop ? 16 : 14,
                            color: const Color(0xFF3B82F6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome Message',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to The LNM Institute of Information Technology (LNMIIT), Jaipur! The LNMIIT is an institution of higher learning focused in select areas of Computing, Communication, ICT, Electronics and carefully chosen traditional engineering and sciences with an innovative blend of interdisciplinary flavor and contemporary relevance.',
                style: GoogleFonts.inter(
                  fontSize: isDesktop ? 16 : 14,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'The Institute, in spite of being young (founded in 2002, jointly by the Government of Rajasthan and the Lakshmi & Usha Mittal Foundation in the public-private partnership mode) is considered as one of the best institutions in its chosen areas of higher learning, both in the state and the country.',
                style: GoogleFonts.inter(
                  fontSize: isDesktop ? 16 : 14,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'The Institute takes pride in its eco-system that aims to groom incoming students into academically strong yet well-rounded personality based professionals who could adapt themselves to the challenges posed by the ever-changing world and working environments.',
                style: GoogleFonts.inter(
                  fontSize: isDesktop ? 16 : 14,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernCardGrid(List<_CardData> cards, bool isDesktop, bool isTablet, int startIndex) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
        childAspectRatio: isDesktop ? 1.2 : (isTablet ? 1.1 : 1.3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return AnimatedBuilder(
          animation: _cardAnimations[startIndex + index],
          builder: (context, child) {
            return Transform.scale(
              scale: _cardAnimations[startIndex + index].value,
              child: Opacity(
                opacity: _cardAnimations[startIndex + index].value,
                child: _buildModernCard(card, isDesktop),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernCard(_CardData card, bool isDesktop) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        card.onTap();
      },
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 24 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              card.color.withOpacity(0.1),
              card.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: card.color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: card.color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: card.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                card.icon,
                size: 24,
                color: card.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              card.title,
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              card.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  'Explore',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: card.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: card.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _CardData(this.title, this.description, this.icon, this.color, this.onTap);
}