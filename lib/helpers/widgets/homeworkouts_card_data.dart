import 'package:flutter/material.dart';

class HomeWorkoutData {
  HomeWorkoutData({
    required this.imageM,
    required this.imageW,
    required this.cardColor,
    required this.title,
    required this.subtitle,
    required this.calories,
    required this.time,
  });

  final String imageM;
  final String imageW;
  final String title;
  final String calories;
  final String time;
  final String subtitle;
  final dynamic cardColor;
  static List<HomeWorkoutData> workoutList = <HomeWorkoutData>[
    HomeWorkoutData(
      imageM: 'assets/images/workout/home_m.png',
      imageW: 'assets/images/workout/home_w.png',
      title: 'Home Workout',
      subtitle: 'No Equipments\nRequired',
      time: "25",
      calories: "350",
      cardColor: Colors.lightBlue.shade100,
    ),
    HomeWorkoutData(
      imageM: 'assets/images/workout/band_m.png',
      imageW: 'assets/images/workout/band_w.png',
      title: 'Resistance\nWorkout',
      subtitle: 'Using Resistance Bands',
      time: "10",
      calories: "350",
      cardColor: Colors.pink.shade100,
    ),
    HomeWorkoutData(
      imageM: 'assets/images/workout/db_m.png',
      imageW: 'assets/images/workout/db_w.png',
      title: 'Dumbbell Workout',
      subtitle: 'Using Dumbbells Only',
      time: "20",
      calories: "350",
      cardColor: Colors.red.shade100,
    ),
    HomeWorkoutData(
      imageM: 'assets/images/workout/yoga_m.png',
      imageW: 'assets/images/workout/yoga_w.png',
      title: 'Yoga',
      subtitle: 'Relaxing yoga & meditation sessions',
      time: "40",
      calories: "350",
      cardColor: Colors.orange.shade100,
    ),
    HomeWorkoutData(
      imageM: 'assets/images/workout/stretching_m.png',
      imageW: 'assets/images/workout/stretching_w.png',
      title: 'Flexiblity',
      subtitle: 'Stretch & make your\nbody flexible',
      time: "15",
      calories: "350",
      cardColor: Colors.teal.shade100,
    ),
    HomeWorkoutData(
      imageM: 'assets/images/workout/hiit_m.png',
      imageW: 'assets/images/workout/hiit_w.png',
      title: 'HIIT',
      subtitle: 'High Intensity Interval Training',
      time: "20",
      calories: "350",
      cardColor: Colors.cyan.shade100,
    ),
    HomeWorkoutData(
      imageM: 'assets/images/workout/weightloss_m.png',
      imageW: 'assets/images/workout/weightloss_w.png',
      title: 'Weight Loss',
      subtitle: 'Lose that stubborn belly\nfat in minutes',
      time: "30",
      calories: "350",
      cardColor: Colors.purple.shade100,
    ),
  ];
}
