import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_glass_morphism/flutter_glass_morphism.dart';

import '../home/home_view.dart';
import '../present/present_view.dart';
import '../absent/absent_view.dart';
import '../scan/scan_view.dart';
import 'main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  Widget _loadPage(int index) {
    switch (index) {
      case 0:
        return const HomeView();
      case 1:
        return const ScanView();
      case 2:
        return const PresentView();
      case 3:
        return const AbsentView();
      default:
        return const HomeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      // ==============================
      // PAGE CONTENT (TANPA ANIMASI)
      // ==============================
      body: Obx(() {
        return _loadPage(controller.pageIndex.value);
      }),

      // ==============================
      // FLOATING GLASS NAV BAR
      // ==============================
      bottomNavigationBar: Obx(() {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
          child: GlassEffects.dynamicGlass(
            animation: const AlwaysStoppedAnimation(1),
            maxBlur: 30,
            minBlur: 12,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),

                // Glass background
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.20),
                    Colors.white.withOpacity(0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                border: Border.all(
                  color: Colors.white.withOpacity(0.28),
                  width: 1.3,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: _navBar(),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ==============================
  // NAV BAR (RINGAN & RESPONSIF)
  // ==============================
  Widget _navBar() {
    final items = [
      (CupertinoIcons.home, "Beranda"),
      (CupertinoIcons.qrcode_viewfinder, "Scan"),
      (CupertinoIcons.check_mark_circled, "Hadir"),
      (CupertinoIcons.timer, "Belum"),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(items.length, (i) {
        final isActive = controller.pageIndex.value == i;

        return GestureDetector(
          onTap: () => controller.changePage(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
              horizontal: isActive ? 16 : 10,
              vertical: isActive ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withOpacity(0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  items[i].$1,
                  size: isActive ? 26 : 22,
                  color: isActive
                      ? Colors.black.withOpacity(0.85)
                      : Colors.black.withOpacity(0.55),
                ),
                if (isActive) ...[
                  const SizedBox(width: 6),
                  Text(
                    items[i].$2,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
