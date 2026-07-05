import 'dart:async';
import 'dart:ui';
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const ModernProfileApp());
}

// โมเดลข้อมูลสำหรับใช้ใน Dialog แบบรูดได้
class DetailItem {
  final String title;
  final String content;
  final IconData icon;
  final String? subtitle;
  final List<String>? tags; // เพิ่มแท็กสำหรับแสดงผลบนการ์ด

  DetailItem({
    required this.title, 
    required this.content, 
    required this.icon, 
    this.subtitle,
    this.tags,
  });
}

class ModernProfileApp extends StatelessWidget {
  const ModernProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PortfolioHomePage(),
    );
  }
}

class PortfolioHomePage extends StatefulWidget {
  const PortfolioHomePage({super.key});

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage> {
  int _selectedIndex = 0;
  bool _isDark = true;
  static const _navItems = ['Home', 'Contact', 'Skills', 'Education', 'Hobby'];

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 720;
    final themeData = _isDark 
      ? ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F0F0F),
          primaryColor: Colors.amber,
        )
      : ThemeData.light().copyWith(
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          primaryColor: Colors.amber,
        );

    return Theme(
      data: themeData,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(isMobile ? 64 : 80),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                title: Padding(
                  padding: EdgeInsets.only(left: isMobile ? 0 : 16),
                  child: Text(
                    'Boom\'s Portfolio',
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: isMobile ? 0.5 : 2,
                      color: _isDark ? Colors.amber : Colors.amber.shade700,
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: isMobile ? 8 : 24),
                    child: Row(
                      children: [
                        if (!isMobile) ...[
                          for (var i = 0; i < _navItems.length; i++)
                            _NavButton(_navItems[i], i, _selectedIndex, _onNavTapped, _isDark),
                          const SizedBox(width: 16),
                        ],
                        if (isMobile)
                          PopupMenuButton<int>(
                            icon: Icon(
                              Icons.menu,
                              color: _isDark ? Colors.amber : Colors.amber.shade700,
                            ),
                            onSelected: _onNavTapped,
                            itemBuilder: (context) => List.generate(
                              _navItems.length,
                              (index) => PopupMenuItem(
                                value: index,
                                child: Text(_navItems[index]),
                              ),
                            ),
                          ),
                        IconButton(
                          onPressed: _toggleTheme,
                          icon: Icon(
                            _isDark ? Icons.light_mode : Icons.dark_mode,
                            color: _isDark ? Colors.amber : Colors.amber.shade700,
                          ),
                          tooltip: 'สลับโหมดมืด/สว่าง',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _getPages(_isDark)[_selectedIndex],
        ),
      ),
    );
  }

  List<Widget> _getPages(bool isDark) {
    return [
      ProfilePage(isDark: isDark),
      ContactPage(isDark: isDark),
      SkillsPage(isDark: isDark),
      EducationPage(isDark: isDark),
      HobbyPage(isDark: isDark),
    ];
  }
}

// --- Common UI Components ---

class Responsive {
  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < 700;

  static EdgeInsets pagePadding(BuildContext context, {double bottom = 40}) {
    final mobile = isMobile(context);
    return EdgeInsets.fromLTRB(
      mobile ? 16 : 40,
      mobile ? 96 : 140,
      mobile ? 16 : 40,
      bottom,
    );
  }

  static double cardWidth(BuildContext context, double desktopWidth) {
    final available = MediaQuery.sizeOf(context).width - (isMobile(context) ? 32 : 80);
    return available < desktopWidth ? available : desktopWidth;
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;
  final bool isDark;
  const _NavButton(this.label, this.index, this.selectedIndex, this.onTap, this.isDark);

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selectedIndex;
    final activeColor = isDark ? Colors.amber : Colors.amber.shade700;
    final inactiveColor = isDark ? Colors.white70 : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? activeColor.withOpacity(0.5) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : inactiveColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumSectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const PremiumSectionTitle({super.key, required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.w900,
            letterSpacing: isMobile ? 0.5 : 1.5,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 24),
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final bool isDark;
  const PremiumCard({super.key, required this.child, this.width, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      width: width == null ? null : Responsive.cardWidth(context, width!),
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
      ),
      child: child,
    );
  }
}

// --- Swipeable Carousel Dialog ---

class PremiumSwipeDialog extends StatefulWidget {
  final List<DetailItem> items;
  final int initialIndex;
  final bool isDark;

  const PremiumSwipeDialog({
    super.key, 
    required this.items, 
    required this.initialIndex, 
    required this.isDark
  });

