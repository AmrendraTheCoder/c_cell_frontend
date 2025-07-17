import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_page/login_page.dart';
import 'package:login_page/more_page.dart';
import 'package:login_page/home_page.dart';

import 'package:login_page/notifications_screen.dart';
import 'package:login_page/profile_page.dart';
import 'package:login_page/welcome_screen.dart';
import 'package:login_page/hostel_registration.dart';
import 'package:login_page/loading_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'gymkhana.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lnm_page.dart';
import 'firebase_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Handling a background message: ${message.messageId}");
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      if (kDebugMode) {
        print("🔥 Foreground push received!");
        print("Title: ${message.notification?.title}");
        print("Body: ${message.notification?.body}");
      }
      if (!kIsWeb) {
        flutterLocalNotificationsPlugin.show(
         notification.hashCode,
         notification.title,
         notification.body,
         NotificationDetails(
           android: AndroidNotificationDetails(
             'channelId',
             'General',
             importance: Importance.high,
             priority: Priority.max,
             color: Color(0xFF143FA6),
             enableLights: true,
             enableVibration: true,
             largeIcon: FilePathAndroidBitmap('assets/images/ccell_logo.png'),
             visibility: NotificationVisibility.public,
           ),
         ),
       );}

    }
  });

  // 👇 Call your FCM init function (make sure to replace with actual userId)


  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'LNMIIT C-Cell App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.interTextTheme(), // Set Inter as default
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0175C2),
            brightness: Brightness.dark,
          ),
        ),
        routes: {
          '/profile': (context) => const ProfilePage(),
          '/home': (context) => const MyHomePage(),
          '/welcome': (context) => const WelcomeScreen(),
          '/hostel_registration': (context) => const HostelRegistrationScreen(),
          '/login': (context) => const LoginPage(),
        },
        home: const AuthLoadingScreen(),
      ),
    );
  }
}

// =====================
// AuthLoadingScreen
// =====================

class AuthLoadingScreen extends StatefulWidget {
  const AuthLoadingScreen({super.key});

  @override
  State<AuthLoadingScreen> createState() => _AuthLoadingScreenState();
}

class _AuthLoadingScreenState extends State<AuthLoadingScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, _, _) => LoadingScreen(
            userName: FirebaseAuth.instance.currentUser?.displayName ?? 'User',
          ),
        ),
      );
      if (!_navigated) {
        _navigated = true;
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/welcome');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while waiting for navigation
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// =====================
// 🧭 Responsive Navigation UI
// =====================

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _sidebarController;
  late AnimationController _hoverController;
  bool _isHovering = false;

  final List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      icon: Icons.home,
      activeIcon: Icons.home_filled,
      label: "Home",
      color: Colors.white,
      page: () => HomePage(userName: FirebaseAuth.instance.currentUser?.displayName ?? 'Student'),
    ),
    _NavigationItem(
      icon: Icons.sports,
      activeIcon: Icons.sports,
      label: "Gymkhana", 
      color: Colors.cyanAccent,
      page: () => const GymkhanaPage(),
    ),
    _NavigationItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      label: "Notifications",
      color: Colors.lightGreenAccent,
      page: () => const NotificationsPage(),
    ),
    _NavigationItem(
      icon: Icons.account_balance_outlined,
      activeIcon: Icons.account_balance,
      label: "LNMIIT",
      color: Colors.redAccent,
      page: () => const LNMPage(),
    ),
    _NavigationItem(
      icon: Icons.more_horiz_outlined,
      activeIcon: Icons.more_horiz,
      label: "More",
      color: Colors.purpleAccent,
      page: () => MorePage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedIndex = index;
    });
  }

  // Keyboard navigation support
  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.digit1) _onItemTapped(0);
      if (event.logicalKey == LogicalKeyboardKey.digit2) _onItemTapped(1);
      if (event.logicalKey == LogicalKeyboardKey.digit3) _onItemTapped(2);
      if (event.logicalKey == LogicalKeyboardKey.digit4) _onItemTapped(3);
      if (event.logicalKey == LogicalKeyboardKey.digit5) _onItemTapped(4);
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft && _selectedIndex > 0) {
        _onItemTapped(_selectedIndex - 1);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight && _selectedIndex < _navigationItems.length - 1) {
        _onItemTapped(_selectedIndex + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;
    
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: _handleKeyPress,
      child: Scaffold(
        body: Row(
          children: [
            // Desktop Sidebar
            if (isDesktop) ...[
              _buildDesktopSidebar(),
            ],
            
            // Main Content Area
            Expanded(
              child: _buildMainContent(isDesktop, isTablet),
            ),
          ],
        ),
        
        // Mobile/Tablet Bottom Navigation
        bottomNavigationBar: (!isDesktop) ? _buildBottomNavigation(isTablet) : null,
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0175C2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'C-Cell',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'LNMIIT',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: Colors.white24, height: 1),
          
          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              itemCount: _navigationItems.length,
              itemBuilder: (context, index) {
                final item = _navigationItems[index];
                final isSelected = _selectedIndex == index;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: _DesktopNavItem(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => _onItemTapped(index),
                    index: index + 1,
                  ),
                );
              },
            ),
          ),
          
          // User Profile Section
          Container(
            padding: const EdgeInsets.all(16),
            child: _buildUserProfile(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? '';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF0175C2),
            child: Text(
              displayName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.length > 15 ? '${displayName.substring(0, 15)}...' : displayName,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  email.length > 20 ? '${email.substring(0, 20)}...' : email,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDesktop, bool isTablet) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0E27),
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey(_selectedIndex),
          child: _navigationItems[_selectedIndex].page(),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 20 : 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
        child: SalomonBottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.black.withOpacity(0.9),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey.shade600,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          itemPadding: EdgeInsets.symmetric(
            vertical: isTablet ? 16 : 12,
            horizontal: isTablet ? 20 : 16,
          ),
          items: _navigationItems.map((item) {
            final isSelected = _navigationItems.indexOf(item) == _selectedIndex;
            return SalomonBottomBarItem(
              icon: _buildAnimatedIcon(
                isSelected ? item.activeIcon : item.icon,
                isSelected,
                item.color,
              ),
              title: Text(
                item.label,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selectedColor: item.color,
              unselectedColor: Colors.grey.shade600,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, bool isSelected, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Icon(
        icon,
        color: isSelected ? color : Colors.grey.shade600,
        size: 24,
      ),
    );
  }
}

// =====================
// Navigation Models & Widgets
// =====================

class _NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;
  final Widget Function() page;

  _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
    required this.page,
  });
}

class _DesktopNavItem extends StatefulWidget {
  final _NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const _DesktopNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  State<_DesktopNavItem> createState() => _DesktopNavItemState();
}

class _DesktopNavItemState extends State<_DesktopNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _hoverAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? widget.item.color.withOpacity(0.15)
                    : _isHovering 
                        ? Colors.white.withOpacity(0.05)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: widget.isSelected
                    ? Border.all(color: widget.item.color.withOpacity(0.3))
                    : null,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isSelected 
                          ? widget.item.color.withOpacity(0.2)
                          : _isHovering 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                      color: widget.isSelected 
                          ? widget.item.color
                          : _isHovering 
                              ? Colors.white 
                              : Colors.white70,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.label,
                      style: GoogleFonts.inter(
                        color: widget.isSelected 
                            ? widget.item.color
                            : _isHovering 
                                ? Colors.white 
                                : Colors.white70,
                        fontSize: 14,
                        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (kIsWeb) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.index.toString(),
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

