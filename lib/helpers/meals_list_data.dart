class MealsListData {
  MealsListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.meals,
  });

  String imagePath;
  String titleTxt;
  dynamic startColor;
  dynamic endColor;
  List<String>? meals;

  static List<MealsListData> tabIconsList = <MealsListData>[
    MealsListData(
      imagePath: 'assets/fitness_app/breakfast.png',
      titleTxt: 'Breakfast',
      meals: <String>['Bread,', 'Peanut butter,', 'Milk'],
      startColor: 0xFFFA7D82,
      endColor: 0xFFFFB295,
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/lunch.png',
      titleTxt: 'Lunch',
      meals: <String>['Omelette,', 'Rice,', 'Mixed veggies'],
      startColor: 0xFF738AE6,
      endColor: 0xFF5C5EDD,
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/snack.png',
      titleTxt: 'Snack',
      meals: <String>['Apple,', 'Avocado'],
      startColor: 0xFFFE95B6,
      endColor: 0xFFFF5287,
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/dinner.png',
      titleTxt: 'Dinner',
      meals: <String>['Eggs,', 'Chapati,', 'Salad'],
      startColor: 0xFF6F72CA,
      endColor: 0xFF1E1466,
    ),
  ];
}
