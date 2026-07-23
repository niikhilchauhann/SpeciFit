import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';

import '/core/utils/exports.dart';
import '/core/providers/theme_provider.dart';
import '/core/providers/user_provider.dart';
import '/core/widgets/custom_route.dart';
import '/core/videoplayer/player.dart';
import '/data/models/nutrients_model.dart';
import '/data/models/exercise_model.dart';
import '/data/models/videos_model.dart';
import '/data/repositories/fatsecret_nutrition_service.dart';
import '/data/repositories/nutrition_service.dart';
import '/data/adapters/meal_adapter.dart';
import '/features/workouts/screens/exercise_tile.dart';

class FallbackNutritionService implements NutritionService {
  FallbackNutritionService({required this.primary, required this.fallback});
  final NutritionService primary;
  final NutritionService fallback;

  @override
  Future<List<String>> getAutocompleteSuggestions(String query) async {
    try {
      return await primary.getAutocompleteSuggestions(query);
    } catch (e) {
      return fallback.getAutocompleteSuggestions(query);
    }
  }

  @override
  Future<List<NutrientsModel>> getDefaultFoods() async {
    try {
      return await primary.getDefaultFoods();
    } catch (e) {
      return fallback.getDefaultFoods();
    }
  }

  @override
  Future<List<NutrientsModel>> searchFoods(String query) async {
    try {
      return await primary.searchFoods(query);
    } catch (e) {
      return fallback.searchFoods(query);
    }
  }
}

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  late TabController _tabController;

  // State Variables
  String _currentQuery = '';

  // Foods State
  final NutritionService _service = FallbackNutritionService(
    primary: FatSecretNutritionService(),
    fallback: MockNutritionService(),
  );
  bool _isSearchingFoods = false;
  List<NutrientsModel> _foodResults = [];
  late Box _searchCacheBox;

  // Exercises State
  bool _isFetchingExercises = true;
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];

  // Home Workouts State
  bool _isFetchingHomeWorkouts = true;
  List<VideosModel> _allHomeWorkoutVideos = [];
  List<VideosModel> _filteredHomeWorkoutVideos = [];

  @override
  void initState() {
    super.initState();
    _searchCacheBox = Hive.box('search_cache');
    _tabController = TabController(length: 3, vsync: this);
    _fetchExercises();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = ref.read(userProvider);
      final gender = u?.gender ?? 'Male';
      _fetchHomeWorkoutVideos(gender);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchExercises() async {
    try {
      final response = await http.get(
        Uri.parse('https://edcorp-specifit.github.io/APIs/exercises_api.json'),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<Exercise> list = [];
        for (var json in data) {
          list.add(Exercise.fromJson(json));
        }
        if (mounted) {
          setState(() {
            _allExercises = list;
            _filteredExercises = list;
            _isFetchingExercises = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingExercises = false);
      }
    }
  }

  Future<void> _fetchHomeWorkoutVideos(String gender) async {
    final genderDoc = gender.toLowerCase() == 'male' ? AppStrings.maleDoc : AppStrings.femaleDoc;
    List<VideosModel> allVideos = [];
    try {
      for (final collection in AppStrings.pushCollectionNames) {
        final data = await FirebaseFirestore.instance
            .collection("HomeWorkouts")
            .doc(genderDoc)
            .collection(collection)
            .get();
        allVideos.addAll(data.docs.map((doc) => VideosModel.fromSnapshot(doc)));
      }
      if (mounted) {
        setState(() {
          _allHomeWorkoutVideos = allVideos;
          _filteredHomeWorkoutVideos = allVideos;
          _isFetchingHomeWorkouts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingHomeWorkouts = false);
      }
    }
  }

  void _onChanged(String value) {
    setState(() => _currentQuery = value.trim());
    _filterLocalData(value);

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().isNotEmpty) {
        _runFoodSearch(value.trim());
      } else {
        setState(() => _foodResults = []);
      }
    });
  }

  void _filterLocalData(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredExercises = _allExercises;
        _filteredHomeWorkoutVideos = _allHomeWorkoutVideos;
      });
      return;
    }
    setState(() {
      _filteredExercises = _allExercises
          .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _filteredHomeWorkoutVideos = _allHomeWorkoutVideos
          .where((w) => w.hwName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _runFoodSearch(String query) async {
    if (_searchCacheBox.containsKey(query)) {
      final jsonString = _searchCacheBox.get(query) as String;
      setState(() {
        _foodResults = nutrientsModelFromJson(jsonString);
        _isSearchingFoods = false;
      });
      return;
    }

    setState(() => _isSearchingFoods = true);
    try {
      final foods = await _service.searchFoods(query);
      _searchCacheBox.put(query, nutrientsModelToJson(foods));
      if (mounted && _currentQuery == query) {
        setState(() => _foodResults = foods);
      }
    } catch (e) {
      debugPrint('[GlobalSearch] error: $e');
    } finally {
      if (mounted && _currentQuery == query) {
        setState(() => _isSearchingFoods = false);
      }
    }
  }

  Future<void> _addToDiary(NutrientsModel food) async {
    double safeParse(String v) =>
        double.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    final w = safeParse(food.servingWeight1);
    final factor = (w > 0 && w != 100) ? w / 100 : 1.0;
    final cal = safeParse(food.calories) * factor;
    final prot = safeParse(food.protein) * factor;
    final carb = safeParse(food.carbohydrates) * factor;
    final fat = safeParse(food.fat) * factor;

    final box = await Hive.openBox<Calories>('calories');
    final entry = Calories(
      date: DateTime.now(),
      name: food.name,
      calories: cal,
      protein: prot,
      carbohydrates: carb,
      fat: fat,
      id: box.length,
    );
    
    final existing = box.values
        .where((c) =>
            c.date.year == entry.date.year &&
            c.date.month == entry.date.month &&
            c.date.day == entry.date.day)
        .cast<Calories>()
        .toList();
    existing.add(entry);
    await box.putAll({for (var c in existing) c.hashCode: c});

    if (mounted) {
      ElegantNotification.success(
        background: AppColors.instance.surfaceDark,
        animation: AnimationType.fromRight,
        title: const Text(
          'Added to Diary ✓',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
        ),
        description: Text(
          food.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final u = ref.watch(userProvider);
    final gender = u?.gender ?? 'Male';

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.instance.backgroundDark
          : const Color(0xFFF8FAFE),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(isDark),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.instance.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.instance.primary,
              tabs: const [
                Tab(text: 'Foods'),
                Tab(text: 'Exercises'),
                Tab(text: 'Home Workouts'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFoodsTab(),
                  _buildExercisesTab(),
                  _buildHomeWorkoutsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_rounded, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.instance.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.instance.primary.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                focusNode: _focusNode,
                onChanged: _onChanged,
                textInputAction: TextInputAction.search,
                cursorColor: AppColors.instance.primary,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Search databases...',
                  hintStyle: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.6),
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.grey,
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                          onPressed: () {
                            _searchCtrl.clear();
                            _onChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodsTab() {
    if (_currentQuery.isEmpty) {
      return const _EmptyState(message: 'Search for foods and drinks', icon: Icons.restaurant);
    }
    if (_isSearchingFoods) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.instance.primary),
      );
    }
    if (_foodResults.isEmpty) {
      return const _EmptyState(message: 'No foods found', icon: Icons.search_off);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _foodResults.length,
      itemBuilder: (context, i) {
        final food = _foodResults[i];
        double safeParse(String v) =>
            double.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        final cal = safeParse(food.calories);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.instance.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  cal.round().toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.instance.primary,
                  ),
                ),
              ),
            ),
            title: Text(food.name, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text('${food.servingWeight1}g'),
            trailing: IconButton(
              icon: Icon(Icons.add_circle, color: AppColors.instance.primary),
              onPressed: () => _addToDiary(food),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExercisesTab() {
    if (_isFetchingExercises) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.instance.primary),
      );
    }
    if (_filteredExercises.isEmpty) {
      return const _EmptyState(message: 'No exercises found', icon: Icons.fitness_center);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _filteredExercises.length,
      itemBuilder: (context, i) {
        final ex = _filteredExercises[i];
        return ExerciseTile(
          bodyPart: ex.bodyPart,
          equipment: ex.equipment,
          gifUrl: ex.gifUrl,
          name: ex.name,
          target: ex.target,
        );
      },
    );
  }

  Widget _buildHomeWorkoutsTab() {
    if (_isFetchingHomeWorkouts) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.instance.primary),
      );
    }
    if (_filteredHomeWorkoutVideos.isEmpty) {
      return const _EmptyState(message: 'No home workout videos found', icon: Icons.video_library);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _filteredHomeWorkoutVideos.length,
      itemBuilder: (context, i) {
        final video = _filteredHomeWorkoutVideos[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                createRoute(
                  VideoPlayer(videoUrl: video.hwVideoId, startAt: 0.0),
                ),
              );
            },
            child: Container(
              height: 225,
              decoration: BoxDecoration(
                boxShadow: kElevationToShadow[3],
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            "https://img.youtube.com/vi/${video.hwVideoId}/maxresdefault.jpg",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.hwName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          video.hwDescription,
                          style: Theme.of(context).textTheme.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
