import 'package:flutter/material.dart';
import '../../utilities/export.dart';

class NutrientDetails extends StatefulWidget {
  final dynamic name;
  final dynamic calories;
  final dynamic fat;
  final dynamic protein;
  final dynamic carbohydrates;
  final dynamic sugars;
  final dynamic fiber;
  final dynamic cholesterol;
  final dynamic saturatedFats;
  final dynamic calcium;
  final dynamic iron;
  final dynamic potassium;
  final dynamic vitaminA;
  final dynamic vitaminC;
  final dynamic vitaminB12;
  final dynamic vitaminD;
  final dynamic vitaminE;
  final dynamic transFat;
  final dynamic sodium;
  final dynamic vitaminK;
  final dynamic monounsaturatedFat;
  final dynamic polyunsaturatedFat;
  final dynamic caffeine;
  final dynamic servingWeight1;
  final dynamic servingDescription1;
  final dynamic cardColor;

  const NutrientDetails({
    super.key,
    required this.name,
    required this.calories,
    required this.fat,
    required this.protein,
    required this.carbohydrates,
    required this.sugars,
    required this.fiber,
    required this.cholesterol,
    required this.saturatedFats,
    required this.calcium,
    required this.iron,
    required this.potassium,
    required this.vitaminA,
    required this.vitaminC,
    required this.vitaminB12,
    required this.vitaminD,
    required this.vitaminE,
    required this.transFat,
    required this.sodium,
    required this.vitaminK,
    required this.monounsaturatedFat,
    required this.polyunsaturatedFat,
    required this.caffeine,
    required this.servingWeight1,
    required this.servingDescription1,
    this.cardColor,
  });

  @override
  State<NutrientDetails> createState() => _NutrientDetailsState();
}

class _NutrientDetailsState extends State<NutrientDetails> {
  final List<bool> _isOpen = [false, false];
  bool isDarkMode(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: isDarkMode(context)
          ? Theme.of(context).cardColor
          : Colors.primaries[widget.cardColor].shade50,
      body: Stack(
        children: [
          Positioned(
            right: 15,
            top: 10,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.primaries[widget.cardColor].shade300),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.primaries[widget.cardColor].shade200),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.primaries[widget.cardColor].shade200),
            ),
          ),
          Positioned(
            bottom: 40,
            right: MediaQuery.of(context).size.width / 2.8,
            child: Container(
              height: 85,
              width: 85,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.primaries[widget.cardColor].shade300),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height / 3,
            right: 0,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.primaries[widget.cardColor].shade100),
            ),
          ),
          Positioned(
            top: 40,
            right: MediaQuery.of(context).size.width / 1.65,
            child: Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.primaries[widget.cardColor].shade100),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.primaries[widget.cardColor].shade100),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [shadow]),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nutrition Facts",
                          style: Theme.of(context).textTheme.headlineSmall),
                      const Divider(color: color),
                      Text(widget.name, style: theme.titleMedium),
                      const Divider(color: color),
                      Text("Serving Size:",
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text(
                        widget.servingDescription1 == ''
                            ? widget.servingDescription1 +
                                "" +
                                widget.servingWeight1 +
                                " g"
                            : widget.servingDescription1 +
                                ", " +
                                widget.servingWeight1 +
                                " g",
                        style: theme.titleMedium,
                      ),
                      const Divider(color: color, height: 15, thickness: 6),
                      Text("Amount Per 100 g", style: theme.titleMedium),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Calories", style: theme.headlineSmall),
                          Text(widget.calories, style: theme.headlineSmall)
                        ],
                      ),
                      const Divider(color: color, height: 15, thickness: 6),
                      const SizedBox(height: 4),
                      const NutrientWidgetSmall(
                          name: "Nutrient Name", value: "Amount"),
                      NutrientWidget(
                          name: "Total Fat", value: widget.fat + " g"),
                      NutrientWidgetSmall(
                          name: "Saturated Fat",
                          value: widget.saturatedFats + " g"),
                      NutrientWidgetSmall(
                          name: "Trans Fat", value: widget.transFat + " g"),
                      NutrientWidgetSmall(
                          name: "Polyunsaturated Fat",
                          value: widget.polyunsaturatedFat + " mg"),
                      NutrientWidgetSmall(
                          name: "Monounsaturated Fat",
                          value: widget.monounsaturatedFat + " mg"),
                      NutrientWidget(
                          name: "Cholesterol",
                          value: widget.cholesterol + " mg"),
                      NutrientWidget(
                          name: "Sodium", value: widget.sodium + " mg"),
                      NutrientWidget(
                          name: "Total Carbohydrates",
                          value: widget.carbohydrates + " g"),
                      NutrientWidgetSmall(
                          name: "Dietary Fiber", value: widget.fiber + " g"),
                      NutrientWidgetSmall(
                          name: "Sugars", value: widget.sugars + " g"),
                      NutrientWidget(
                          name: "Protein", value: widget.protein + " g"),
                      const Divider(color: color),
                      ExpansionPanelList(
                        elevation: 0,
                        expansionCallback: (i, isOpen) {
                          setState(() {
                            _isOpen[i] = !isOpen;
                          });
                        },
                        children: [
                          ExpansionPanel(
                            canTapOnHeader: true,
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Other Nutrients",
                                      style: theme.titleSmall)
                                ],
                              );
                            },
                            body: Column(
                              children: [
                                NutrientWidgetSmall(
                                    name: "Calcium",
                                    value: widget.calcium + " mg"),
                                NutrientWidgetSmall(
                                    name: "Iron", value: widget.iron + " mg"),
                                NutrientWidgetSmall(
                                    name: "Potassium",
                                    value: widget.potassium + " mg"),
                                NutrientWidgetSmall(
                                    name: "Caffeine",
                                    value: widget.caffeine + " mg"),
                              ],
                            ),
                            isExpanded: _isOpen[0],
                          ),
                          ExpansionPanel(
                            canTapOnHeader: true,
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Vitamins", style: theme.titleSmall)
                                ],
                              );
                            },
                            body: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      NutrientWidgetSmall(
                                          name: "Vitamin A",
                                          value: widget.vitaminA + " mcg"),
                                      NutrientWidgetSmall(
                                          name: "Vitamin B-12",
                                          value: widget.vitaminB12 + " mcg"),
                                      NutrientWidgetSmall(
                                          name: "Vitamin C",
                                          value: widget.vitaminC + " mg"),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    children: [
                                      NutrientWidgetSmall(
                                          name: "Vitamin D",
                                          value: widget.vitaminD + " mcg"),
                                      NutrientWidgetSmall(
                                          name: "Vitamin E",
                                          value: widget.vitaminE + " mg"),
                                      NutrientWidgetSmall(
                                          name: "Vitamin K",
                                          value: widget.vitaminK + " mcg"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            isExpanded: _isOpen[1],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
