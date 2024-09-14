import 'dart:convert';

List<RecipesModel> recipesModelFromJson(String str) => List<RecipesModel>.from(
    json.decode(str).map((x) => RecipesModel.fromJson(x)));

String recipesModelToJson(List<RecipesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RecipesModel {
  RecipesModel({
    required this.description,
    required this.keywords,
    required this.name,
    required this.slug,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.cookTime,
    required this.prepTime,
    required this.totalTime,
    required this.score,
    required this.protein,
    required this.fat,
    required this.calories,
    required this.sugar,
    required this.carbohydrates,
    required this.fiber,
  });

  String description;
  String keywords;
  String name;
  String slug;
  String videoUrl;
  String thumbnailUrl;
  String cookTime;
  String prepTime;
  String totalTime;
  String score;
  String protein;
  String fat;
  String calories;
  String sugar;
  String carbohydrates;
  String fiber;

  factory RecipesModel.fromJson(Map<String, dynamic> json) => RecipesModel(
        description: json["description"],
        keywords: json["keywords"],
        name: json["name"],
        slug: json["slug"],
        videoUrl: json["video_url"],
        thumbnailUrl: json["thumbnail_url"],
        cookTime: json["cook_time"],
        prepTime: json["prep_time"],
        totalTime: json["total_time"],
        score: json["score"],
        protein: json["protein"],
        fat: json["fat"],
        calories: json["calories"],
        sugar: json["sugar"],
        carbohydrates: json["carbohydrates"],
        fiber: json["fiber"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "keywords": keywords,
        "name": name,
        "slug": slug,
        "video_url": videoUrl,
        "thumbnail_url": thumbnailUrl,
        "cook_time": cookTime,
        "prep_time": prepTime,
        "total_time": totalTime,
        "score": score,
        "protein": protein,
        "fat": fat,
        "calories": calories,
        "sugar": sugar,
        "carbohydrates": carbohydrates,
        "fiber": fiber,
      };
}
