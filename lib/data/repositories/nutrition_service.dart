import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/nutrients_model.dart';

abstract class NutritionService {
  Future<List<NutrientsModel>> searchFoods(String query);
  Future<List<NutrientsModel>> getDefaultFoods();
  Future<List<String>> getAutocompleteSuggestions(String query);
}

/// Fallback service using the original static JSON (used for offline/testing).
class MockNutritionService implements NutritionService {
  List<NutrientsModel> _cache = [];

  Future<void> _load() async {
    if (_cache.isNotEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('https://edcorp-specifit.github.io/APIs/nutrients_api.json'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        _cache = data.map((e) => NutrientsModel.fromJson(e as Map<String, dynamic>)).toList();
        debugPrint('[MockNutrition] Loaded ${_cache.length} foods from JSON');
      }
    } catch (e) {
      debugPrint('[MockNutrition] Failed to load: $e');
    }
  }

  @override
  Future<List<NutrientsModel>> getDefaultFoods() async {
    await _load();
    return _cache;
  }

  @override
  Future<List<NutrientsModel>> searchFoods(String query) async {
    await _load();
    if (query.trim().isEmpty) return _cache;
    final q = query.toLowerCase();
    return _cache.where((f) => f.name.toLowerCase().contains(q)).toList();
  }

  @override
  Future<List<String>> getAutocompleteSuggestions(String query) async {
    await _load();
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return _cache
        .where((f) => f.name.toLowerCase().contains(q))
        .map((f) => f.name)
        .take(8)
        .toList();
  }
}
