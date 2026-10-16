import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/core/data/app_data.dart';

class HomeBannerSection extends StatefulWidget {
  const HomeBannerSection({super.key});

  @override
  State<HomeBannerSection> createState() => _HomeBannerSectionState();
}

class _HomeBannerSectionState extends State<HomeBannerSection> {
  final _bannerCtrl = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  static const _colors = [
    [Color(0xFF922B21), Color(0xFFE74C3C)],
    [Color(0xFF6C3483), Color(0xFF8E44AD)],
    [Color(0xFF1A5276), Color(0xFF2980B9)],
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerCtrl.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_bannerCtrl.hasClients) return;
      final bannerCount = AppData.banners.length;
      final nextPage = (_bannerIndex + 1) % bannerCount;
      _bannerCtrl.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const banners = AppData.banners;
    return Column(children: [
      SizedBox(
        height: 170,
        child: PageView.builder(
          controller: _bannerCtrl,
          onPageChanged: (i) => setState(() => _bannerIndex = i),
          itemCount: banners.length,
          itemBuilder: (_, i) {
            final b = banners[i];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: _colors[i],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(children: [
                Positioned(
                    right: -20,
                    bottom: -20,
                    child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle))),
                Positioned(
                    right: 30,
                    top: -30,
                    child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            shape: BoxShape.circle))),
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(b['tag']!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 12),
                        Text(b['title']!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5)),
                        const SizedBox(height: 6),
                        Text(b['subtitle']!,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12)),
                      ],
                    )),
              ]),
            );
          },
        ),
      ),
      const SizedBox(height: 12),
      AnimatedSmoothIndicator(
        activeIndex: _bannerIndex,
        count: banners.length,
        effect: ExpandingDotsEffect(
            activeDotColor: AppTheme.primary,
            dotColor: AppTheme.textLight.withValues(alpha: 0.3),
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 3),
      ),
    ]);
  }
}
