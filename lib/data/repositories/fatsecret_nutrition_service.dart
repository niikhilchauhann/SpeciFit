import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/nutrients_model.dart';
import 'nutrition_service.dart';

/// Calls the FatSecret proxy server (deployed on Render/Railway/etc.)
/// instead of calling FatSecret directly — this avoids the IP whitelist limitation.
///
/// Set FATSECRET_PROXY_URL in your .env file:
///   FATSECRET_PROXY_URL=https://your-proxy.onrender.com
class FatSecretNutritionService implements NutritionService {
  String get _baseUrl {
    final url = dotenv.env['FATSECRET_PROXY_URL'] ?? '';
    if (url.isEmpty) {
      debugPrint('[FatSecret] WARNING: FATSECRET_PROXY_URL not set in .env!');
    }
    return url.trimRight().replaceAll(RegExp(r'/$'), '');
  }

  // ──────────────────────────────────────────────
  //  Generic proxy call helper
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>?> _get(String path, Map<String, String> params) async {
    final base = _baseUrl;
    if (base.isEmpty) return null;

    final uri = params.isEmpty 
        ? Uri.parse('$base$path') 
        : Uri.parse('$base$path').replace(queryParameters: params);
    debugPrint('[FatSecret] GET $uri');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      debugPrint('[FatSecret] → ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('[FatSecret] Error body: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data.containsKey('error')) {
        debugPrint('[FatSecret] API error: ${data['error']}');
        return null;
      }
      return data;
    } catch (e, st) {
      debugPrint('[FatSecret] Exception: $e\n$st');
      return null;
    }
  }

  // ──────────────────────────────────────────────
  //  NutritionService interface
  // ──────────────────────────────────────────────

  @override
  Future<List<NutrientsModel>> getDefaultFoods() => searchFoods('chicken');

  @override
  Future<List<String>> getAutocompleteSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    debugPrint('[FatSecret] Autocomplete: "$query"');
    final data = await _get('/api/foods/autocomplete', {'q': query, 'max': '8'});
    if (data == null) return [];

    try {
      final suggestions = data['suggestions'];
      if (suggestions == null) return [];
      final raw = suggestions['suggestion'];
      if (raw == null) return [];
      if (raw is List) return raw.cast<String>();
      if (raw is String) return [raw];
      return [];
    } catch (e) {
      debugPrint('[FatSecret] Autocomplete parse error: $e');
      return [];
    }
  }

  @override
  Future<List<NutrientsModel>> searchFoods(String query) async {
    if (query.trim().isEmpty) return [];

    debugPrint('[FatSecret] Search: "$query"');
    final data = await _get('/api/foods/search', {'q': query, 'max': '10', 'page': '0'});
    if (data == null) return [];

    try {
      final foodsSearch = data['foods_search'] as Map<String, dynamic>?;
      final results = foodsSearch?['results'] as Map<String, dynamic>?;
      final rawFood = results?['food'];

      if (rawFood == null) {
        debugPrint('[FatSecret] No food results in response.');
        return [];
      }

      final foodList = rawFood is List
          ? rawFood.cast<Map<String, dynamic>>()
          : [rawFood as Map<String, dynamic>];

      debugPrint('[FatSecret] Found ${foodList.length} foods — fetching details…');

      final futures = foodList.take(10).map((food) async {
        final foodId = food['food_id']?.toString();
        final foodName = food['food_name']?.toString() ?? 'Unknown';
        if (foodId == null) return null;
        return _fetchDetail(foodId, foodName);
      });

      final detailed = await Future.wait(futures);
      final models = detailed.whereType<NutrientsModel>().toList();
      debugPrint('[FatSecret] Returning ${models.length} NutrientsModel items');
      return models;
    } catch (e, st) {
      debugPrint('[FatSecret] Search parse error: $e\n$st');
      return [];
    }
  }

  // ──────────────────────────────────────────────
  //  Fetch individual food details
  // ──────────────────────────────────────────────

  Future<NutrientsModel?> _fetchDetail(String foodId, String foodName) async {
    final data = await _get('/api/foods/$foodId', {});
    if (data == null) return null;

    try {
      final food = data['food'] as Map<String, dynamic>?;
      if (food == null) return null;

      final name = food['food_name']?.toString() ?? foodName;
      final servingsData = food['servings'];
      Map<String, dynamic>? serving;

      if (servingsData != null) {
        final servingRaw = servingsData['serving'];
        if (servingRaw is List && servingRaw.isNotEmpty) {
          serving = servingRaw.first as Map<String, dynamic>;
        } else if (servingRaw is Map<String, dynamic>) {
          serving = servingRaw;
        }
      }

      if (serving == null) {
        debugPrint('[FatSecret] No serving data for $foodId ($name)');
        return null;
      }

      String? imageUrl;
      final foodImages = food['food_images'];
      if (foodImages != null) {
        final imageRaw = foodImages['food_image'];
        if (imageRaw is List && imageRaw.isNotEmpty) {
          imageUrl = imageRaw.first['image_url']?.toString();
        } else if (imageRaw is Map<String, dynamic>) {
          imageUrl = imageRaw['image_url']?.toString();
        }
      }

      debugPrint('[FatSecret] ✓ $name | cal=${serving['calories']}');

      return NutrientsModel(
        imageUrl: imageUrl,
        keywords: name,
        name: name,
        calories: _s(serving['calories']),
        fat: _s(serving['fat']),
        protein: _s(serving['protein']),
        carbohydrates: _s(serving['carbohydrate']),
        sugars: _s(serving['sugar']),
        fiber: _s(serving['fiber']),
        cholesterol: _s(serving['cholesterol']),
        saturatedFats: _s(serving['saturated_fat']),
        calcium: _s(serving['calcium']),
        iron: _s(serving['iron']),
        potassium: _s(serving['potassium']),
        vitaminA: _s(serving['vitamin_a']),
        vitaminC: _s(serving['vitamin_c']),
        vitaminB12: _s(serving['vitamin_b12']),
        vitaminD: '0',
        vitaminE: '0',
        transFat: '0',
        sodium: _s(serving['sodium']),
        vitaminK: '0',
        monounsaturatedFat: _s(serving['monounsaturated_fat']),
        polyunsaturatedFat: _s(serving['polyunsaturated_fat']),
        caffeine: '0',
        servingWeight1: _s(serving['metric_serving_amount']),
        servingDescription1: serving['measurement_description']?.toString() ??
            serving['serving_description']?.toString() ??
            '1 serving',
      );
    } catch (e, st) {
      debugPrint('[FatSecret] Detail parse error for $foodId: $e\n$st');
      return null;
    }
  }

  String _s(dynamic v) => v?.toString() ?? '0';
}