  @override
  State<PremiumSwipeDialog> createState() => _PremiumSwipeDialogState();
}

class _PremiumSwipeDialogState extends State<PremiumSwipeDialog> {
  late PageController _pageController;
  late int _currentIndex;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextIndex = (_currentIndex + 1) % widget.items.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black87;
    final screenSize = MediaQuery.sizeOf(context);
    final isMobile = screenSize.width < 700;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 40,
          vertical: isMobile ? 16 : 24,
        ),
        child: Container(
          width: isMobile ? screenSize.width - 32 : 900,
          height: isMobile ? screenSize.height * 0.78 : 600,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(isMobile ? 24 : 40),
            border: Border.all(color: Colors.amber.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 40,
                spreadRadius: 10,
              )
            ],
          ),
          child: Column(
            children: [
              // Indicator & Close Button
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 20 : 32,
                  isMobile ? 16 : 24,
                  isMobile ? 12 : 24,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(widget.items.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          height: 8,
                          width: _currentIndex == index ? 32 : 8,
                          decoration: BoxDecoration(
                            color: _currentIndex == index ? Colors.amber : Colors.amber.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textColor.withOpacity(0.5), size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // PageView Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    _startAutoScroll();
                  },
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 60,
                        vertical: isMobile ? 24 : 40,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(isMobile ? 18 : 24),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.amber.withOpacity(0.2), width: 2),
                            ),
                            child: Icon(item.icon, color: Colors.amber, size: isMobile ? 56 : 80),
                          ),
                          SizedBox(height: isMobile ? 24 : 32),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 26 : 36,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: isMobile ? 0.4 : 1.2,
                            ),
                          ),
                          if (item.subtitle != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              item.subtitle!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 20,
                                color: Colors.amber, 
                                fontWeight: FontWeight.w600,
                                letterSpacing: isMobile ? 0.2 : 1,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Text(
                              item.content,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 20,
                                color: textColor.withOpacity(0.8),
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Hint text
              Padding(
                padding: EdgeInsets.only(bottom: isMobile ? 16 : 24),
                child: Text(
                  'Swipe to explore more • Auto-scroll every 5s',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: textColor.withOpacity(0.4),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Pages ---

class ProfilePage extends StatelessWidget {
  final bool isDark;
  const ProfilePage({super.key, required this.isDark});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String url,
    required bool isDark,
  }) {
    final isMobile = Responsive.isMobile(context);
    final isNarrow = MediaQuery.sizeOf(context).width < 380;
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 14 : isMobile ? 18 : 24,
          vertical: isMobile ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.black, size: isMobile ? 20 : 24),
            SizedBox(width: isMobile ? 8 : 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final screenSize = MediaQuery.sizeOf(context);
    final isShortMobile = isMobile && screenSize.height < 740;
    final isNarrowMobile = isMobile && screenSize.width < 380;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final scaffoldBg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA);
    final Color gradStart = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
    final pagePadding = isMobile
        ? EdgeInsets.fromLTRB(16, isShortMobile ? 88 : 100, 16, 32)
        : const EdgeInsets.fromLTRB(40, 96, 40, 40);
    final avatarRadius = isMobile ? (isShortMobile ? 44.0 : 52.0) : 80.0;
    final nameFontSize = isMobile ? (isNarrowMobile ? 24.0 : 28.0) : 48.0;
    final introSpacing = isMobile ? (isShortMobile ? 20.0 : 24.0) : 40.0;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.8, -0.6),
              radius: 1.5,
              colors: [gradStart, scaffoldBg],
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final minContentHeight = isMobile
                ? 0.0
                : (constraints.maxHeight - pagePadding.vertical).clamp(0.0, double.infinity).toDouble();

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: pagePadding,
              child: SizedBox(
                width: double.infinity,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minContentHeight),
                  child: Column(
                    mainAxisAlignment: isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orangeAccent],
                  ),
                ),
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundImage: AssetImage('assets/bomz.jpg'),
                ),
              ),
              SizedBox(height: isMobile ? 18 : 32),
              Text(
                'Mr.Jessadakorn Nantasupawatana',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: nameFontSize,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                ),
              ),
              Text(
                'Information Technology Student',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 20,
                  color: Colors.amber,
                  letterSpacing: isMobile ? 0.8 : 2,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: introSpacing),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: PremiumCard(
                  isDark: isDark,
                  child: Column(
                    children: [
                      Text(
                        'PASSIONATE FULL-STACK DEVELOPER, TECH ENTHUSIAST AND PROMPT ENGINEER',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 18,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'I am a student at Kasetsart University specializing in Information Technology. I enjoy building modern, high-performance applications and exploring new technologies. I’m currently working toward becoming a full-stack developer, with growing interests in cybersecurity and system engineering.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 16,
                          color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 24 : 60),
              // Navigation Buttons at bottom center
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildSocialButton(
                    context: context,
                    icon: Icons.code,
                    label: 'GitHub',
                    url: 'https://github.com/Jessadakorn-hbo/coop-exam',
                    isDark: isDark,
                  ),
                  _buildSocialButton(
                    context: context,
                    icon: Icons.facebook,
                    label: 'Facebook',
                    url: 'https://www.facebook.com/jessadakorn.nantasupawatana.2024',
                    isDark: isDark,
                  ),
                ],
              ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ContactPage extends StatelessWidget {
  final bool isDark;
  const ContactPage({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA);
    final Color gradStart = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.8, -0.6),
          radius: 1.5,
          colors: [gradStart, scaffoldBg],
        ),
      ),
      child: ListView(
        padding: Responsive.pagePadding(context),
        children: [
          PremiumSectionTitle(title: 'Contact Information', isDark: isDark),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildContactItem(context, Icons.location_on, 'ADDRESS', 'Ratchapruek, Nonthaburi, Thailand', isDark),
              _buildContactItem(context, Icons.email, 'EMAIL', 'Jessadakorn.na@ku.th', isDark),
              _buildContactItem(context, Icons.phone, 'PHONE', '099-757-1251', isDark),
              _buildContactItem(context, Icons.chat, 'LINE ID', 'Hulkbigolo', isDark),
              _buildContactItem(context, Icons.facebook, 'FACEBOOK', 'Jessadakorn Nantasupawatana', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String label, String value, bool isDark) {
    return PremiumCard(
      isDark: isDark,
      width: Responsive.cardWidth(context, 350),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.amber, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white.withOpacity(0.5) : Colors.black45,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
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
}

class SkillsPage extends StatelessWidget {
  final bool isDark;
  const SkillsPage({super.key, required this.isDark});

  // รายการข้อมูลสำหรับหน้า Skills พร้อมระบุ Tags สำหรับแต่ละอัน
  List<DetailItem> _getSkillItems() {
    return [
      DetailItem(
        title: 'Languages', 
        icon: Icons.language,
        tags: ['Thai (Native)', 'English (Professional)'],
        content: 'Native proficiency in English and Thai. Capable of technical documentation and international collaboration. have been teaching and accepting English traslation jobs for 5 years.'
      ),
      DetailItem(
        title: 'Programming', 
        icon: Icons.code,
        tags: ['Dart (Flutter)', 'Python', 'JavaScript', 'Angular'],
        content: 'Experienced in cross-platform mobile development with Flutter, backend scripting with Python, and frontend web technologies like Angular.'
      ),
      DetailItem(
        title: 'Database', 
        icon: Icons.storage,
        tags: ['MySQL', 'PostgreSQL', 'Firebase', 'Supabase'],
        content: 'Skilled in relational database design (MySQL, PostgreSQL, Supabase) and NoSQL solutions like Firebase for real-time applications.'
      ),
      DetailItem(
        title: 'Design & Tools', 
        icon: Icons.architecture,
        tags: ['ChatGPT', 'VS Code', 'Git', 'Figma', 'Postman'],
        content: 'Proficient in modern development workflows, version control with Git, UI/UX design in Figma, and API testing with Postman.'
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _getSkillItems();
    return Container(
      color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA),
      child: ListView(
        padding: Responsive.pagePadding(context),
        children: [
          PremiumSectionTitle(title: 'Technical Skills', isDark: isDark),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: List.generate(items.length, (index) {
              final item = items[index];
              return _buildSkillCard(context, item, index, items, isDark);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(BuildContext context, DetailItem item, int index, List<DetailItem> allItems, bool isDark) {
    return InkWell(
      onTap: () => _showSwipeDialog(context, allItems, index, isDark),
      borderRadius: BorderRadius.circular(24),
      child: PremiumCard(
        isDark: isDark,
        width: 450, // เพิ่มความกว้างการ์ดเพื่อให้ใส่ Tag ได้สวยงาม
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.icon, color: Colors.amber, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // แสดงผลกล่องทักษะย่อย (Skill Tags) บนการ์ด
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (item.tags ?? []).map((tag) => _buildSkillTag(tag)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillTag(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          color: Colors.amber, 
          fontSize: 13,
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }

  void _showSwipeDialog(BuildContext context, List<DetailItem> items, int index, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => PremiumSwipeDialog(items: items, initialIndex: index, isDark: isDark),
    );
  }
}

class EducationPage extends StatelessWidget {
  final bool isDark;
  const EducationPage({super.key, required this.isDark});

  List<DetailItem> _getEduItems() {
    return [
      DetailItem(
        title: 'Bachelor of Science (IT)',
        subtitle: 'Kasetsart University',
        icon: Icons.school,
        content: 'Currently focusing on Cyber Security, Networking, Mobile Development, and Artificial Intelligence. Maintaining a strong academic record to take the internship.',
      ),
      DetailItem(
        title: 'High School Diploma',
        subtitle: 'Sarasas Witaed Samut Sakhon School',
        icon: Icons.history_edu,
        content: 'Graduated with honors in the Science-Math track. Developed a strong foundation in logic, mathematics, and was representative for Samut Sakhon province for Multi-skill English Competitions.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _getEduItems();
    return Container(
      color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA),
      child: ListView(
        padding: Responsive.pagePadding(context),
        children: [
          PremiumSectionTitle(title: 'Education', isDark: isDark),
          ...List.generate(items.length, (index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: InkWell(
                onTap: () => _showSwipeDialog(context, items, index, isDark),
                borderRadius: BorderRadius.circular(24),
                child: PremiumCard(
                  isDark: isDark,
                  child: Row(
                    children: [
                      Icon(item.icon, color: Colors.amber, size: 32),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: Responsive.isMobile(context) ? 17 : 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              item.subtitle ?? '',
                              style: const TextStyle(color: Colors.amber),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showSwipeDialog(BuildContext context, List<DetailItem> items, int index, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => PremiumSwipeDialog(items: items, initialIndex: index, isDark: isDark),
    );
  }
}

class HobbyPage extends StatelessWidget {
  final bool isDark;
  const HobbyPage({super.key, required this.isDark});

  List<DetailItem> _getHobbyItems() {
    return [
      DetailItem(title: 'Music', icon: Icons.music_note, content: 'Upbeat music like techno, hardstyle, pop, and soul/funk keeps me energized while working, while jazz, blues, and ballads help me relax and unwind.'),
      DetailItem(title: 'Gaming', icon: Icons.sports_esports, content: ' RPG\'s and Multiplaer PVE games , such as Helldivers 2 and Space Marines 2. I enjoy analyzing game mechanics and UI design.'),
      DetailItem(title: 'Biking (motorsports)', icon: Icons.sports_motorsports, content: 'I’ve always preferred motorcycles over cars since childhood. I enjoy the speed and adrenaline of riding, and currently ride a Kawasaki KSR, GPX Demon GR200R, and Honda CBR500R—always chasing the thrill.'),
      DetailItem(title: 'Model-kit Building', icon: Icons.smart_toy_outlined, content: 'I fell in love with Gunpla, which sparked my passion for detailed model kits and design. Since then, I’ve expanded into Star Wars collectibles—lightsabers, helmets, and figures from brands like Hasbro, Bandai, Tomy, and Hot Toys—and I’m currently diving into Warhammer 40K.'),
      DetailItem(title: 'Reading', icon: Icons.book, content: 'I enjoy reading everything from comics and manga to novels and light novels, along with mythology and the latest in scientific discovery.'),
      DetailItem(title: 'Muaythai', icon: Icons.sports_mma_outlined, content: 'I’ve grown up with a father who is an ex-Muaythai boxer, so me and my siblings grew up training the martial art.'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _getHobbyItems();
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width < 620 ? 1 : width < 980 ? 2 : 3;
    return Container(
      color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA),
      child: ListView(
        padding: Responsive.pagePadding(context),
        children: [
          PremiumSectionTitle(title: 'Interests & Hobbies', isDark: isDark),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: width < 620 ? 3.2 : 2.5,
            children: List.generate(items.length, (index) {
              final item = items[index];
              return InkWell(
                onTap: () => _showSwipeDialog(context, items, index, isDark),
                borderRadius: BorderRadius.circular(24),
                child: PremiumCard(
                  isDark: isDark,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, color: Colors.amber, size: 32),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showSwipeDialog(BuildContext context, List<DetailItem> items, int index, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => PremiumSwipeDialog(items: items, initialIndex: index, isDark: isDark),
    );
  }
}
