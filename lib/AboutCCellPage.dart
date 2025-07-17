import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login_page/convenerMessage.dart';
import 'member.dart';

class AboutCCellPage extends StatelessWidget {
  const AboutCCellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Modern Header Section
            _buildHeaderSection(),
            
            const SizedBox(height: 32),
            
            // Institution Info
            _buildInstitutionInfo(),
            
            const SizedBox(height: 40),
            
            // Mission Statement
            _buildMissionStatement(),
            
            const SizedBox(height: 48),
            
            // Team Sections
            _buildTeamSection(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
            Color(0xFFA855F7),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                image: DecorationImage(
                  image: const AssetImage('assets/images/y24.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.overlay,
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // C-Cell Logo
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    backgroundImage: const AssetImage('assets/images/ccell_logo_c.png'),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Counseling Cell',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'LNMIIT Student Support System',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstitutionInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF6366F1),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'The LNM Institute of Information Technology',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'A premier institution dedicated to excellence in technical education and research, fostering innovation and holistic development of students.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF64748B),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionStatement() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF1F5F9),
              Color(0xFFE2E8F0),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Our Mission',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'The Counseling Cell at LNMIIT fosters mental well-being and provides comprehensive support through peer mentorship, professional guidance, and proactive outreach initiatives. We are committed to creating a supportive environment where every student can thrive academically, emotionally, and socially.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF475569),
                height: 1.7,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Mission Points
            _buildMissionPoint(
              icon: Icons.support_agent_rounded,
              title: 'Professional Support',
              description: 'Expert counseling and guidance services',
            ),
            
            const SizedBox(height: 16),
            
            _buildMissionPoint(
              icon: Icons.groups_rounded,
              title: 'Peer Mentorship',
              description: 'Student-to-student support networks',
            ),
            
            const SizedBox(height: 16),
            
            _buildMissionPoint(
              icon: Icons.campaign_rounded,
              title: 'Proactive Outreach',
              description: 'Awareness programs and workshops',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionPoint({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6366F1),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection() {
    return Column(
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Our Team',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Coordinators Y-23
        _buildModernMemberSection(
          title: "Coordinators Y-23",
          icon: Icons.stars_rounded,
          color: const Color(0xFF6366F1),
          members: [
            Member(
              name: "Aditya Kansal",
              imagePath: 'assets/images/aditya_kansal.webp',
              email: '23ucc506@lnmiit.ac.in',
              phone: '7037898300',
            ),
            Member(
              name: "Kunal Sharma",
              imagePath: 'assets/images/kunal_sharma.png',
              email: '23uec563@lnmiit.ac.in',
              phone: '9166405904',
            ),
            Member(
              name: "Neha Raniwala",
              imagePath: 'assets/images/neha_raniwala.jpg',
              email: '23ucc577@lnmiit.ac.in',
              phone: '8982919670',
            ),
          ],
        ),
        
        const SizedBox(height: 40),
        
        // Associate Coordinators Y-23
        _buildModernMemberSection(
          title: "Associate Coordinators Y-23",
          icon: Icons.group_work_rounded,
          color: const Color(0xFF8B5CF6),
          members: [
            Member(
              name: "Atharv Shah",
              imagePath: 'assets/images/atharv_shah.jpg',
              email: '23ucc525@lnmiit.ac.in',
              phone: '9315394135',
            ),
            Member(
              name: "Lakshita Sharma",
              imagePath: 'assets/images/lakshita.jpeg',
              email: '23ume529@lnmiit.ac.in',
              phone: '7877045043',
            ),
            Member(
              name: "Mudit Choudhary",
              imagePath: 'assets/images/mudit_img.jpg',
              email: '23ucc623@lnmiit.ac.in',
              phone: '9672467580',
            ),
            Member(
              name: "Rahul Sharma",
              imagePath: 'assets/images/rahul_sharma.jpg',
              email: '23ucs686@lnmiit.ac.in',
              phone: '9899007236',
            ),
            Member(
              name: "Vibha Gupta",
              imagePath: 'assets/images/vibha_gupta.jpg',
              email: '23uec642@lnmiit.ac.in',
              phone: '7976737262',
            ),
            Member(
              name: "Yash Raj",
              imagePath: 'assets/images/yash_raj.jpg',
              email: '23ucc619@lnmiit.ac.in',
              phone: '8291508341',
            ),
          ],
        ),
        
        const SizedBox(height: 40),
        
        // Team Mentors Y-22
        _buildSimpleTeamSection(
          title: "Team Mentors Y-22",
          icon: Icons.school_rounded,
          color: const Color(0xFFEF4444),
          members: [
            "Harshita Sharma",
            "Arpit Joshi", 
            "Naman Agarwal",
          ],
          imagePaths: [
            'assets/images/Harshita.jpg',
            'assets/images/arpit_joshi.jpg',
            'assets/images/naman.jpg',
          ],
        ),
        
        const SizedBox(height: 40),
        
        // Convener Message Section
        convenerMessageSection(),
        
        const SizedBox(height: 40),
        
        // App Developers
        _buildDeveloperSection(),
      ],
    );
  }

  Widget _buildModernMemberSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Member> members,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Members Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    return _buildModernMemberCard(members[index], color);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernMemberCard(Member member, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profile Image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(member.imagePath),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Name
          Text(
            member.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Contact Info
          if (member.email.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Contact Available',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSimpleTeamSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> members,
    required List<String> imagePaths,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Members Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(members.length, (index) {
                return _buildSimpleMemberCard(
                  members[index],
                  imagePaths[index],
                  color,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleMemberCard(String name, String imagePath, Color accentColor) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage(imagePath),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.code_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'App Developers',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Developers Grid
            _buildDeveloperGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperGrid() {
    final developers = [
      {'name': 'Mudit Choudhary', 'image': 'assets/images/mudit_img.jpg'},
      {'name': 'Yash Raj', 'image': 'assets/images/yash_raj.jpg'},
      {'name': 'Praneel Dev', 'image': 'assets/images/praneel.jpg'},
      {'name': 'Nikhila S Hari', 'image': 'assets/images/nikhila.jpg'},
      {'name': 'Panth Moradia', 'image': 'assets/images/panth_moradiya.jpg'},
      {'name': 'Ishita Agarwal', 'image': 'assets/images/ishita.jpg'},
      {'name': 'Armaan Jain', 'image': 'assets/images/armaan.png'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: developers.length,
          itemBuilder: (context, index) {
            return _buildDeveloperCard(
              developers[index]['name']!,
              developers[index]['image']!,
            );
          },
        );
      },
    );
  }

  Widget _buildDeveloperCard(String name, String imagePath) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage(imagePath),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
