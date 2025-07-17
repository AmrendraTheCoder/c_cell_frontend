import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login_page/cosha.dart';
import 'package:login_page/cultural.dart';
import 'package:login_page/fest_card.dart';
import 'package:login_page/sports.dart';
import 'package:login_page/technology.dart';
import 'package:url_launcher/url_launcher.dart';

class GymkhanaPage extends StatefulWidget {
  const GymkhanaPage({super.key});

  @override
  State<GymkhanaPage> createState() => _GymkhanaPageState();
}

class _GymkhanaPageState extends State<GymkhanaPage> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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
                  horizontal: isDesktop ? 48 : (isTablet ? 32 : 16),
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    _buildHeroSection(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 64 : 48),
                    _buildLeadershipSection(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 64 : 48),
                    _buildCouncilsSection(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 64 : 48),
                    _buildStudentEventsSection(isDesktop, isTablet),
                    SizedBox(height: 40),
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
            Color(0xFF1E40AF),
            Color(0xFF3B82F6),
            Color(0xFF60A5FA),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
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
                  Icons.account_balance_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'STUDENT GYMKHANA',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isDesktop ? 42 : (isTablet ? 36 : 28),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "The Students' Gymkhana is the official student-governing body of The LNMIIT, Jaipur, dedicated to representing and advancing the interests of the student community. Established in 2006, it plays a vital role in nurturing leadership, promoting dialogue, and building a participatory campus culture.",
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.9),
              fontSize: isDesktop ? 16 : 14,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeadershipSection(bool isDesktop, bool isTablet) {
    return Column(
      children: [
        _buildSectionHeader('LEADERSHIP TEAM', Icons.person_rounded, isDesktop),
        const SizedBox(height: 32),
        Column(
          children: [
            enhancedPresidentTile(
              "Mr. Vaibhav Khamesra",
              "President",
              "7023659757",
              "gym.president@lnmiit.ac.in",
              const Color(0xFFEF4444),
              isDesktop,
            ),
            const SizedBox(height: 16),
            enhancedPresidentTile(
              "Mr. Chirag Mehta",
              "Vice-President",
              "",
              "gym.vicepresident@lnmiit.ac.in",
              const Color(0xFF3B82F6),
              isDesktop,
            ),
            const SizedBox(height: 16),
            enhancedPresidentTile(
              "Mr. Jalaj Rastogi",
              "Finance Convener",
              "8077054850",
              "gym.financeconvenor@lnmiit.ac.in",
              const Color(0xFF10B981),
              isDesktop,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCouncilsSection(bool isDesktop, bool isTablet) {
    return Column(
      children: [
        _buildSectionHeader('PRESIDENTIAL COUNCIL', Icons.groups_rounded, isDesktop),
        const SizedBox(height: 32),
        _buildResponsiveGrid(
          isDesktop: isDesktop,
          isTablet: isTablet,
          children: [
            enhancedSquareCard(
              "Cultural Council",
              'assets/images/ccell_logo.png',
              const CulturalCouncil(),
              const Color(0xFFEC4899),
              "Creativity & Arts",
              isDesktop,
            ),
            enhancedSquareCard(
              "Science & Technology Council",
              'assets/images/tech_logo.jpg',
              const TechnologyCouncil(),
              const Color(0xFF8B5CF6),
              "Innovation & Tech",
              isDesktop,
            ),
            enhancedSquareCard(
              "Sports Council",
              'assets/images/sports_logo.jpg',
              const SportsCouncil(),
              const Color(0xFF06B6D4),
              "Athletics & Wellness",
              isDesktop,
            ),
            enhancedSquareCard(
              "COSHA Committee",
              "assets/images/cosha_logo.jpg",
              COSHAScreen(),
              const Color(0xFFF59E0B),
              "Student Welfare",
              isDesktop,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentEventsSection(bool isDesktop, bool isTablet) {
    return Column(
      children: [
        _buildSectionHeader('STUDENT FESTIVALS', Icons.celebration_rounded, isDesktop),
        const SizedBox(height: 32),
        _buildResponsiveGrid(
          isDesktop: isDesktop,
          isTablet: isTablet,
          children: [
            enhancedEventCard(
              "Desportivos",
              "assets/images/despo/despo_logo.jpeg",
              const StudentEventScreen(
                imageUrl: "assets/images/despo/despo_logo.jpeg",
                description: "Desportivos is the flagship annual sports festival of LNMIIT...",
                festHeads: [],
                galleryImages: [],
                instaUrl: '',
                emailUrl: "",
                youtubeUrl: "",
                linkedinUrl: "",
                facebookUrl: "",
                xUrl: "",
                label: "Desportivos",
              ),
              const Color(0xFF059669),
              "Sports Festival",
              isDesktop,
            ),
            enhancedEventCard(
              "TEDX LNMIIT",
              'assets/images/ted_logo.jpg',
              const StudentEventScreen(
                imageUrl: "assets/images/ted_logo.jpg",
                description: "TEDxLNMIIT brings the global spirit of TED's ideas worth spreading...",
                festHeads: [],
                galleryImages: [],
                instaUrl: '',
                emailUrl: "",
                youtubeUrl: "",
                linkedinUrl: "",
                facebookUrl: "",
                xUrl: "",
                label: "TEDx LNMIIT",
              ),
              const Color(0xFFDC2626),
              "Ideas Worth Spreading",
              isDesktop,
            ),
            enhancedEventCard(
              "E-Summit",
              'assets/images/esummit_logo.jpg',
              const StudentEventScreen(
                imageUrl: "assets/images/esummit_logo.jpg",
                description: "E-Summit is LNMIIT Jaipur's flagship celebration of entrepreneurship...",
                festHeads: [],
                galleryImages: [],
                instaUrl: '',
                emailUrl: "",
                youtubeUrl: "",
                linkedinUrl: "",
                facebookUrl: "",
                xUrl: "",
                label: "E-Summit",
              ),
              const Color(0xFF7C3AED),
              "Entrepreneurship",
              isDesktop,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDesktop) {
    return Row(
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
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isDesktop ? 28 : 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveGrid({
    required bool isDesktop,
    required bool isTablet,
    required List<Widget> children,
  }) {
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isDesktop ? 0.85 : 0.8,
        crossAxisSpacing: isDesktop ? 24 : 16,
        mainAxisSpacing: isDesktop ? 24 : 16,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

Widget enhancedSquareCard(
  String title,
  String imageUrl,
  Widget targetScreen,
  Color accentColor,
  String subtitle,
  bool isDesktop,
) {
  return Material(
    elevation: 0,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        // Navigation implementation
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E293B),
              const Color(0xFF0F172A),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.1),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: CircleAvatar(
                radius: isDesktop ? 32 : 28,
                backgroundImage: AssetImage(imageUrl),
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: isDesktop ? 16 : 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: accentColor.withOpacity(0.8),
                fontSize: isDesktop ? 12 : 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget enhancedEventCard(
  String title,
  String imageUrl,
  Widget targetScreen,
  Color accentColor,
  String category,
  bool isDesktop,
) {
  return Material(
    elevation: 0,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        // Navigation implementation
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withOpacity(0.1),
              accentColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.event_rounded,
                color: accentColor,
                size: isDesktop ? 32 : 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: isDesktop ? 16 : 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: GoogleFonts.inter(
                  color: accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget enhancedPresidentTile(
  String name,
  String post,
  String phoneUrl,
  String mailUrl,
  Color accentColor,
  bool isDesktop,
) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1E293B),
          const Color(0xFF0F172A),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
      boxShadow: [
        BoxShadow(
          color: accentColor.withOpacity(0.1),
          blurRadius: 12,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: isDesktop ? 16 : 12,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.person_rounded,
          color: accentColor,
          size: 24,
        ),
      ),
      title: Text(
        name,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: isDesktop ? 16 : 14,
        ),
      ),
      subtitle: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          post,
          style: GoogleFonts.inter(
            color: accentColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (phoneUrl.isNotEmpty)
            _buildActionButton(
              Icons.phone_rounded,
              const Color(0xFF10B981),
              () => _launchPhone(phoneUrl),
            ),
          const SizedBox(width: 8),
          _buildActionButton(
            Icons.email_rounded,
            const Color(0xFF3B82F6),
            () => _launchEmail(mailUrl),
          ),
        ],
      ),
    ),
  );
}

Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
  return Material(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: 18),
      ),
    ),
  );
}

// Launcher functions remain the same
void _launchPhone(String phone) async {
  final Uri uri = Uri.parse('tel:$phone');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

void _launchEmail(String email) async {
  final Uri uri = Uri(scheme: 'mailto', path: email);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
