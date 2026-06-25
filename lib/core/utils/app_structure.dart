import '/core/utils/exports.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '/core/providers/theme_provider.dart';
import '/features/home/screens/home_screen.dart';
import '/features/profile/screens/profile_screen.dart';
import '/features/search/screens/search_screen.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import '/features/workouts/screens/workouts.dart';

import 'package:sidebarx/sidebarx.dart';

class AppStructure extends ConsumerStatefulWidget {
  const AppStructure({super.key});

  @override
  ConsumerState<AppStructure> createState() => _AppStructureState();
}

class _AppStructureState extends ConsumerState<AppStructure> {
  final ValueNotifier<int> _updateState = ValueNotifier(0);

  late SidebarXController sidebarController;
  int _currentIndex = 0;

  final List<Widget> screens = [
    HomeScreen(),
    SearchScreen(),
    Workouts(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarXController(
      selectedIndex: _currentIndex,
      extended: true,
    );

    // Add a listener to update _currentIndex when the sidebar index changes
    sidebarController.addListener(() {
      _currentIndex = sidebarController.selectedIndex;
      _updateState.value++;
    });
  }

  @override
  void dispose() {
    sidebarController.dispose();
    super.dispose();
  }

  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return ValueListenableBuilder(
      valueListenable: _updateState,
      builder: (context, _, __) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: isDarkMode
                ? AppColors.instance.surfaceDark
                : AppColors.instance.surface,
            systemNavigationBarIconBrightness: isDarkMode
                ? Brightness.light
                : Brightness.dark,
          ),
          child: Scaffold(
            key: _key,
            appBar: AppBar(
              leading: kIsWeb
                  ? IconButton.filled(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateColor.resolveWith(
                          (states) => AppColors.instance.surface,
                        ),
                      ),
                      onPressed: () {
                        _key.currentState?.openDrawer();
                      },
                      icon: Icon(
                        Icons.menu,
                        color: AppColors.instance.onSurface,
                        size: 22,
                      ),
                    )
                  : null,
              title: const Text('SpeciFit'),
              actions: [
                IconButton(
                  onPressed: () {
                    ref.read(themeProvider.notifier).changeTheme();
                  },
                  icon: const Icon(Icons.dark_mode),
                ),
              ],
            ),
            body: kIsWeb
                ? Row(
                    children: [
                      CustomSidebar(controller: sidebarController),
                      Expanded(
                        child: IndexedStack(
                          index: _currentIndex,
                          children: screens,
                        ),
                      ),
                    ],
                  )
                : IndexedStack(index: _currentIndex, children: screens),
            bottomNavigationBar: kIsWeb
                ? null
                : FlashyTabBar(
                    animationCurve: Curves.linear,
                    selectedIndex: _currentIndex,
                    iconSize: 30,
                    showElevation: true,
                    onItemSelected: (index) {
                      _currentIndex = index;
                      sidebarController.selectIndex(
                        index,
                      ); // Sync sidebar with bottom navigation
                      _updateState.value++;
                    },
                    backgroundColor: isDarkMode
                        ? AppColors.instance.surfaceDark
                        : AppColors.instance.surface,
                    animationDuration: const Duration(milliseconds: 500),
                    items: [
                      FlashyTabBarItem(
                        icon: const Icon(Icons.home),
                        title: const Text('Home'),
                        activeColor: isDarkMode
                            ? AppColors.instance.onSecondary
                            : AppColors.instance.onSurface,
                        inactiveColor: isDarkMode
                            ? AppColors.instance.secondary
                            : AppColors.instance.primary,
                      ),
                      FlashyTabBarItem(
                        icon: const Icon(Icons.search),
                        title: const Text('Search'),
                        activeColor: isDarkMode
                            ? AppColors.instance.onSecondary
                            : AppColors.instance.onSurface,
                        inactiveColor: isDarkMode
                            ? AppColors.instance.secondary
                            : AppColors.instance.primary,
                      ),
                      FlashyTabBarItem(
                        icon: const Icon(Icons.sports_gymnastics),
                        title: const Text('Workouts'),
                        activeColor: isDarkMode
                            ? AppColors.instance.onSecondary
                            : AppColors.instance.onSurface,
                        inactiveColor: isDarkMode
                            ? AppColors.instance.secondary
                            : AppColors.instance.primary,
                      ),
                      FlashyTabBarItem(
                        icon: const Icon(Icons.person),
                        title: const Text('Profile'),
                        activeColor: isDarkMode
                            ? AppColors.instance.onSecondary
                            : AppColors.instance.onSurface,
                        inactiveColor: isDarkMode
                            ? AppColors.instance.secondary
                            : AppColors.instance.primary,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class CustomSidebar extends ConsumerWidget {
  const CustomSidebar({super.key, required this.controller});

  final SidebarXController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    return SafeArea(
      child: SidebarX(
        controller: controller,
        theme: SidebarXTheme(
          width: controller.extended ? 260 : 80,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.instance.surfaceDark
                : AppColors.instance.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          hoverColor: Colors.grey[200]!,
          textStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          selectedTextStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          itemPadding: const EdgeInsets.all(16),
          selectedItemPadding: const EdgeInsets.all(16),
          itemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey),
          ),
          padding: EdgeInsets.all(10),
          selectedItemDecoration: BoxDecoration(
            color: isDark ? Colors.black54 : Colors.grey[300]!,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black),
          ),
          iconTheme: IconThemeData(
            color: isDark ? Colors.white70 : Colors.black54,
            size: 20,
          ),
          selectedIconTheme: IconThemeData(
            color: isDark ? Colors.white70 : Colors.black54,
            size: 20,
          ),
        ),
        items: [
          SidebarXItem(
            icon: Icons.home,
            label: ' Home',
            onTap: () => controller.selectIndex(0),
          ),
          SidebarXItem(
            icon: Icons.search,
            label: ' Search',
            onTap: () => controller.selectIndex(1),
          ),
          SidebarXItem(
            icon: Icons.sports_gymnastics,
            label: ' Workouts',
            onTap: () => controller.selectIndex(2),
          ),
          SidebarXItem(
            icon: Icons.person,
            label: ' Profile',
            onTap: () => controller.selectIndex(3),
          ),
        ],
      ),
    );
  }
}
