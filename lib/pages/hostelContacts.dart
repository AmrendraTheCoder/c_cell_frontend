import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class HostelPage extends StatefulWidget {
  const HostelPage({super.key});

  @override
  State<HostelPage> createState() => _HostelPageState();
}

class _HostelPageState extends State<HostelPage> with TickerProviderStateMixin {
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
    _listAnimations = List.generate(30, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _listController,
          curve: Interval(
            index * 0.05,
            0.3 + (index * 0.05),
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
                        ..._buildAllSections(isDesktop, isTablet),
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
                Color(0xFF1E3A8A),
                Color(0xFF3B82F6),
                Color(0xFF1E40AF),
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
                        Icons.home_rounded,
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
                            'Hostel Contacts',
                            style: GoogleFonts.poppins(
                              fontSize: isDesktop ? 32 : 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Hostel Contact Information',
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
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LNMIIT Hostel Directory',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 20 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete contact information for all hostel staff, wardens, and administration.',
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

  List<Widget> _buildAllSections(bool isDesktop, bool isTablet) {
    int cardIndex = 0;
    
    final sections = [
      {
        'title': 'ADMINISTRATION',
        'subtitle': 'Administrative Contacts',
        'icon': Icons.business_rounded,
        'color': const Color(0xFF10B981),
        'contacts': [
          ContactData(
            name: 'Pushpendra Singh',
            designation: 'Chief Administrative Officer',
            email: 'cao@lnmiit.ac.in',
            phone: '0141-3526006',
            imageAsset: 'assets/pages/faces/pushpendra_singh.jpg'
          ),
          ContactData(
            name: 'Mr. Manoj Singh',
            designation: 'Chief Warden Office - Office Staff',
            email: 'cwoffice@lnmiit.ac.in',
            phone: '+91-9351773779'
          ),
        ]
      },
      {
        'title': 'BOYS HOSTEL 1',
        'subtitle': 'बॉयज हॉस्टल 1',
        'icon': Icons.apartment_rounded,
        'color': const Color(0xFF3B82F6),
        'contacts': [
          ContactData(
            name: 'BH1 Reception',
            designation: 'Boys Hostel 1 Main Reception',
            phone: '+91-0141-2688128',
          ),
          ContactData(
            name: 'Mr. Namo Narayan Meena',
            designation: 'Jr. Hostel Superintendent BH1',
            email: 'jhs-bh1@lnmiit.ac.in',
            phone: '91-141-3526145',
            phone2: '7851948930',
            imageAsset: 'assets/pages/faces/namo_narayan_meena.jpg'
          ),
          ContactData(
            name: 'Mr. Prahlad Sharma',
            designation: 'Hostel Support BH1',
            email: 'bh1-support@lnmiit.ac.in',
            phone: '91-141-3526145',
            phone2: '7851948930',
            imageAsset: 'assets/pages/faces/prahlad_sharma.jpg'
          ),
          ContactData(
            name: 'Mr. Kajor Meena',
            designation: 'Hostel Support BH1',
            email: 'bh1-support@lnmiit.ac.in',
            phone: '91-141-3526145',
            phone2: '7851948930'
          ),
          ContactData(
            name: 'Mr. Abhishek Sharma',
            designation: 'Hostel Support BH1',
            email: 'bh1-support@lnmiit.ac.in',
            phone: '91-141-3526145',
            phone2: '7851948930'
          ),
        ]
      },
      {
        'title': 'BOYS HOSTEL 2',
        'subtitle': 'बॉयज हॉस्टल 2',
        'icon': Icons.apartment_rounded,
        'color': const Color(0xFFF59E0B),
        'contacts': [
          ContactData(
            name: 'BH2 Reception',
            designation: 'Boys Hostel 2 Main Reception',
            phone: '+91-0141-2688129',
          ),
          ContactData(
            name: 'Mr. Namo Narayan Meena',
            designation: 'Jr. Hostel Superintendent BH2',
            email: 'jhs-bh2@lnmiit.ac.in',
            phone: '+91-141-3526148',
            phone2: '7852824457',
            imageAsset: 'assets/pages/faces/namo_narayan_meena.jpg'
          ),
          ContactData(
            name: 'Mr. Kamlesh Kumar Meena',
            designation: 'Hostel Support BH2',
            email: 'bh2-support@lnmiit.ac.in',
            phone: '91-141-3526148',
            phone2: '7852824457'
          ),
          ContactData(
            name: 'Mr. Suresh Chand Danka',
            designation: 'Hostel Support BH2',
            email: 'bh2-support@lnmiit.ac.in',
            phone: '91-141-3526148',
            phone2: '7852824457'
          ),
        ]
      },
      {
        'title': 'BOYS HOSTEL 3',
        'subtitle': 'बॉयज हॉस्टल 3',
        'icon': Icons.apartment_rounded,
        'color': const Color(0xFF8B5CF6),
        'contacts': [
          ContactData(
            name: 'BH3 Reception',
            designation: 'Boys Hostel 3 Main Reception',
            phone: '+91-0141-2688130',
          ),
          ContactData(
            name: 'Mr. Ghanshyam Sharma',
            designation: 'Jr. Hostel Superintendent BH3',
            email: 'jhs-bh3@lnmiit.ac.in',
            phone: '91-141-3526151',
            phone2: '7852833867'
          ),
          ContactData(
            name: 'Mr. Rahul Sharma',
            designation: 'Hostel Support BH3',
            email: 'bh3-support@lnmiit.ac.in',
            phone: '91-141-3526151',
            phone2: '7852833867'
          ),
          ContactData(
            name: 'Mr. Ram Kumar Singh',
            designation: 'Hostel Support BH3',
            email: 'bh3-support@lnmiit.ac.in',
            phone: '91-141-3526151',
            phone2: '7852833867'
          ),
          ContactData(
            name: 'Mr. Madhu Sudan Sharma',
            designation: 'Hostel Support BH3',
            email: 'bh3-support@lnmiit.ac.in',
            phone: '91-141-3526151',
            phone2: '7852833867'
          ),
        ]
      },
      {
        'title': 'BOYS HOSTEL 4',
        'subtitle': 'बॉयज हॉस्टल 4',
        'icon': Icons.apartment_rounded,
        'color': const Color(0xFFEF4444),
        'contacts': [
          ContactData(
            name: 'BH4 Reception',
            designation: 'Boys Hostel 4 Main Reception',
            phone: '+91-0141-2688131',
          ),
          ContactData(
            name: 'Mr. Ghanshyam Sharma',
            designation: 'Jr. Hostel Superintendent BH4',
            email: 'jhs-bh4@lnmiit.ac.in',
            phone: '91-141-3526153',
            phone2: '7852832339'
          ),
          ContactData(
            name: 'Mr. Praveen Kumar Jha',
            designation: 'Hostel Support BH4',
            email: 'bh4-support@lnmiit.ac.in',
            phone: '91-141-3526153',
            phone2: '7852832339'
          ),
          ContactData(
            name: 'Mr. Manoj Kumar Pancholi',
            designation: 'Hostel Support BH4',
            email: 'bh4-support@lnmiit.ac.in',
            phone: '91-141-3526153',
            phone2: '7852832339'
          ),
        ]
      },
      {
        'title': 'BOYS HOSTEL 5',
        'subtitle': 'बॉयज हॉस्टल 5',
        'icon': Icons.apartment_rounded,
        'color': const Color(0xFF06B6D4),
        'contacts': [
          ContactData(
            name: 'Mr. Prahlad Sharma',
            designation: 'Hostel Support BH5 (Pre FEB Building)',
            email: 'bh1-support@lnmiit.ac.in',
            phone: '7851948930',
            imageAsset: 'assets/pages/faces/prahlad_sharma.jpg'
          ),
        ]
      },
      {
        'title': 'GIRLS HOSTEL',
        'subtitle': 'गर्ल्स हॉस्टल',
        'icon': Icons.home_rounded,
        'color': const Color(0xFFEC4899),
        'contacts': [
          ContactData(
            name: 'Girls Hostel Reception',
            designation: 'Girls Hostel Main Reception',
            phone: '+91-0141-2688132'
          ),
          ContactData(
            name: 'Dr. Poonam Gera',
            designation: 'GH Warden',
            phone: '+91-0141-3526225',
            email: 'warden-gh@lnmiit.ac.in',
            imageAsset: 'assets/pages/faces/poonam_gera.jpg'
          ),
          ContactData(
            name: 'Mrs. Sakshi Sharma',
            designation: 'Hostel Support GH',
            phone: '91-141-3526158',
            phone2: '7851941316',
            email: 'gh-support@lnmiit.ac.in',
          ),
          ContactData(
            name: 'Mrs. Pankesh Sharma',
            designation: 'Hostel Support GH',
            phone: '91-141-3526158',
            phone2: '7851941316',
            email: 'gh-support@lnmiit.ac.in',
          ),
          ContactData(
            name: 'Mrs. Manju Kunwar',
            designation: 'Hostel Support GH',
            phone: '91-141-3526158',
            phone2: '7851941316',
            email: 'gh-support@lnmiit.ac.in',
          ),
        ]
      }
    ];

    List<Widget> widgets = [];
    
    for (var section in sections) {
      widgets.add(SizedBox(height: isDesktop ? 48 : 32));
      widgets.add(_buildModernSectionHeader(
        section['title'] as String,
        section['subtitle'] as String,
        section['icon'] as IconData,
        section['color'] as Color,
        isDesktop,
        isTablet,
      ));
      widgets.add(const SizedBox(height: 24));

      final contacts = section['contacts'] as List<ContactData>;
      for (var contact in contacts) {
        widgets.add(AnimatedBuilder(
          animation: _listAnimations[cardIndex % _listAnimations.length],
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * _listAnimations[cardIndex % _listAnimations.length].value),
              child: Opacity(
                opacity: _listAnimations[cardIndex % _listAnimations.length].value,
                child: _buildModernContactCard(
                  contact,
                  section['color'] as Color,
                  isDesktop,
                  isTablet,
                ),
              ),
            );
          },
        ));
        widgets.add(const SizedBox(height: 16));
        cardIndex++;
      }
    }

    return widgets;
  }

