import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:login_page/utils/responsive_utils.dart';

import 'notifications_api/notification_model.dart';

enum NotificationFilter { all, today, thisWeek, thisMonth }

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> 
    with TickerProviderStateMixin {
  late Future<List<NotificationModel>> futureNotifications;
  bool _isLoading = false;
  NotificationFilter selectedFilter = NotificationFilter.all;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    futureNotifications = fetchNotifications();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    final response = await http.get(
      Uri.parse('https://ccell-notification-api.onrender.com/api/notifications'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => NotificationModel.fromJson(data)).toList().reversed.toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _isLoading = true;
      futureNotifications = fetchNotifications();
    });
    await Future.delayed(const Duration(milliseconds: 500)); // Minimum loading time
    setState(() => _isLoading = false);
  }

  List<NotificationModel> _filterNotifications(List<NotificationModel> notifications) {
    final now = DateTime.now();
    return notifications.where((notification) {
      final notificationDate = DateTime.parse(notification.datePosted);
      switch (selectedFilter) {
        case NotificationFilter.today:
          return notificationDate.day == now.day &&
                 notificationDate.month == now.month &&
                 notificationDate.year == now.year;
        case NotificationFilter.thisWeek:
          final weekAgo = now.subtract(const Duration(days: 7));
          return notificationDate.isAfter(weekAgo);
        case NotificationFilter.thisMonth:
          return notificationDate.month == now.month &&
                 notificationDate.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  String formateDate(String isoString) {
    final date = DateTime.parse(isoString);
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}   ${date.day}/${date.month}/${date.year}";
  }

  String formatEventDate(DateTime date) {
    return DateFormat("d MMMM, yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 768 && size.width < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A23),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48 : (isTablet ? 32 : 16),
            vertical: isDesktop ? 32 : 16,
          ),
          child: Column(
            children: [
              _buildHeader(isDesktop, isTablet),
              const SizedBox(height: 24),
              if (isDesktop || isTablet) _buildFilters(isDesktop),
              if (isDesktop || isTablet) const SizedBox(height: 24),
              _buildStatsRow(isDesktop, isTablet),
              const SizedBox(height: 24),
              Expanded(
                child: _buildNotificationsList(isDesktop, isTablet),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _refreshNotifications,
              icon: const Icon(Icons.refresh),
              label: Text(isDesktop ? 'Refresh Notifications' : 'Refresh'),
              backgroundColor: const Color(0xFF0175C2),
              foregroundColor: Colors.white,
            ),
    );
  }

  Widget _buildHeader(bool isDesktop, bool isTablet) {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _listAnimationController.value)),
          child: Opacity(
            opacity: _listAnimationController.value,
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
                        Expanded(flex: 2, child: _buildHeaderText(isDesktop)),
                        const SizedBox(width: 32),
                        _buildHeaderIcon(),
                      ],
                    )
                  : Column(
                      children: [
                        _buildHeaderText(isDesktop),
                        const SizedBox(height: 16),
                        _buildHeaderIcon(),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderText(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Center',
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 32 : 24,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stay updated with the latest announcements',
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 16 : 14,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0175C2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.notifications_active,
        size: 48,
        color: Color(0xFF0175C2),
      ),
    );
  }

  Widget _buildFilters(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: NotificationFilter.values.map((filter) {
          final isSelected = selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 12 : 10,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0175C2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  filter.name.replaceAll('_', ' '),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: isDesktop ? 14 : 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsRow(bool isDesktop, bool isTablet) {
    return FutureBuilder<List<NotificationModel>>(
      future: futureNotifications,
      builder: (context, snapshot) {
        final totalNotifications = snapshot.hasData ? snapshot.data!.length : 0;
        final todayNotifications = snapshot.hasData
            ? _filterNotifications(snapshot.data!).length
            : 0;

        return Container(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Notifications',
                  totalNotifications.toString(),
                  Icons.notifications,
                  Colors.blue,
                  isDesktop,
                ),
              ),
              if (isDesktop || isTablet) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Filtered Results',
                    todayNotifications.toString(),
                    Icons.filter_list,
                    Colors.green,
                    isDesktop,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Last Updated',
                    'Just now',
                    Icons.access_time,
                    Colors.orange,
                    isDesktop,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color, bool isDesktop) {
    return Column(
      children: [
        Icon(icon, color: color, size: isDesktop ? 24 : 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 20 : 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 12 : 10,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(bool isDesktop, bool isTablet) {
    return FutureBuilder<List<NotificationModel>>(
      future: futureNotifications,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(isDesktop);
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString(), isDesktop);
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(isDesktop);
        }

        final notifications = _filterNotifications(snapshot.data!);
        
        if (notifications.isEmpty) {
          return _buildEmptyFilterState(isDesktop);
        }

        return _buildNotificationsGrid(notifications, isDesktop, isTablet);
      },
    );
  }

  Widget _buildLoadingState(bool isDesktop) {
    return Column(
      children: [
        const SizedBox(height: 60),
        ModernLoadingIndicator(
          message: 'Loading notifications...',
          primaryColor: const Color(0xFF3B82F6),
          size: isDesktop ? 80 : 60,
        ),
        const SizedBox(height: 40),
        if (isDesktop) ...[
          // Shimmer placeholders for desktop
          _buildShimmerGrid(isDesktop),
        ],
      ],
    );
  }

  Widget _buildShimmerGrid(bool isDesktop) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 1,
        childAspectRatio: isDesktop ? 2.2 : 1.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return ShimmerLoading(
          isLoading: true,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: double.infinity * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error, bool isDesktop) {
    return EnhancedErrorState(
      title: 'Connection Error',
      message: 'Unable to load notifications. Please check your internet connection and try again.',
      icon: Icons.wifi_off_rounded,
      onRetry: _refreshNotifications,
    );
  }

  Widget _buildEmptyState(bool isDesktop) {
    return EnhancedEmptyState(
      title: 'No Notifications',
      message: 'You don\'t have any notifications yet. When new announcements are posted, they\'ll appear here.',
      icon: Icons.notifications_none_rounded,
    );
  }

  Widget _buildEmptyFilterState(bool isDesktop) {
    return EnhancedEmptyState(
      title: 'No Results Found',
      message: 'No notifications match your current filter. Try selecting a different time period.',
      icon: Icons.filter_list_off_rounded,
      onAction: () => setState(() => selectedFilter = NotificationFilter.all),
      actionLabel: 'Clear Filter',
    );
  }

  Widget _buildNotificationsGrid(
    List<NotificationModel> notifications,
    bool isDesktop,
    bool isTablet,
  ) {
    if (isDesktop) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return _EnhancedDesktopNotificationCard(
            notification: notifications[index],
            index: index,
            formatDate: formateDate,
            formatEventDate: formatEventDate,
          );
        },
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return _EnhancedMobileNotificationCard(
            notification: notifications[index],
            index: index,
            formatDate: formateDate,
            formatEventDate: formatEventDate,
          );
        },
      );
    }
  }
}

class _EnhancedDesktopNotificationCard extends StatefulWidget {
  final NotificationModel notification;
  final int index;
  final String Function(String) formatDate;
  final String Function(DateTime) formatEventDate;

  const _EnhancedDesktopNotificationCard({
    required this.notification,
    required this.index,
    required this.formatDate,
    required this.formatEventDate,
  });

  @override
  State<_EnhancedDesktopNotificationCard> createState() => _EnhancedDesktopNotificationCardState();
}

class _EnhancedDesktopNotificationCardState extends State<_EnhancedDesktopNotificationCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
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
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..scale(_isHovered ? 1.02 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isHovered ? [
              const Color(0xFF1E293B),
              const Color(0xFF0F172A),
            ] : [
              const Color(0xFF0F172A),
              const Color(0xFF1E293B),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered 
                ? const Color(0xFF3B82F6).withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered 
                  ? const Color(0xFF3B82F6).withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
              blurRadius: _isHovered ? 20 : 10,
              spreadRadius: 0,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.notification.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.formatDate(widget.notification.datePosted),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Text(
                  widget.notification.message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.notification.eventDate != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.event_rounded,
                            size: 14,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.formatEventDate(widget.notification.eventDate!),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (_isHovered) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'View Details',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnhancedMobileNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final int index;
  final String Function(String) formatDate;
  final String Function(DateTime) formatEventDate;

  const _EnhancedMobileNotificationCard({
    required this.notification,
    required this.index,
    required this.formatDate,
    required this.formatEventDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          formatDate(notification.datePosted),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              notification.message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            if (notification.eventDate != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.event_rounded,
                      size: 16,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Event Date: ${formatEventDate(notification.eventDate!)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
