import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/data/models/exercise_model.dart';
import '/features/workouts/screens/exercise_tile.dart';

class SearchWorkouts extends StatefulWidget {
  const SearchWorkouts({super.key});

  @override
  State<SearchWorkouts> createState() => _SearchWorkoutsState();
}

class _SearchWorkoutsState extends State<SearchWorkouts> {
  final ValueNotifier<int> _updateState = ValueNotifier(0);

  List<Exercise> _allexercises = [];
  List<Exercise> _filteredexercises = [];

  Future<List<Exercise>> getApiData() async {
    final response = await http.get(
      Uri.parse('https://edcorp-specifit.github.io/APIs/exercises_api.json'),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<Exercise> exerciseList = [];
      for (var json in data) {
        Exercise exercise = Exercise.fromJson(json);
        exerciseList.add(exercise);
      }
      return exerciseList;
    } else {
      throw Exception('Failed to fetch exerciseList');
    }
  }

  TextEditingController searchController = TextEditingController();
  performSearch(value) {
    _filteredexercises = _allexercises
        .where(
          (exercise) =>
              exercise.name.toLowerCase().contains(value.toLowerCase()),
        )
        .toList();
    _updateState.value++;
  }

  @override
  void initState() {
    super.initState();
    getApiData().then((exerciseList) {
      _allexercises = exerciseList;
      _filteredexercises = exerciseList;
      _updateState.value++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _updateState,
      builder: (context, _, __) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios_rounded),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: performSearch,
                    decoration: InputDecoration(
                      hintText: 'Search any workout...',
                      hintStyle: Theme.of(context).textTheme.labelLarge,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    searchController.text = '';
                  },
                  child: const Icon(Icons.clear_rounded),
                ),
              ],
            ),
          ),
          body: ListView.builder(
            itemCount: _filteredexercises.length,
            itemBuilder: (context, index) {
              return ExerciseTile(
                bodyPart: _filteredexercises[index].bodyPart,
                equipment: _filteredexercises[index].equipment,
                gifUrl: _filteredexercises[index].gifUrl,
                name: _filteredexercises[index].name,
                target: _filteredexercises[index].target,
              );
            },
          ),
        );
      },
    );
  }
}