  Widget _buildModernSectionHeader(String title, String subtitle, IconData icon, Color color, bool isDesktop, bool isTablet) {
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

  Widget _buildModernContactCard(ContactData contact, Color accentColor, bool isDesktop, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
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
                width: isDesktop ? 60 : 50,
                height: isDesktop ? 60 : 50,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
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
                        size: isDesktop ? 32 : 28,
                        color: accentColor,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (contact.designation.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        contact.designation,
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 14 : 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (contact.email != null || contact.phone != null || contact.phone2 != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (contact.email != null)
                  _buildActionButton(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    color: const Color(0xFF3B82F6),
                    onTap: () => _launchEmail(contact.email!),
                    isDesktop: isDesktop,
                  ),
                if (contact.phone != null)
                  _buildActionButton(
                    icon: Icons.phone_rounded,
                    label: 'Phone',
                    color: const Color(0xFF10B981),
                    onTap: () => _launchPhone(contact.phone!),
                    isDesktop: isDesktop,
                  ),
                if (contact.phone2 != null)
                  _buildActionButton(
                    icon: Icons.phone_android_rounded,
                    label: 'Mobile',
                    color: const Color(0xFFF59E0B),
                    onTap: () => _launchPhone(contact.phone2!),
                    isDesktop: isDesktop,
                  ),
              ],
            ),
          ],
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
          horizontal: isDesktop ? 16 : 12,
          vertical: isDesktop ? 12 : 8,
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
          children: [
            Icon(
              icon,
              size: isDesktop ? 18 : 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: isDesktop ? 12 : 10,
                fontWeight: FontWeight.w500,
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

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch phone: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }
}

// Data model for contact information
class ContactData {
  final String name;
  final String designation;
  final String? email;
  final String? phone;
  final String? phone2;
  final String? imageAsset;

  ContactData({
    required this.name,
    required this.designation,
    this.email,
    this.phone,
    this.phone2,
    this.imageAsset,
  });
}