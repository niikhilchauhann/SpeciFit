import 'dart:convert';
import 'dart:math';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:specifit/screens/details/nutrient_details.dart';
import '../../helpers/adapters/meal_adapter.dart';
import '../../utilities/export.dart';
import 'package:http/http.dart' as http;

import '../trackers/meal_tracker.dart';

class Nutrients extends StatefulWidget {
  const Nutrients({super.key});

  @override
  State<Nutrients> createState() => _NutrientsState();
}

class _NutrientsState extends State<Nutrients> with TickerProviderStateMixin {
  final BannerAd navbarAdUnit = BannerAd(
      adUnitId: AdService.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: AdService.bannerAdListener)
    ..load();
  List<NutrientsModel> _allFoods = [];
  List<NutrientsModel> _filteredFoods = [];

  Future<List<NutrientsModel>> getApiData() async {
    try {
      final response = await http.get(
        Uri.parse('https://edcorp-specifit.github.io/APIs/nutrients_api.json'),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<NutrientsModel> foodList = [];
        for (var json in data) {
          NutrientsModel food = NutrientsModel.fromJson(json);
          foodList.add(food);
        }
        return foodList;
      } else {
        throw Exception('Failed to fetch foodList');
      }
    } catch (e) {
      throw Exception('Failed to fetch foodList: $e');
    }
  }

  void addCalories(DateTime date, String name, double calories, double protein,
      double carbohydrates, double fat) async {
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
    await box.putAll(
        {for (var calories in existingCalories) calories.hashCode: calories});
  }

  performSearch(value) {
    if (mounted) {
      setState(() {
        _filteredFoods = _allFoods
            .where((food) =>
                food.keywords.toLowerCase().contains(value.toLowerCase()))
            .toList();
      });
    }
  }

