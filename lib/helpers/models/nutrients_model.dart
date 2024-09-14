import 'dart:convert';

List<NutrientsModel> nutrientsModelFromJson(String str) =>
    List<NutrientsModel>.from(
        json.decode(str).map((x) => NutrientsModel.fromJson(x)));

String nutrientsModelToJson(List<NutrientsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NutrientsModel {
  NutrientsModel({
    required this.keywords,
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
  });

  String keywords;
  String name;
  String calories;
  String fat;
  String protein;
  String carbohydrates;
  String sugars;
  String fiber;
  String cholesterol;
  String saturatedFats;
  String calcium;
  String iron;
  String potassium;
  String vitaminA;
  String vitaminC;
  String vitaminB12;
  String vitaminD;
  String vitaminE;
  String transFat;
  String sodium;
  String vitaminK;
  String monounsaturatedFat;
  String polyunsaturatedFat;
  String caffeine;
  String servingWeight1;
  String servingDescription1;

  factory NutrientsModel.fromJson(Map<String, dynamic> json) => NutrientsModel(
        keywords: json["keywords"],
        name: json["name"],
        calories: json["calories"],
        fat: json["fat"],
        protein: json["protein"],
        carbohydrates: json["carbohydrates"],
        sugars: json["sugars"],
        fiber: json["fiber"],
        cholesterol: json["cholesterol"],
        saturatedFats: json["saturatedFats"],
        calcium: json["calcium"],
        iron: json["iron"],
        potassium: json["potassium"],
        vitaminA: json["vitaminA"],
        vitaminC: json["vitaminC"],
        vitaminB12: json["vitaminB12"],
        vitaminD: json["vitaminD"],
        vitaminE: json["vitaminE"],
        transFat: json["transFat"],
        sodium: json["sodium"],
        vitaminK: json["vitaminK"],
        monounsaturatedFat: json["monounsaturatedFat"],
        polyunsaturatedFat: json["polyunsaturatedFat"],
        caffeine: json["caffeine"],
        servingWeight1: json["servingWeight1"],
        servingDescription1: json["servingDescription1"],
      );

  Map<String, dynamic> toJson() => {
        "keywords": keywords,
        "name": name,
        "calories": calories,
        "fat": fat,
        "protein": protein,
        "carbohydrates": carbohydrates,
        "sugars": sugars,
        "fiber": fiber,
        "cholesterol": cholesterol,
        "saturatedFats": saturatedFats,
        "calcium": calcium,
        "iron": iron,
        "potassium": potassium,
        "vitaminA": vitaminA,
        "vitaminC": vitaminC,
        "vitaminB12": vitaminB12,
        "vitaminD": vitaminD,
        "vitaminE": vitaminE,
        "transFat": transFat,
        "sodium": sodium,
        "vitaminK": vitaminK,
        "monounsaturatedFat": monounsaturatedFat,
        "polyunsaturatedFat": polyunsaturatedFat,
        "caffeine": caffeine,
        "servingWeight1": servingWeight1,
        "servingDescription1": servingDescription1,
      };
}

List<NutrientsModel> nutrientList = [
  NutrientsModel(
    keywords: "Bread Chapati Or Roti Whole Wheat Commercially Prepared Frozen",
    name: "Bread Chapati Or Roti Whole Wheat Commercially Prepared Frozen",
    calories: "299",
    fat: "9.2",
    protein: "7.85",
    carbohydrates: "46.13",
    sugars: "2.93",
    fiber: "9.7",
    cholesterol: "0",
    saturatedFats: "3.311",
    calcium: "36",
    iron: "2.2",
    potassium: "196",
    vitaminA: "0",
    vitaminC: "0",
    vitaminB12: "0",
    vitaminD: "0",
    vitaminE: "0.55",
    transFat: "0.029",
    sodium: "298",
    vitaminK: "3.3",
    monounsaturatedFat: "2091",
    polyunsaturatedFat: "761",
    caffeine: "0",
    servingWeight1: "43",
    servingDescription1: "1 piece",
  ),
  NutrientsModel(
    keywords: "Egg Scrambled",
    name: "Egg Scrambled",
    calories: "212",
    fat: "16.18",
    protein: "13.84",
    carbohydrates: "2.08",
    sugars: "1.64",
    fiber: "0",
    cholesterol: "426",
    saturatedFats: "6.153",
    calcium: "57",
    iron: "2.59",
    potassium: "147",
    vitaminA: "176",
    vitaminC: "3.3",
    vitaminB12: "1.01",
    vitaminD: "1.1",
    vitaminE: "0.96",
    transFat: "NULL",
    sodium: "187",
    vitaminK: "9",
    monounsaturatedFat: "5889",
    polyunsaturatedFat: "1969",
    caffeine: "0",
    servingWeight1: "96",
    servingDescription1: "2 eggs",
  ),
  NutrientsModel(
    keywords: "Milk Shakes Thick Chocolate",
    name: "Milk Shakes Thick Chocolate",
    calories: "119",
    fat: "2.7",
    protein: "3.05",
    carbohydrates: "21.15",
    sugars: "20.85",
    fiber: "0.3",
    cholesterol: "11",
    saturatedFats: "1.681",
    calcium: "132",
    iron: "0.31",
    potassium: "224",
    vitaminA: "18",
    vitaminC: "0",
    vitaminB12: "0.32",
    vitaminD: "1",
    vitaminE: "0.05",
    transFat: "NULL",
    sodium: "111",
    vitaminK: "0.2",
    monounsaturatedFat: "780",
    polyunsaturatedFat: "100",
    caffeine: "2",
    servingWeight1: "28.4",
    servingDescription1: "1 fl oz",
  ),
  NutrientsModel(
    keywords: "Taco Bell Burrito Supreme With Chicken",
    name: "Taco Bell Burrito Supreme With Chicken",
    calories: "179",
    fat: "6.42",
    protein: "9.84",
    carbohydrates: "20.51",
    sugars: "NULL",
    fiber: "2.4",
    cholesterol: "21",
    saturatedFats: "2.352",
    calcium: "94",
    iron: "1.56",
    potassium: "264",
    vitaminA: "4",
    vitaminC: "NULL",
    vitaminB12: "0.33",
    vitaminD: "NULL",
    vitaminE: "0.42",
    transFat: "NULL",
    sodium: "564",
    vitaminK: "5.3",
    monounsaturatedFat: "2560",
    polyunsaturatedFat: "795",
    caffeine: "NULL",
    servingWeight1: "248",
    servingDescription1: "1 item",
  ),
];
