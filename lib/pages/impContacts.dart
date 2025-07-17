import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class ImportantContactsPage extends StatefulWidget {
  const ImportantContactsPage({super.key});

  @override
  State<ImportantContactsPage> createState() => _ImportantContactsPageState();
}

class _ImportantContactsPageState extends State<ImportantContactsPage> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _listController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _listAnimations;

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
    
    _listController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Create staggered animations for contact cards
    _listAnimations = List.generate(10, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _listController,
          curve: Interval(
            index * 0.1,
            0.3 + (index * 0.1),
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
            if (mounted) _listController.forward();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _listController.dispose();
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildModernAppBar(isDesktop, isTablet),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 48 : (isTablet ? 32 : 20),
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(isDesktop, isTablet),
                        SizedBox(height: isDesktop ? 48 : 32),
                        ..._buildContactsList(isDesktop, isTablet),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar(bool isDesktop, bool isTablet) {
    return SliverAppBar(
      expandedHeight: isDesktop ? 200 : 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF0A0E27),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF059669),
                Color(0xFF10B981),
                Color(0xFF065F46),
              ],
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 48 : 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
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
                        Icons.contact_phone_rounded,
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
                            'Important Contacts',
                            style: GoogleFonts.poppins(
                              fontSize: isDesktop ? 32 : 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Important Contact Persons',
                            style: GoogleFonts.inter(
                              fontSize: isDesktop ? 16 : 14,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(bool isDesktop, bool isTablet) {
    return Container(
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
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: isDesktop ? 32 : 24,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LNMIIT Key Personnel',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 20 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Direct contact information for key administrative and academic personnel at LNMIIT.',
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 14 : 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContactsList(bool isDesktop, bool isTablet) {
    final contacts = [
      ContactData(
        name: 'Dr. Rahul Banerjee',
        designation: 'Director',
        department: 'Administration',
        email: 'rahul.banerjee@lnmiit.ac.in',
        imageAsset: 'assets/pages/faces/rahul_banerjee.jpg',
        color: const Color(0xFF3B82F6),
        priority: 'High',
      ),
      ContactData(
        name: 'Dr. Sandeep Saini',
        designation: 'Dean of Academic Affairs',
        department: 'Academic Administration',
        email: 'dean.academics@lnmiit.ac.in',
        imageAsset: 'assets/pages/faces/sandeep_saini.jpg',
        color: const Color(0xFF8B5CF6),
        priority: 'High',
      ),
      ContactData(
        name: 'Dr. Nabyendu Das',
        designation: 'Dean of Student Affairs',
        department: 'Student Administration',
        email: 'dean.students@lnmiit.ac.in',
        imageAsset: 'assets/pages/faces/nabyendu_das.jpg',
        color: const Color(0xFFF59E0B),
        priority: 'High',
      ),
      ContactData(
        name: 'Mr. Rajeev Saxena',
        designation: 'Assistant Registrar - Academic',
        department: 'Academic Office',
        email: 'aracademic@lnmiit.ac.in',
        imageAsset: 'assets/pages/faces/rajeev_saxena.jpg',
        color: const Color(0xFF06B6D4),
        priority: 'Medium',
      ),
      ContactData(
        name: 'Mr. Devaram Rabri',
        designation: 'Finance Assistant',
        department: 'Finance Office',
        email: 'devadewasi@lnmiit.ac.in',
        imageAsset: 'assets/pages/faces/devaram_rabri.jpg',
        color: const Color(0xFFEF4444),
        priority: 'Medium',
      ),
      ContactData(
        name: 'Mr. Samar Singh',
        designation: 'Assistant Registrar - Academic',
        department: 'Academic Office',
        email: 'arss@lnmiit.ac.in',
        imageAsset: 'assets/pages/faces/rajeev_saxena.jpg',
        color: const Color(0xFF10B981),
        priority: 'Medium',
      ),
      ContactData(
        name: 'Dr. Chand Singh Panwar',
        designation: 'Resident Doctor',
        department: 'Medical Services',
        email: 'medicalofficer@lnmiit.ac.in',
        imageAsset: 'assets/pages/faces/dr_chand.jpg',
        color: const Color(0xFFEC4899),
        priority: 'Emergency',
      ),
    ];

    List<Widget> widgets = [];
    
    // Add section headers
    final priorityGroups = {
      'Emergency': contacts.where((c) => c.priority == 'Emergency').toList(),
      'High': contacts.where((c) => c.priority == 'High').toList(),
      'Medium': contacts.where((c) => c.priority == 'Medium').toList(),
    };

    int cardIndex = 0;

    for (var entry in priorityGroups.entries) {
      if (entry.value.isNotEmpty) {
        final priorityInfo = _getPriorityInfo(entry.key);
        
        widgets.add(SizedBox(height: isDesktop ? 32 : 24));
        widgets.add(_buildSectionHeader(
          entry.key == 'Emergency' ? 'Emergency Contacts' :
          entry.key == 'High' ? 'Senior Administration' : 'Academic Support',
          entry.key == 'Emergency' ? 'Emergency Contacts' :
          entry.key == 'High' ? 'Senior Administration' : 'Academic Support',
          priorityInfo['icon'] as IconData,
          priorityInfo['color'] as Color,
          isDesktop,
          isTablet,
        ));
        widgets.add(const SizedBox(height: 24));

        for (var contact in entry.value) {
          widgets.add(AnimatedBuilder(
            animation: _listAnimations[cardIndex % _listAnimations.length],
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * _listAnimations[cardIndex % _listAnimations.length].value),
                child: Opacity(
                  opacity: _listAnimations[cardIndex % _listAnimations.length].value,
                  child: _buildModernContactCard(contact, isDesktop, isTablet),
                ),
              );
            },
          ));
          widgets.add(const SizedBox(height: 16));
          cardIndex++;
        }
      }
    }

    return widgets;
  }

  Map<String, dynamic> _getPriorityInfo(String priority) {
    switch (priority) {
      case 'Emergency':
        return {'icon': Icons.emergency_rounded, 'color': const Color(0xFFEF4444)};
      case 'High':
        return {'icon': Icons.star_rounded, 'color': const Color(0xFF8B5CF6)};
      default:
        return {'icon': Icons.business_rounded, 'color': const Color(0xFF10B981)};
    }
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color, bool isDesktop, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
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
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: isDesktop ? 28 : 24,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 20 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 14 : 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernContactCard(ContactData contact, bool isDesktop, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B).withOpacity(0.8),
            const Color(0xFF334155).withOpacity(0.6),
            const Color(0xFF0F172A).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: contact.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: contact.color.withOpacity(0.1),
            blurRadius: 24,
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
                width: isDesktop ? 80 : 64,
                height: isDesktop ? 80 : 64,
                decoration: BoxDecoration(
                  color: contact.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  image: contact.imageAsset != null
                      ? DecorationImage(
                          image: AssetImage(contact.imageAsset!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: contact.imageAsset == null
                    ? Icon(
                        Icons.person_rounded,
                        size: isDesktop ? 40 : 32,
                        color: contact.color,
                      )
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 20 : 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      contact.designation,
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.w500,
                        color: contact.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: contact.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        contact.department,
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 12 : 10,
                          fontWeight: FontWeight.w500,
                          color: contact.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (contact.priority == 'Emergency') ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emergency_rounded,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Emergency',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.email_rounded,
                  label: 'Send Email',
                  color: const Color(0xFF3B82F6),
                  onTap: () => _launchEmail(contact.email),
                  isDesktop: isDesktop,
                ),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.copy_rounded,
                label: 'Copy',
                color: const Color(0xFF6B7280),
                onTap: () => _copyEmail(contact.email),
                isDesktop: isDesktop,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDesktop,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: isDesktop ? 16 : 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isDesktop ? 20 : 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: isDesktop ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        final Uri gmailUri = Uri.parse('https://mail.google.com/mail/?view=cm&to=$email');
        if (await canLaunchUrl(gmailUri)) {
          await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch email: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _copyEmail(String email) async {
    await Clipboard.setData(ClipboardData(text: email));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('Email copied: $email'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}

// Enhanced data model for contact information
class ContactData {
  final String name;
  final String designation;
  final String department;
  final String email;
  final String? imageAsset;
  final Color color;
  final String priority;

  ContactData({
    required this.name,
    required this.designation,
    required this.department,
    required this.email,
    this.imageAsset,
    required this.color,
    required this.priority,
  });
}

