import '/core/utils/exports.dart';
import 'dart:math';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:hive/hive.dart';
import '/core/providers/theme_provider.dart';
import '/core/widgets/custom_route.dart';
import '/data/adapters/meal_adapter.dart';
import '/features/tracker/screens/meal_tracker.dart';
import '/features/search/screens/nutrient_details.dart';
import '/data/models/nutrients_model.dart';
import '/features/search/screens/widgets/macro_widget.dart';
import '/features/search/screens/widgets/search_ui.dart';
import 'dart:async';
import '/data/repositories/nutrition_service.dart';
import '/data/repositories/fatsecret_nutrition_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  List<NutrientsModel> _allFoods = [];
  final ValueNotifier<List<NutrientsModel>> _filteredFoods = ValueNotifier([]);
  final NutritionService _nutritionService = _FallbackNutritionService(
    primary: FatSecretNutritionService(),
    fallback: MockNutritionService(),
  );
  Timer? _debounce;
  Future<List<NutrientsModel>>? _initialDataFuture;
  bool _isLoading = false;
  List<String> _suggestions = [];
  final TextEditingController _searchController = TextEditingController();

  void addCalories(
    DateTime date,
    String name,
    double calories,
    double protein,
    double carbohydrates,
    double fat,
  ) async {
    final box = await Hive.openBox<Calories>('calories');
    final existingCalories = box.values
        .where((calories) => calories.date == date)
        .cast<Calories>()
        .toList();
    final newCalories = Calories(
      date: date,
      name: name,
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fat: fat,
      id: box.length - 1,
    );
    existingCalories.add(newCalories);
    await box.putAll({
      for (var calories in existingCalories) calories.hashCode: calories,
    });
  }

  void performSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.trim().isEmpty) {
        if (mounted) _filteredFoods.value = _allFoods;
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        final suggestions = await _nutritionService.getAutocompleteSuggestions(value);
        if (mounted) {
          setState(() {
            _suggestions = suggestions;
          });
        }
        
        final results = await _nutritionService.searchFoods(value);
        if (mounted) {
          _filteredFoods.value = results;
        }
      } catch (e) {
        debugPrint("Error searching foods: $e");
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initialDataFuture = _nutritionService.getDefaultFoods();
    _initialDataFuture!.then((foodList) {
      if (mounted) {
        _allFoods = foodList;
        _filteredFoods.value = foodList;
      }
    });
  }

  bool isDarkMode(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final isSmall = Res.isMobile(context);
    return Scaffold(
      body: ValueListenableBuilder<List<NutrientsModel>>(
        valueListenable: _filteredFoods,
        builder: (context, filteredList, child) {
          return FutureBuilder(
            future: _initialDataFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: NestedScrollView(
                            controller: _scrollController,
                            headerSliverBuilder:
                                (
                                  BuildContext context,
                                  bool innerBoxIsScrolled,
                                ) {
                                  return [
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate((
                                        BuildContext context,
                                        int index,
                                      ) {
                                        return Column(
                                          children: [getSearchBarUI()],
                                        );
                                      }, childCount: 1),
                                    ),
                                    SliverPersistentHeader(
                                      pinned: true,
                                      floating: true,
                                      delegate: ContestTabHeader(
                                        getFilterBarUI(),
                                      ),
                                    ),
                                  ];
                                },
                            body: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (_isLoading)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                      color: AppColors.instance.primary,
                                    ),
                                  ),
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: isSmall ? 2.24 : 4,
                                          crossAxisCount: isSmall ? 1 : 2,
                                        ),
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    itemCount: _filteredFoods.value.length > 250
                                        ? 250
                                        : _filteredFoods.value.length,
                                    itemBuilder: (context, index) {
                                      var generatedColor = Random().nextInt(
                                        Colors.primaries.length,
                                      );
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              createRoute(
                                                NutrientDetails(
                                                  name: _filteredFoods
                                                      .value[index]
                                                      .name,
                                                  calories: _filteredFoods
                                                      .value[index]
                                                      .calories,
                                                  fat: _filteredFoods
                                                      .value[index]
                                                      .fat,
                                                  protein: _filteredFoods
                                                      .value[index]
                                                      .protein,
                                                  carbohydrates: _filteredFoods
                                                      .value[index]
                                                      .carbohydrates,
                                                  sugars: _filteredFoods
                                                      .value[index]
                                                      .sugars,
                                                  fiber: _filteredFoods
                                                      .value[index]
                                                      .fiber,
                                                  cholesterol: _filteredFoods
                                                      .value[index]
                                                      .cholesterol,
                                                  saturatedFats: _filteredFoods
                                                      .value[index]
                                                      .saturatedFats,
                                                  calcium: _filteredFoods
                                                      .value[index]
                                                      .calcium,
                                                  iron: _filteredFoods
                                                      .value[index]
                                                      .iron,
                                                  potassium: _filteredFoods
                                                      .value[index]
                                                      .potassium,
                                                  vitaminA: _filteredFoods
                                                      .value[index]
                                                      .vitaminA,
                                                  vitaminC: _filteredFoods
                                                      .value[index]
                                                      .vitaminC,
                                                  vitaminB12: _filteredFoods
                                                      .value[index]
                                                      .vitaminB12,
                                                  vitaminD: _filteredFoods
                                                      .value[index]
                                                      .vitaminD,
                                                  vitaminE: _filteredFoods
                                                      .value[index]
                                                      .vitaminE,
                                                  transFat: _filteredFoods
                                                      .value[index]
                                                      .transFat,
                                                  sodium: _filteredFoods
                                                      .value[index]
                                                      .sodium,
                                                  vitaminK: _filteredFoods
                                                      .value[index]
                                                      .vitaminK,
                                                  monounsaturatedFat:
                                                      _filteredFoods
                                                          .value[index]
                                                          .monounsaturatedFat,
                                                  polyunsaturatedFat:
                                                      _filteredFoods
                                                          .value[index]
                                                          .polyunsaturatedFat,
                                                  caffeine: _filteredFoods
                                                      .value[index]
                                                      .caffeine,
                                                  servingWeight1: _filteredFoods
                                                      .value[index]
                                                      .servingWeight1,
                                                  servingDescription1:
                                                      _filteredFoods
                                                          .value[index]
                                                          .servingDescription1,
                                                  cardColor: generatedColor,
                                                ),
                                              ),
                                            );
                                          },
                                          splashColor: Colors
                                              .primaries[generatedColor]
                                              .shade100,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Ink(
                                            height: 152,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppColors
                                                        .instance
                                                        .surfaceDark
                                                  : AppColors.instance.surface,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                width: 1.5,
                                                color: isDarkMode(context)
                                                    ? Theme.of(context)
                                                          .colorScheme
                                                          .outlineVariant
                                                    : Colors.grey.withValues(
                                                        alpha: 0.3,
                                                      ),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 74,
                                                      height: 56,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              15,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.grey
                                                              .withValues(
                                                                alpha: 0.3,
                                                              ),
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '${_filteredFoods.value[index].servingDescription1.split(' ').first} x ${_filteredFoods.value[index].servingWeight1}g',
                                                        style: Theme.of(
                                                          context,
                                                        ).textTheme.labelMedium,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            _filteredFoods
                                                                .value[index]
                                                                .name,
                                                            maxLines: 2,
                                                            style:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .textTheme
                                                                    .titleSmall,
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Text(
                                                                '🔥 ',
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                              ),
                                                              Text(
                                                                _filteredFoods.value[index].servingWeight1 ==
                                                                            'NULL' ||
                                                                        _filteredFoods.value[index].calories ==
                                                                            'NULL'
                                                                    ? '${_filteredFoods.value[index].calories} kcal'
                                                                    : '${((double.parse(_filteredFoods.value[index].calories) / 100) * double.parse(_filteredFoods.value[index].servingWeight1)).round()} kcal',
                                                                style: Theme.of(
                                                                  context,
                                                                ).textTheme.labelMedium,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 15),
                                                    InkWell(
                                                      splashColor: AppColors
                                                          .instance
                                                          .surface
                                                          .withValues(
                                                            alpha: 0.6,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            50,
                                                          ),
                                                      onTap: () {
                                                        _filteredFoods
                                                                        .value[index]
                                                                        .servingWeight1 ==
                                                                    'NULL' ||
                                                                _filteredFoods
                                                                        .value[index]
                                                                        .calories ==
                                                                    'NULL'
                                                            ? addCalories(
                                                                DateTime.now(),
                                                                _filteredFoods
                                                                    .value[index]
                                                                    .name,
                                                                double.parse(
                                                                  _filteredFoods
                                                                      .value[index]
                                                                      .calories,
                                                                ),
                                                                double.parse(
                                                                  _filteredFoods
                                                                      .value[index]
                                                                      .protein,
                                                                ),
                                                                double.parse(
                                                                  _filteredFoods
                                                                      .value[index]
                                                                      .carbohydrates,
                                                                ),
                                                                double.parse(
                                                                  _filteredFoods
                                                                      .value[index]
                                                                      .fat,
                                                                ),
                                                              )
                                                            : addCalories(
                                                                DateTime.now(),
                                                                _filteredFoods
                                                                    .value[index]
                                                                    .name,
                                                                ((double.parse(
                                                                          _filteredFoods
                                                                              .value[index]
                                                                              .calories,
                                                                        ) /
                                                                        100) *
                                                                    double.parse(
                                                                      _filteredFoods
                                                                          .value[index]
                                                                          .servingWeight1,
                                                                    )),
                                                                ((double.parse(
                                                                          _filteredFoods
                                                                              .value[index]
                                                                              .protein,
                                                                        ) /
                                                                        100) *
                                                                    double.parse(
                                                                      _filteredFoods
                                                                          .value[index]
                                                                          .servingWeight1,
                                                                    )),
                                                                ((double.parse(
                                                                          _filteredFoods
                                                                              .value[index]
                                                                              .carbohydrates,
                                                                        ) /
                                                                        100) *
                                                                    double.parse(
                                                                      _filteredFoods
                                                                          .value[index]
                                                                          .servingWeight1,
                                                                    )),
                                                                ((double.parse(
                                                                          _filteredFoods
                                                                              .value[index]
                                                                              .fat,
                                                                        ) /
                                                                        100) *
                                                                    double.parse(
                                                                      _filteredFoods
                                                                          .value[index]
                                                                          .servingWeight1,
                                                                    )),
                                                              );
                                                        ElegantNotification.success(
                                                          background: AppColors
                                                              .instance
                                                              .surfaceDark,
                                                          animation:
                                                              AnimationType
                                                                  .fromRight,
                                                          title: const Text(
                                                            "Meal Added Successfully",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white60,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          description: Text(
                                                            _filteredFoods
                                                                .value[index]
                                                                .name,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white60,
                                                                  fontSize: 12,
                                                                ),
                                                          ),
                                                        ).show(context);
                                                      },
                                                      child: Ink(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                50,
                                                              ),
                                                          color: Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                        ),
                                                        child: Icon(
                                                          Icons.add_rounded,
                                                          color: AppColors
                                                              .instance
                                                              .surface,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 14,
                                                      ),
                                                  child:
                                                      _filteredFoods
                                                                  .value[index]
                                                                  .servingWeight1 ==
                                                              'NULL' ||
                                                          _filteredFoods
                                                                  .value[index]
                                                                  .calories ==
                                                              'NULL'
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            MacroWidget(
                                                              macro:
                                                                  '${double.parse(_filteredFoods.value[index].protein).toStringAsFixed(1)} g',
                                                              macrocolor: AppColors
                                                                  .instance
                                                                  .proteinColor,
                                                              macroname:
                                                                  'Protein',
                                                            ),
                                                            MacroWidget(
                                                              macro:
                                                                  '${double.parse(_filteredFoods.value[index].carbohydrates).toStringAsFixed(1)} g',
                                                              macrocolor:
                                                                  AppColors
                                                                      .instance
                                                                      .carbsColor,
                                                              macroname:
                                                                  'Carbs',
                                                            ),
                                                            MacroWidget(
                                                              macro:
                                                                  '${double.parse(_filteredFoods.value[index].fat).toStringAsFixed(1)} g',
                                                              macrocolor:
                                                                  AppColors
                                                                      .instance
                                                                      .fatColor,
                                                              macroname: 'Fat',
                                                            ),
                                                          ],
                                                        )
                                                      : Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            MacroWidget(
                                                              macro:
                                                                  '${((double.parse(_filteredFoods.value[index].protein) / 100) * double.parse(_filteredFoods.value[index].servingWeight1)).toStringAsFixed(1)} g',
                                                              macrocolor: AppColors
                                                                  .instance
                                                                  .proteinColor,
                                                              macroname:
                                                                  'Protein',
                                                            ),
                                                            MacroWidget(
                                                              macro:
                                                                  '${((double.parse(_filteredFoods.value[index].carbohydrates) / 100) * double.parse(_filteredFoods.value[index].servingWeight1)).toStringAsFixed(1)} g',
                                                              macrocolor:
                                                                  AppColors
                                                                      .instance
                                                                      .carbsColor,
                                                              macroname:
                                                                  'Carbs',
                                                            ),
                                                            MacroWidget(
                                                              macro:
                                                                  '${((double.parse(_filteredFoods.value[index].fat) / 100) * double.parse(_filteredFoods.value[index].servingWeight1)).toStringAsFixed(1)} g',
                                                              macrocolor:
                                                                  AppColors
                                                                      .instance
                                                                      .fatColor,
                                                              macroname: 'Fat',
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.instance.primary,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget getSearchBarUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(38)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    offset: const Offset(0, 1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 4,
                  bottom: 4,
                ),
                child: TextField(
                  controller: _searchController,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.text,
                  onChanged: performSearch,
                  cursorColor: const Color(0xff54D3C2),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    border: InputBorder.none,
                    hintText: 'Search any food or drink...',
                    hintStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),
          ),
          if (_suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: _suggestions.map((suggestion) {
                  return ActionChip(
                    label: Text(suggestion, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      _searchController.text = suggestion;
                      performSearch(suggestion);
                      setState(() {
                        _suggestions = [];
                      });
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget getFilterBarUI() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Search result: ${_filteredFoods.value.length} items',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Row(
            children: [
              CustomRoundButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    createRoute(const MealCalendarScreen()),
                  );
                },
                color: AppColors.instance.onSurfaceDark,
                size: 13,
                child: Icon(Icons.calendar_month_outlined, size: 20),
              ),
              SizedBox(width: 8),
              Text('View Diary', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tries [primary] first; if it returns an empty list it falls back to [fallback].
/// This lets the app work even when FatSecret rejects requests (e.g. IP whitelist issues).
class _FallbackNutritionService implements NutritionService {
  _FallbackNutritionService({required this.primary, required this.fallback});

  final NutritionService primary;
  final NutritionService fallback;

  @override
  Future<List<NutrientsModel>> getDefaultFoods() async {
    final results = await primary.getDefaultFoods();
    if (results.isNotEmpty) return results;
    debugPrint('[Fallback] FatSecret returned 0 foods for default. Using MockService.');
    return fallback.getDefaultFoods();
  }

  @override
  Future<List<NutrientsModel>> searchFoods(String query) async {
    final results = await primary.searchFoods(query);
    if (results.isNotEmpty) return results;
    debugPrint('[Fallback] FatSecret returned 0 results for "$query". Using MockService.');
    return fallback.searchFoods(query);
  }

  @override
  Future<List<String>> getAutocompleteSuggestions(String query) async {
    final suggestions = await primary.getAutocompleteSuggestions(query);
    if (suggestions.isNotEmpty) return suggestions;
    return fallback.getAutocompleteSuggestions(query);
  }
}