  InterstitialAd? _interstitialAd;
  createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdService.adUnitIdInterstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {},
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    createInterstitialAd();
    getApiData().then((foodList) {
      if (mounted) {
        setState(() {
          _allFoods = foodList;
          _filteredFoods = foodList;
        });
      }
    });
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  bool isDarkMode(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => exitDialogue(() => _interstitialAd!.show(), context),
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Food Diary"),
            actions: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(32.0),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      createRoute(
                        const MealCalendarScreen(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.calendar_month_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8)
            ],
          ),
          body: FutureBuilder(
              future: getApiData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Stack(children: [
                    Column(children: [
                      Expanded(
                          child: NestedScrollView(
                              controller: _scrollController,
                              headerSliverBuilder: (BuildContext context,
                                  bool innerBoxIsScrolled) {
                                return [
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        return Column(
                                          children: [
                                            getSearchBarUI(),
                                          ],
                                        );
                                      },
                                      childCount: 1,
                                    ),
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
                                    Expanded(
                                        child: ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6),
                                            itemCount:
                                                _filteredFoods.length > 250
                                                    ? 250
                                                    : _filteredFoods.length,
                                            itemBuilder: (context, index) {
                                              var generatedColor = Random()
                                                  .nextInt(
                                                      Colors.primaries.length);
                                              return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  child: InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          createRoute(
                                                            NutrientDetails(
                                                              name:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .name,
                                                              calories:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .calories,
                                                              fat:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .fat,
                                                              protein:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .protein,
                                                              carbohydrates:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .carbohydrates,
                                                              sugars:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .sugars,
                                                              fiber:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .fiber,
                                                              cholesterol:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .cholesterol,
                                                              saturatedFats:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .saturatedFats,
                                                              calcium:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .calcium,
                                                              iron:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .iron,
                                                              potassium:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .potassium,
                                                              vitaminA:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .vitaminA,
                                                              vitaminC:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .vitaminC,
                                                              vitaminB12:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .vitaminB12,
                                                              vitaminD:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .vitaminD,
                                                              vitaminE:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .vitaminE,
                                                              transFat:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .transFat,
                                                              sodium:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .sodium,
                                                              vitaminK:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .vitaminK,
                                                              monounsaturatedFat:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .monounsaturatedFat,
                                                              polyunsaturatedFat:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .polyunsaturatedFat,
                                                              caffeine:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .caffeine,
                                                              servingWeight1:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .servingWeight1,
                                                              servingDescription1:
                                                                  _filteredFoods[
                                                                          index]
                                                                      .servingDescription1,
                                                              cardColor:
                                                                  generatedColor,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      splashColor: Colors
                                                          .primaries[
                                                              generatedColor]
                                                          .shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: Ink(
                                                          height: 152,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .cardColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            border: Border.all(
                                                              width: 1.5,
                                                              color: isDarkMode(
                                                                      context)
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .outlineVariant
                                                                  : Colors.grey
                                                                      .withOpacity(
                                                                          0.3),
                                                            ),
                                                          ),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      width: 74,
                                                                      height:
                                                                          56,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(15),
                                                                        border:
                                                                            Border.all(
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.3),
                                                                          width:
                                                                              1.5,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        '${_filteredFoods[index].servingDescription1.split(' ').first} x ${_filteredFoods[index].servingWeight1}g',
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .labelMedium,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            12),
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                              _filteredFoods[index].name,
                                                                              maxLines: 2,
                                                                              style: Theme.of(context).textTheme.titleSmall),
                                                                          Row(
                                                                            children: [
                                                                              const Text(
                                                                                '🔥 ',
                                                                                style: TextStyle(fontSize: 13),
                                                                              ),
                                                                              Text(_filteredFoods[index].servingWeight1 == 'NULL' || _filteredFoods[index].calories == 'NULL' ? '${_filteredFoods[index].calories} kcal' : '${((double.parse(_filteredFoods[index].calories) / 100) * double.parse(_filteredFoods[index].servingWeight1)).round()} kcal', style: Theme.of(context).textTheme.labelMedium),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            15),
                                                                    InkWell(
                                                                      splashColor:
                                                                          bgcolor
                                                                              .withOpacity(0.6),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              50),
                                                                      onTap:
                                                                          () {
                                                                        _filteredFoods[index].servingWeight1 == 'NULL' ||
                                                                                _filteredFoods[index].calories ==
                                                                                    'NULL'
                                                                            ? addCalories(
                                                                                DateTime.now(),
                                                                                _filteredFoods[index].name,
                                                                                double.parse(_filteredFoods[index].calories),
                                                                                double.parse(_filteredFoods[index].protein),
                                                                                double.parse(_filteredFoods[index].carbohydrates),
                                                                                double.parse(_filteredFoods[index].fat))
                                                                            : addCalories(
                                                                                DateTime.now(),
                                                                                _filteredFoods[index].name,
                                                                                ((double.parse(_filteredFoods[index].calories) / 100) * double.parse(_filteredFoods[index].servingWeight1)),
                                                                                ((double.parse(_filteredFoods[index].protein) / 100) * double.parse(_filteredFoods[index].servingWeight1)),
                                                                                ((double.parse(_filteredFoods[index].carbohydrates) / 100) * double.parse(_filteredFoods[index].servingWeight1)),
                                                                                ((double.parse(_filteredFoods[index].fat) / 100) * double.parse(_filteredFoods[index].servingWeight1)),
                                                                              );
                                                                        ElegantNotification.success(
                                                                                animation: AnimationType.fromBottom,
                                                                                title: const Text("Meal Added Successfully", style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                                                                                description: Text(_filteredFoods[index].name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: color, fontSize: 12)))
                                                                            .show(context);
                                                                      },
                                                                      child:
                                                                          Ink(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(50),
                                                                          color:
                                                                              Theme.of(context).primaryColor,
                                                                        ),
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .add_rounded,
                                                                          color:
                                                                              bgcolor,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 12),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              14),
                                                                  child: _filteredFoods[index].servingWeight1 ==
                                                                              'NULL' ||
                                                                          _filteredFoods[index].calories ==
                                                                              'NULL'
                                                                      ? Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                              MacroWidget(macro: '${double.parse(_filteredFoods[index].protein).toStringAsFixed(1)} g', macrocolor: proteincolor, macroname: 'Protein'),
                                                                              MacroWidget(macro: '${double.parse(_filteredFoods[index].carbohydrates).toStringAsFixed(1)} g', macrocolor: carbscolor, macroname: 'Carbs'),
                                                                              MacroWidget(macro: '${double.parse(_filteredFoods[index].fat).toStringAsFixed(1)} g', macrocolor: fatcolor, macroname: 'Fat'),
                                                                            ])
                                                                      : Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            MacroWidget(
                                                                                macro: '${((double.parse(_filteredFoods[index].protein) / 100) * double.parse(_filteredFoods[index].servingWeight1)).toStringAsFixed(1)} g',
                                                                                macrocolor: proteincolor,
                                                                                macroname: 'Protein'),
                                                                            MacroWidget(
                                                                                macro: '${((double.parse(_filteredFoods[index].carbohydrates) / 100) * double.parse(_filteredFoods[index].servingWeight1)).toStringAsFixed(1)} g',
                                                                                macrocolor: carbscolor,
                                                                                macroname: 'Carbs'),
                                                                            MacroWidget(
                                                                                macro: '${((double.parse(_filteredFoods[index].fat) / 100) * double.parse(_filteredFoods[index].servingWeight1)).toStringAsFixed(1)} g',
                                                                                macrocolor: fatcolor,
                                                                                macroname: 'Fat'),
                                                                          ],
                                                                        ),
                                                                )
                                                              ]))));
                                            })),
                                    const SizedBox(height: 70)
                                  ])))
                    ])
                  ]);
                } else {
                  return Center(
                      child: CircularProgressIndicator(color: primary));
                }
              })),
    );
  }

  Widget getSearchBarUI() {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
        child: Column(children: [
          SizedBox(height: 52, child: AdWidget(ad: navbarAdUnit)),
          Padding(
              padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
              child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(38),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          offset: const Offset(0, 1),
                          blurRadius: 8),
                    ],
                  ),
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 4, bottom: 4),
                      child: TextField(
                          textCapitalization: TextCapitalization.words,
                          keyboardType: TextInputType.text,
                          onChanged: performSearch,
                          cursorColor: const Color(0xff54D3C2),
                          decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              border: InputBorder.none,
                              hintText: 'Search any food or drink...',
                              hintStyle:
                                  Theme.of(context).textTheme.labelLarge)))))
        ]));
  }

  Widget getFilterBarUI() {
    return Stack(children: [
      Container(
          height: MediaQuery.of(context).size.height,
          color: Theme.of(context).cardColor,
          child: Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
              child: Row(children: [
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            'Search result: ${_filteredFoods.length} items',
                            style: Theme.of(context).textTheme.labelLarge))),
                Material(
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Row(
                        children: [
                          // Text('Filter',
                          //     style: Theme.of(context).textTheme.bodyLarge),
                          // Padding(
                          //     padding: const EdgeInsets.all(8.0),
                          //     child: Icon(Icons.sort,
                          //         color: Theme.of(context).primaryColor))
                        ],
                      ),
                    ),
                  ),
                )
              ]))),
      const Positioned(top: 0, left: 0, right: 0, child: Divider(height: 1))
    ]);
  }
}
