import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:specifit/screens/details/gym_details.dart';
import '../../utilities/export.dart';

class Gyms extends StatefulWidget {
  const Gyms({super.key});

  @override
  State<Gyms> createState() => _GymsState();
}

class _GymsState extends State<Gyms> {
  final BannerAd bannerAdUnit = BannerAd(
    adUnitId: AdService.adUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: AdService.bannerAdListener,
  )..load();

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Gyms")),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: SizedBox(
                                  height: 52,
                                  width: width,
                                  child: AdWidget(ad: bannerAdUnit)),
                            );
                          },
                          childCount: 1,
                        ),
                      ),
                    ];
                  },
                  body: ListView.builder(
                    itemCount: _getGyms.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              createRoute(
                                GymDetails(
                                  address: _getGyms[index].gAddress,
                                  facilities: _getGyms[index].gFacilities,
                                  fees: _getGyms[index].gFees,
                                  image: _getGyms[index].gImage,
                                  orientation: _getGyms[index].gOrientation,
                                  size: _getGyms[index].gSize,
                                  name: _getGyms[index].gName,
                                  trainer: _getGyms[index].gTrainer,
                                  images: _getGyms[index].gImages,
                                  contact: _getGyms[index].gContact,
                                  rating: _getGyms[index].gRating,
                                ),
                              ),
                            );
                          },
                          child: GymsCard(
                            image: _getGyms[index].gImage,
                            name: _getGyms[index].gName,
                            address: _getGyms[index].gAddress,
                            orientation:
                                "Gender: ${_getGyms[index].gOrientation}",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List _getGyms = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getGyms();
  }

  Future getGyms() async {
    var data = await FirebaseFirestore.instance.collection("Gyms").get();
    setState(
      () {
        _getGyms = List.from(
          data.docs.map(
            (doc) => GymsModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }
}
