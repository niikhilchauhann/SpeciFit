import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:specifit/screens/mainScreens/more.dart';
import '../screens/mainScreens/home.dart';
import '../screens/mainScreens/recipes.dart';
import '../screens/mainScreens/food_diary.dart';
import '../screens/mainScreens/workouts.dart';

class MobileStructure extends StatefulWidget {
  const MobileStructure({Key? key}) : super(key: key);

  @override
  MobileStructureState createState() => MobileStructureState();
}

class MobileStructureState extends State<MobileStructure> {
  List<Widget> screens = [
    const Dashboard(),
    const Meals(),
    const Workouts(),
    const Nutrients(),
    const More()
  ];
  int selectedIndex = 0;

  List<Color> colors = [
    Colors.red,
    Colors.teal,
    Colors.amber.shade800,
    Colors.cyan.shade800,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: kElevationToShadow[4]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: GNav(
            gap: 8,
            haptic: true,
            textStyle: TextStyle(
                fontSize: 14,
                color: colors[selectedIndex],
                fontWeight: FontWeight.w600),
            activeColor: colors[selectedIndex],
            iconSize: 20,
            tabBackgroundColor: colors[selectedIndex].withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            duration: const Duration(milliseconds: 400),
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.fastfood,
                text: 'Meals',
              ),
              GButton(
                icon: Icons.sports_gymnastics,
                text: 'Workouts',
              ),
              GButton(
                icon: CupertinoIcons.flame_fill,
                text: 'Diary',
              ),
              GButton(
                icon: Icons.menu_rounded,
                text: 'More',
              )
            ],
            selectedIndex: selectedIndex,
            onTabChange: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
