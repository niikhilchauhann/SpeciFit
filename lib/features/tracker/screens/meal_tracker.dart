import '/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '/data/adapters/meal_adapter.dart';
import '/features/search/screens/widgets/macro_widget.dart';

class MealCalendarScreen extends StatefulWidget {
  const MealCalendarScreen({super.key});

  @override
  State<MealCalendarScreen> createState() => _MealCalendarScreenState();
}

class _MealCalendarScreenState extends State<MealCalendarScreen> {
  late Box<Calories> caloriesBox;
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier(DateTime.now());

  @override
  void initState() {
    super.initState();
    caloriesBox = Hive.box<Calories>('calories');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectDate(context);
    });
  }

  @override
  void dispose() {
    _selectedDate.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 182)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate.value) {
      _selectedDate.value = picked;
    }
  }

  List<Calories> _getCaloriesForSelectedDate() {
    List<Calories> caloriesList = [];
    for (int i = 0; i < caloriesBox.length; i++) {
      Calories calories = caloriesBox.getAt(i)!;
      if (calories.date == _selectedDate.value) {
        caloriesList.add(calories);
      }
    }
    return caloriesList;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Calorie Tracker"),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_selectedDate, caloriesBox.listenable()]),
        builder: (context, child) {
          double totalCalories = 0;
          double totalProtein = 0;
          double totalCarbs = 0;
          double totalFat = 0;

          List<Calories> todaysCalories = _getCaloriesForSelectedDate();
          for (var cal in todaysCalories) {
            totalCalories += cal.calories;
            totalProtein += cal.protein;
            totalCarbs += cal.carbohydrates;
            totalFat += cal.fat;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: .3)),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
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
                          '${DateFormat.yMMMEd().format(_selectedDate.value)} ▼',
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
                          macro: '${totalCalories.toStringAsFixed(0)} kcal',
                          macroname: "Calories",
                          macrocolor: AppColors.instance.caloriesColor,
                        ),
                        MacroWidget(
                          macro: '${totalProtein.toStringAsFixed(1)} g',
                          macroname: "Protein",
                          macrocolor: AppColors.instance.proteinColor,
                        ),
                        MacroWidget(
                          macro: '${totalCarbs.toStringAsFixed(1)} g',
                          macroname: "Carbs",
                          macrocolor: AppColors.instance.carbsColor,
                        ),
                        MacroWidget(
                          macro: '${totalFat.toStringAsFixed(1)} g',
                          macroname: "Fat",
                          macrocolor: AppColors.instance.fatColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Food Dairy', style: theme.titleMedium),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
                  itemCount: todaysCalories.length,
                  itemBuilder: (context, index) {
                    Calories calories = todaysCalories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey(calories.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          int boxIndex = caloriesBox.values.toList().indexOf(
                            calories,
                          );
                          if (boxIndex != -1) {
                            caloriesBox.deleteAt(boxIndex);
                          }
                        },
                        background: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red.shade400,
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          ),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
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
                              style: theme.labelMedium,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
