import 'dart:async';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '/core/providers/theme_provider.dart';
import '/core/theme/app_colors.dart';
import '/core/widgets/custom_route.dart';
import '/data/adapters/meal_adapter.dart';
import '/data/models/nutrients_model.dart';
import '/data/repositories/fatsecret_nutrition_service.dart';
import '/data/repositories/nutrition_service.dart';
import '/features/tracker/screens/meal_tracker.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Search Screen
// ─────────────────────────────────────────────────────────────────────────────
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final NutritionService _service = _FallbackNutritionService(
    primary: FatSecretNutritionService(),
    fallback: MockNutritionService(),
  );

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  Timer? _debounce;
  bool _isSearching = false;
  bool _hasSubmitted = false;
  List<NutrientsModel> _results = [];
  OverlayEntry? _overlayEntry;

  // Caches
  late final Box _autoCompleteCacheBox;
  late final Box _searchCacheBox;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _autoCompleteCacheBox = Hive.box('autocomplete_cache');
    _searchCacheBox = Hive.box('search_cache');
    
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _hideDropdown();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose();
    _hideDropdown();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Autocomplete overlay ──────────────────────────────────────────────────

  void _displayDropdown(List<String> suggestions) {
    _hideDropdown();
    if (suggestions.isEmpty) return;
    _overlayEntry = _buildOverlay(suggestions);
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _buildOverlay(List<String> suggestions) {
    final isDark = ref.read(themeProvider);
    return OverlayEntry(
      builder: (ctx) => Positioned(
        width: MediaQuery.of(context).size.width - 48,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: isDark ? AppColors.instance.surfaceDark : Colors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: suggestions.map((s) {
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _searchCtrl.text = s;
                      _hideDropdown();
                      _runSearch(s);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: AppColors.instance.primary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.north_west_rounded,
                            size: 14,
                            color: Colors.grey.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Search logic ──────────────────────────────────────────────────────────

  void _onChanged(String value) {
    _hasSubmitted = false;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (value.trim().isEmpty) {
        _hideDropdown();
        if (mounted) setState(() => _results = []);
        return;
      }

      if (_autoCompleteCacheBox.containsKey(value)) {
        if (mounted && _searchCtrl.text == value && !_hasSubmitted) {
          final list = _autoCompleteCacheBox.get(value) as List<dynamic>;
          _displayDropdown(list.cast<String>());
        }
        return;
      }

      final suggestions = await _service.getAutocompleteSuggestions(value);
      _autoCompleteCacheBox.put(value, suggestions);

      if (mounted && _searchCtrl.text == value && !_hasSubmitted) {
        _displayDropdown(suggestions);
      }
    });
  }

  Future<void> _runSearch(String query) async {
    if (query.trim().isEmpty) return;
    _hasSubmitted = true;
    _hideDropdown();

    if (_searchCacheBox.containsKey(query)) {
      final jsonString = _searchCacheBox.get(query) as String;
      final cachedFoods = nutrientsModelFromJson(jsonString);
      setState(() {
        _isSearching = false;
        _results = cachedFoods;
      });
      _fadeCtrl.forward(from: 0.0);
      return;
    }

    setState(() {
      _isSearching = true;
      _results = [];
    });
    _fadeCtrl.reset();
    try {
      final foods = await _service.searchFoods(query);
      _searchCacheBox.put(query, nutrientsModelToJson(foods));
      if (mounted) {
        setState(() => _results = foods);
        _fadeCtrl.forward();
      }
    } catch (e) {
      debugPrint('[SearchScreen] error: $e');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // ── Diary helper ──────────────────────────────────────────────────────────

  Future<void> _addToDiary(NutrientsModel food) async {
    double safeParse(String v) {
      final cleaned = v.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0;
    }

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
        .where(
          (c) =>
              c.date.year == entry.date.year &&
              c.date.month == entry.date.month &&
              c.date.day == entry.date.day,
        )
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.instance.backgroundDark
          : const Color(0xFFF8FAFE),
      body: SafeArea(
        child: Column(
          children: [
            _SearchHeader(
              ctrl: _searchCtrl,
              focus: _focusNode,
              layerLink: _layerLink,
              isSearching: _isSearching,
              onChanged: _onChanged,
              onSubmitted: _runSearch,
              onDiaryTap: () => Navigator.push(
                context,
                createRoute(const MealCalendarScreen()),
              ),
            ),
            Expanded(
              child: _results.isEmpty && !_isSearching
                  ? _EmptyState(hasQuery: _searchCtrl.text.isNotEmpty)
                  : _isSearching
                  ? const _LoadingState()
                  : FadeTransition(
                      opacity: _fadeAnim,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: _results.length,
                        itemBuilder: (_, i) => _FoodListTile(
                          food: _results[i],
                          onTap: () => _openDetail(_results[i]),
                          onAdd: () => _addToDiary(_results[i]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(NutrientsModel food) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _FoodDetailSheet(food: food, onAddToDiary: () => _addToDiary(food)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Header with search bar
// ─────────────────────────────────────────────────────────────────────────────
class _SearchHeader extends ConsumerWidget {
  const _SearchHeader({
    required this.ctrl,
    required this.focus,
    required this.layerLink,
    required this.isSearching,
    required this.onChanged,
    required this.onSubmitted,
    required this.onDiaryTap,
  });

  final TextEditingController ctrl;
  final FocusNode focus;
  final LayerLink layerLink;
  final bool isSearching;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onDiaryTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Food Search',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onDiaryTap,
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: const Text('Diary'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.instance.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CompositedTransformTarget(
            link: layerLink,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.instance.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.instance.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: ctrl,
                focusNode: focus,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                cursorColor: AppColors.instance.primary,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Search foods, drinks, recipes…',
                  hintStyle: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.6),
                    fontSize: 15,
                  ),
                  prefixIcon: isSearching
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.instance.primary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.search_rounded,
                          color: AppColors.instance.primary,
                        ),
                  suffixIcon: ctrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            ctrl.clear();
                            onChanged('');
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
}

// ─────────────────────────────────────────────────────────────────────────────
//  Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasQuery});
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.instance.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasQuery ? Icons.search_off_rounded : Icons.restaurant_rounded,
                size: 48,
                color: AppColors.instance.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasQuery ? 'No results found' : 'Discover Your Food',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              hasQuery
                  ? 'Try a different search term or check your spelling.'
                  : 'Search for any food or drink to see\ncalories, macros and full nutrition facts.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey, height: 1.5),
            ),
            if (!hasQuery) ...[
              const SizedBox(height: 28),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  '🍗 Chicken',
                  '🍎 Apple',
                  '🥚 Egg',
                  '🥛 Milk',
                  '🍚 Rice',
                  '🥑 Avocado',
                ].map((s) => _QuickChip(label: s)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.instance.primary.withValues(alpha: 0.25),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(20),
        color: AppColors.instance.primary.withValues(alpha: 0.05),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.instance.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.instance.primary),
          const SizedBox(height: 16),
          Text(
            'Searching…',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Food list tile
// ─────────────────────────────────────────────────────────────────────────────
class _FoodListTile extends ConsumerWidget {
  const _FoodListTile({
    required this.food,
    required this.onTap,
    required this.onAdd,
  });
  final NutrientsModel food;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    double safeParse(String v) =>
        double.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    final cal = safeParse(food.calories);
    final prot = safeParse(food.protein);
    final carb = safeParse(food.carbohydrates);
    final fat = safeParse(food.fat);
    final rdiPct = (cal / 2000 * 100).clamp(0, 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? AppColors.instance.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Calorie badge
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.instance.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cal.round().toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.instance.primary,
                        ),
                      ),
                      Text(
                        'kcal',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.instance.primary.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${food.servingWeight1.split('.').first}g ${food.servingDescription1}',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '($rdiPct% RDI)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _rdiColor(rdiPct),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _MacroPill(
                            label: 'Protein',
                            value: '${prot.toStringAsFixed(1)}g',
                            color: AppColors.instance.proteinColor,
                          ),
                          const SizedBox(width: 6),
                          _MacroPill(
                            label: 'Carbs',
                            value: '${carb.toStringAsFixed(1)}g',
                            color: AppColors.instance.carbsColor,
                          ),
                          const SizedBox(width: 6),
                          _MacroPill(
                            label: 'Fat',
                            value: '${fat.toStringAsFixed(1)}g',
                            color: AppColors.instance.fatColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onAdd();
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.instance.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _rdiColor(int pct) {
    if (pct < 10) return Colors.green;
    if (pct < 25) return Colors.orange;
    return Colors.red;
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Food Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _FoodDetailSheet extends ConsumerWidget {
  const _FoodDetailSheet({required this.food, required this.onAddToDiary});
  final NutrientsModel food;
  final VoidCallback onAddToDiary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final touchedIndexNotifier = ValueNotifier<int>(-1);
    final isDark = ref.watch(themeProvider);

    double safeParse(String v) =>
        double.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    final cal = safeParse(food.calories);
    final prot = safeParse(food.protein);
    final carb = safeParse(food.carbohydrates);
    final fat = safeParse(food.fat);
    final totalMacrosCal = prot * 4 + carb * 4 + fat * 9;
    final protPct = totalMacrosCal > 0
        ? (prot * 4 / totalMacrosCal * 100)
        : 0.0;
    final carbPct = totalMacrosCal > 0
        ? (carb * 4 / totalMacrosCal * 100)
        : 0.0;
    final fatPct = totalMacrosCal > 0 ? (fat * 9 / totalMacrosCal * 100) : 0.0;
    final rdiPct = (cal / 2000 * 100).clamp(0.0, 100.0);

    final bg = isDark ? AppColors.instance.surfaceDark : Colors.white;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    if (food.imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: food.imageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const SizedBox.shrink(),
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: Colors.grey.withValues(alpha: 0.1),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Title + serving
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                food.servingDescription1,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // RDI pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.instance.primary,
                                AppColors.instance.primary.withValues(
                                  alpha: 0.7,
                                ),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${rdiPct.round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                'of RDI',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Pie chart + summary
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ValueListenableBuilder<int>(
                              valueListenable: touchedIndexNotifier,
                              builder: (context, touchedIndex, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PieChart(
                                      PieChartData(
                                        pieTouchData: PieTouchData(
                                          touchCallback: (FlTouchEvent e,
                                              PieTouchResponse? r) {
                                            if (r != null &&
                                                r.touchedSection != null) {
                                              touchedIndexNotifier.value = r
                                                  .touchedSection!
                                                  .touchedSectionIndex;
                                            } else {
                                              touchedIndexNotifier.value = -1;
                                            }
                                          },
                                        ),
                                        borderData: FlBorderData(show: false),
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 38,
                                        sections: [
                                          _pieSection(
                                            carbPct,
                                            AppColors.instance.carbsColor,
                                            'Carbs',
                                            0,
                                            touchedIndex,
                                          ),
                                          _pieSection(
                                            fatPct,
                                            AppColors.instance.fatColor,
                                            'Fat',
                                            1,
                                            touchedIndex,
                                          ),
                                          _pieSection(
                                            protPct,
                                            AppColors.instance.proteinColor,
                                            'Prot',
                                            2,
                                            touchedIndex,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          cal.round().toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 22,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        const Text(
                                          'kcal',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              _LegendRow(
                                color: AppColors.instance.carbsColor,
                                label: 'Carbohydrate',
                                value: '${carb.toStringAsFixed(1)}g',
                                pct: carbPct.round(),
                              ),
                              const SizedBox(height: 10),
                              _LegendRow(
                                color: AppColors.instance.fatColor,
                                label: 'Fat',
                                value: '${fat.toStringAsFixed(1)}g',
                                pct: fatPct.round(),
                              ),
                              const SizedBox(height: 10),
                              _LegendRow(
                                color: AppColors.instance.proteinColor,
                                label: 'Protein',
                                value: '${prot.toStringAsFixed(1)}g',
                                pct: protPct.round(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Text(
                      '*Based on an RDI of 2000 calories',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 24),
                    _SectionHeader('Nutrition Facts'),
                    const SizedBox(height: 4),
                    _NutritionTable(food: food, isDark: isDark),

                    const SizedBox(height: 24),
                    _SectionHeader('Other Nutrients'),
                    const SizedBox(height: 8),
                    _OtherNutrients(food: food, isDark: isDark),

                    const SizedBox(height: 32),
                    // Add to diary button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          onAddToDiary();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text(
                          'Add to Diary',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.instance.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PieChartSectionData _pieSection(
    double pct,
    Color color,
    String label,
    int idx,
    int touchedIndex,
  ) {
    final isTouched = idx == touchedIndex;
    return PieChartSectionData(
      color: color,
      value: pct.isNaN || pct <= 0 ? 0.01 : pct,
      title: isTouched ? '${pct.round()}%' : '',
      radius: isTouched ? 42 : 36,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.pct,
  });
  final Color color;
  final String label;
  final String value;
  final int pct;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 6),
        Text(
          '($pct%)',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Divider(height: 12),
      ],
    );
  }
}

class _NutritionTable extends StatelessWidget {
  const _NutritionTable({required this.food, required this.isDark});
  final NutrientsModel food;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Serving Size', '${food.servingDescription1} (${food.servingWeight1}g)'),
      ('Calories', '${food.calories} kcal'),
      ('Total Fat', '${food.fat} g'),
      ('  Saturated Fat', '${food.saturatedFats} g'),
      ('  Trans Fat', '${food.transFat} g'),
      ('  Polyunsaturated', '${food.polyunsaturatedFat} g'),
      ('  Monounsaturated', '${food.monounsaturatedFat} g'),
      ('Cholesterol', '${food.cholesterol} mg'),
      ('Sodium', '${food.sodium} mg'),
      ('Total Carbohydrates', '${food.carbohydrates} g'),
      ('  Dietary Fiber', '${food.fiber} g'),
      ('  Sugars', '${food.sugars} g'),
      ('Protein', '${food.protein} g'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isHeader = !e.value.$1.startsWith(' ');
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: e.key < rows.length - 1
                  ? Border(
                      bottom: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    e.value.$1,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isHeader
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isHeader
                          ? (isDark ? Colors.white : Colors.black87)
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                Text(
                  e.value.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OtherNutrients extends StatelessWidget {
  const _OtherNutrients({required this.food, required this.isDark});
  final NutrientsModel food;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Calcium', '${food.calcium} mg'),
      ('Iron', '${food.iron} mg'),
      ('Potassium', '${food.potassium} mg'),
      ('Vitamin A', '${food.vitaminA} mcg'),
      ('Vitamin C', '${food.vitaminC} mg'),
      ('Vitamin B-12', '${food.vitaminB12} mcg'),
      ('Vitamin D', '${food.vitaminD} mcg'),
      ('Vitamin E', '${food.vitaminE} mg'),
      ('Vitamin K', '${food.vitaminK} mcg'),
      ('Caffeine', '${food.caffeine} mg'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.$1,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.$2,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Fallback NutritionService
// ─────────────────────────────────────────────────────────────────────────────
class _FallbackNutritionService implements NutritionService {
  _FallbackNutritionService({required this.primary, required this.fallback});
  final NutritionService primary;
  final NutritionService fallback;

  @override
  Future<List<NutrientsModel>> getDefaultFoods() async {
    final r = await primary.getDefaultFoods();
    if (r.isNotEmpty) return r;
    debugPrint('[Fallback] Using MockService for default foods');
    return fallback.getDefaultFoods();
  }

  @override
  Future<List<NutrientsModel>> searchFoods(String query) async {
    final r = await primary.searchFoods(query);
    if (r.isNotEmpty) return r;
    debugPrint('[Fallback] Using MockService for "$query"');
    return fallback.searchFoods(query);
  }

  @override
  Future<List<String>> getAutocompleteSuggestions(String query) async {
    final s = await primary.getAutocompleteSuggestions(query);
    if (s.isNotEmpty) return s;
    return fallback.getAutocompleteSuggestions(query);
  }
}
