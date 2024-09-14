import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../helpers/adapters/meal_adapter.dart';
import '../../utilities/export.dart';

class MealCalendarScreen extends StatefulWidget {
  const MealCalendarScreen({super.key});

  @override
  State<MealCalendarScreen> createState() => _MealCalendarScreenState();
}

class _MealCalendarScreenState extends State<MealCalendarScreen> {
  late Box<Calories> caloriesBox;
  Map<DateTime, int> _caloriesMap = {};
  late DateTime _selectedDate;

  void _updateTotals(DateTime date) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (int i = 0; i < caloriesBox.length; i++) {
      Calories calories = caloriesBox.getAt(i)!;
      if (calories.date == date) {
        totalCalories += calories.calories;
        totalProtein += calories.protein;
        totalCarbs += calories.carbohydrates;
        totalFat += calories.fat;
      }
    }

    setState(() {
      _totalCalories = totalCalories;
      _totalProtein = totalProtein;
      _totalCarbs = totalCarbs;
      _totalFat = totalFat;
    });
  }

  double _totalCalories = 0;
  double _totalProtein = 0;
  double _totalCarbs = 0;
  double _totalFat = 0;

  @override
  void initState() {
    super.initState();
    caloriesBox = Hive.box<Calories>('calories');
    _selectedDate = DateTime.now();
    _loadCalories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectDate(context);
    });
  }

  void _loadCalories() {
    setState(() {
      _caloriesMap = {};
      for (int i = 0; i < caloriesBox.length; i++) {
        Calories calories = caloriesBox.getAt(i)!;
        _caloriesMap[calories.date] = calories.calories.toInt();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 182)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _updateTotals(picked);
    }
  }

  List<Calories> _getCaloriesForSelectedDate() {
    List<Calories> caloriesList = [];
    for (int i = 0; i < caloriesBox.length; i++) {
      Calories calories = caloriesBox.getAt(i)!;
      if (calories.date == _selectedDate) {
        caloriesList.add(calories);
      }
    }
    return caloriesList;
  }

  @override
  Widget build(BuildContext context) {
    _updateTotals(_selectedDate);
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Calorie Tracker"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(.3)),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Select a date to see details',
                  style: theme.bodySmall,
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: SizedBox(
                    width: 110,
                    child: Text(
                      '${DateFormat.yMMMEd().format(_selectedDate)} ▼',
                      style: const TextStyle(
                        fontSize: 14,
                        wordSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MacroWidget(
                      macro: '${_totalCalories.toStringAsFixed(0)} kcal',
                      macroname: "Calories",
                      macrocolor: caloriescolor,
                    ),
                    MacroWidget(
                      macro: '${_totalProtein.toStringAsFixed(1)} g',
                      macroname: "Protein",
                      macrocolor: proteincolor,
                    ),
                    MacroWidget(
                      macro: '${_totalCarbs.toStringAsFixed(1)} g',
                      macroname: "Carbs",
                      macrocolor: carbscolor,
                    ),
                    MacroWidget(
                      macro: '${_totalFat.toStringAsFixed(1)} g',
                      macroname: "Fat",
                      macrocolor: fatcolor,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Food Dairy',
                  style: theme.titleMedium,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
              itemCount: _getCaloriesForSelectedDate().length,
              itemBuilder: (context, index) {
                Calories calories = _getCaloriesForSelectedDate()[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey(calories.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        caloriesBox.deleteAt(index);
                      });
                    },
                    background: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.red.shade400,
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child:
                          const Icon(Icons.delete_rounded, color: Colors.white),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        calories.name,
                        style: const TextStyle(
                          fontSize: 14,
                          wordSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                            'Calories: ${calories.calories.toStringAsFixed(0)}, Protein: ${calories.protein.toStringAsFixed(1)}, Carbs: ${calories.carbohydrates.toStringAsFixed(1)}, Fat: ${calories.fat.toStringAsFixed(1)}',
                            style: theme.labelMedium),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
