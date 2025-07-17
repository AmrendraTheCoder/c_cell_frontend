import 'dart:convert';
import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:login_page/gymkhana.dart';
import 'package:login_page/notifications_screen.dart';

class HomePage extends StatelessWidget {
  final String userName;
  const HomePage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHomeDashboard(userName: userName);
  }
}

class ResponsiveHomeDashboard extends StatefulWidget {
  final String userName;

  const ResponsiveHomeDashboard({super.key, required this.userName});

  @override
  State<ResponsiveHomeDashboard> createState() => _ResponsiveHomeDashboardState();
}

class _ResponsiveHomeDashboardState extends State<ResponsiveHomeDashboard>
    with TickerProviderStateMixin {
  late AnimationController _welcomeAnimationController;
  late AnimationController _cardAnimationController;
  late List<AnimationController> _cardControllers;
  late List<AnimationController> _statsControllers;

  final Map<String, Map<String, dynamic>> buttonData = {
    'Academic Calendar': {
      'image': 'academic_calender.png',
      'url': 'https://lnmiit.ac.in/academics/academic-documents/#pdf-academic-calendar-2025/1/',
      'icon': Icons.calendar_today,
      'description': 'View academic calendar and important dates',
    },
    'Lost & Found': {
      'image': 'lost_found.png',
      'icon': Icons.search,
      'description': 'Report lost items or find lost belongings',
    },
    'Find the Location': {
      'image': 'find_location.png',
      'icon': Icons.location_on,
      'description': 'Navigate around campus with interactive maps',
    },
    'Bus Timetable': {
      'image': 'bus_timetable.png',
      'url': 'https://raw.githubusercontent.com/Counselling-Cell-LNMIIT/appResources/main/pdf/Bus_Time_Table.pdf',
      'icon': Icons.directions_bus,
      'description': 'Check bus schedules and routes',
    },
    'Mess Menu': {
      'image': 'mess_menu.png',
      'url': 'https://raw.githubusercontent.com/Counselling-Cell-LNMIIT/appResources/main/pdf/Mess_Menu.pdf',
      'icon': Icons.restaurant,
      'description': 'View daily mess menu and timings',
    },
    'Profile': {
      'image': 'profile.png',
      'route': 'profile',
      'icon': Icons.person,
      'description': 'Manage your profile and settings',
    }
  };

  @override
  void initState() {
    super.initState();
    _welcomeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _cardControllers = List.generate(
      buttonData.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );
    
    _statsControllers = List.generate(
      4, // 4 stats cards
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + (index * 150)),
        vsync: this,
      ),
    );

    // Start animations
    _welcomeAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
      // Start stats animations
      for (int i = 0; i < _statsControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 100), () {
          if (mounted) _statsControllers[i].forward();
        });
      }
      // Start services animations
      for (int i = 0; i < _cardControllers.length; i++) {
        Future.delayed(Duration(milliseconds: 500 + (i * 100)), () {
          if (mounted) _cardControllers[i].forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _welcomeAnimationController.dispose();
    _cardAnimationController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    for (var controller in _statsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 768 && size.width < 1024;
    final isMobile = size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF001219),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : (isTablet ? 32 : 20),
              vertical: isDesktop ? 32 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(isDesktop, isTablet),
                SizedBox(height: isDesktop ? 48 : 32),
                _buildQuickStatsSection(isDesktop, isTablet),
                SizedBox(height: isDesktop ? 48 : 32),
                _buildServicesGrid(isDesktop, isTablet, isMobile),
                SizedBox(height: isDesktop ? 48 : 32),
                _buildFooterSection(isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(bool isDesktop, bool isTablet) {
    return AnimatedBuilder(
      animation: _welcomeAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _welcomeAnimationController.value)),
          child: Opacity(
            opacity: _welcomeAnimationController.value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isDesktop ? 32 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0175C2).withOpacity(0.1),
                    const Color(0xFF003547).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: isDesktop
                  ? Row(
                      children: [
                        Expanded(flex: 2, child: _buildWelcomeText(isDesktop)),
                        const SizedBox(width: 32),
                        Expanded(child: _buildWelcomeIllustration()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildWelcomeText(isDesktop),
                        const SizedBox(height: 24),
                        _buildWelcomeIllustration(),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeText(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 18 : 16,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.userName,
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 36 : 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your gateway to LNMIIT campus life',
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 16 : 14,
            color: Colors.white60,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (isDesktop) ...[
          const SizedBox(height: 20),
          _buildQuickActionButtons(),
        ],
      ],
    );
  }

  Widget _buildWelcomeIllustration() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF0175C2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.school,
          size: 60,
          color: Color(0xFF0175C2),
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons() {
    return Row(
      children: [
        _buildQuickActionButton(
          'View Profile',
          Icons.person_outline,
          () => Navigator.pushNamed(context, '/profile'),
        ),
        const SizedBox(width: 12),
        _buildQuickActionButton(
          'Notifications',
          Icons.notifications_outlined,
          () => {}, // Will be handled by navigation
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection(bool isDesktop, bool isTablet) {
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
      child: Column(
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
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campus Overview',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 24 : 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Live campus statistics and updates',
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 14 : 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 32 : 24),
          _buildStatsGrid(isDesktop, isTablet),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDesktop, bool isTablet) {
    final stats = [
      _StatData(
        title: 'Active Clubs',
        value: '25+',
        subtitle: 'Student organizations',
        icon: Icons.groups_rounded,
        color: const Color(0xFF3B82F6),
        trend: '+3',
        isPositive: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GymkhanaPage()),
        ),
      ),
      _StatData(
        title: 'Events This Month',
        value: '12',
        subtitle: 'Upcoming activities',
        icon: Icons.event_rounded,
        color: const Color(0xFF10B981),
        trend: '+5',
        isPositive: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GymkhanaPage()),
        ),
      ),
             _StatData(
         title: 'New Notifications',
         value: '8',
         subtitle: 'Unread messages',
         icon: Icons.notifications_active_rounded,
         color: const Color(0xFFF59E0B),
         trend: '+2',
         isPositive: true,
         onTap: () {
           // Navigate to notifications by using Navigator
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => const NotificationsPage()),
           );
         },
       ),
             _StatData(
         title: 'Quick Services',
         value: '6',
         subtitle: 'Available now',
         icon: Icons.apps_rounded,
         color: const Color(0xFF8B5CF6),
         trend: 'All Active',
         isPositive: true,
         onTap: () {
           // Show services info
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Quick services are available below!'),
               backgroundColor: const Color(0xFF8B5CF6),
               behavior: SnackBarBehavior.floating,
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(10),
               ),
             ),
           );
         },
       ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 2),
        childAspectRatio: isDesktop ? 1.1 : (isTablet ? 1.0 : 0.9),
        crossAxisSpacing: isDesktop ? 20 : 12,
        mainAxisSpacing: isDesktop ? 20 : 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return AnimatedBuilder(
          animation: _statsControllers[index],
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * _statsControllers[index].value),
              child: Opacity(
                opacity: _statsControllers[index].value,
                child: _buildModernStatCard(stat, isDesktop),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernStatCard(_StatData stat, bool isDesktop) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        stat.onTap();
      },
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 20 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              stat.color.withOpacity(0.1),
              stat.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: stat.color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: stat.color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: stat.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    stat.icon,
                    color: stat.color,
                    size: isDesktop ? 24 : 20,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stat.isPositive 
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        stat.isPositive 
                            ? Icons.trending_up_rounded 
                            : Icons.trending_down_rounded,
                        size: 12,
                        color: stat.isPositive 
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        stat.trend,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: stat.isPositive 
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              stat.value,
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 28 : 24,
                fontWeight: FontWeight.w800,
                color: stat.color,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.title,
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              stat.subtitle,
              style: GoogleFonts.inter(
                fontSize: isDesktop ? 11 : 10,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  'View Details',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: stat.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: stat.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildServicesGrid(bool isDesktop, bool isTablet, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Services',
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 2),
          childAspectRatio: isDesktop ? 1.2 : (isTablet ? 1.1 : 1.0),
          mainAxisSpacing: isDesktop ? 24 : 16,
          crossAxisSpacing: isDesktop ? 24 : 16,
          children: buttonData.entries.map((entry) {
            final index = buttonData.keys.toList().indexOf(entry.key);
            return AnimatedBuilder(
              animation: _cardControllers[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - _cardControllers[index].value)),
                  child: Opacity(
                    opacity: _cardControllers[index].value,
                    child: ResponsiveFancyButton(
                      title: entry.key,
                      imageName: entry.value['image'],
                      url: entry.value['url'],
                      route: entry.value['route'],
                      icon: entry.value['icon'],
                      description: entry.value['description'],
                      isDesktop: isDesktop,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFooterSection(bool isDesktop) {
    if (!isDesktop) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need Help?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Contact C-Cell for assistance',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.support_agent, size: 18),
            label: const Text('Contact Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0175C2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResponsiveFancyButton extends StatefulWidget {
  final String title;
  final String imageName;
  final String? route;
  final String? url;
  final IconData icon;
  final String description;
  final bool isDesktop;

  const ResponsiveFancyButton({
    super.key,
    required this.title,
    required this.imageName,
    this.route,
    this.url,
    required this.icon,
    required this.description,
    required this.isDesktop,
  });

  @override
  State<ResponsiveFancyButton> createState() => _ResponsiveFancyButtonState();
}

class _ResponsiveFancyButtonState extends State<ResponsiveFancyButton>
    with TickerProviderStateMixin {
  bool _isPressed = false;
  bool _isHovered = false;
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  void _handleTap() async {
    HapticFeedback.lightImpact();
    _pressController.forward().then((_) => _pressController.reverse());
    
    if (widget.route != null && widget.route!.isNotEmpty) {
      Navigator.pushNamed(context, '/${widget.route}');
    } else if (widget.url != null && widget.url!.isNotEmpty) {
      await _launchUrl(widget.url!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _pressController.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _pressController.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _pressController.reverse();
        },
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverController, _pressController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value * _elevationAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isHovered
                        ? [
                            const Color(0xFF353F54).withOpacity(0.9),
                            const Color(0xFF222834).withOpacity(0.9),
                          ]
                        : [
                            const Color(0xFF353F54).withOpacity(0.7),
                            const Color(0xFF222834).withOpacity(0.7),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isHovered 
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    width: _isHovered ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.1),
                      blurRadius: _isHovered ? 20 : 10,
                      spreadRadius: 0,
                      offset: Offset(0, _isHovered ? 8 : 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(widget.isDesktop ? 20 : 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon/Image Section
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(widget.isDesktop ? 16 : 12),
                        decoration: BoxDecoration(
                          color: _isHovered 
                              ? const Color(0xFF0175C2).withOpacity(0.2)
                              : const Color(0xFF0175C2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          size: widget.isDesktop ? 32 : 28,
                          color: _isHovered 
                              ? const Color(0xFF0175C2)
                              : Colors.white70,
                        ),
                      ),
                      
                      SizedBox(height: widget.isDesktop ? 16 : 12),
                      
                      // Title
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: _isHovered ? Colors.white : Colors.white70,
                          fontSize: widget.isDesktop ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      
                      if (widget.isDesktop && widget.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                        ),
                      ],
                      
                      if (_isHovered && widget.isDesktop) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0175C2).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Click to open',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF0175C2),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Data model for stats
class _StatData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isPositive;
  final VoidCallback onTap;

  _StatData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
    required this.onTap,
  });
}


