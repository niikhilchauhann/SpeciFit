import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../utilities/export.dart';
import '../../../utilities/videoplayer/player.dart';

class HomeWorkouts extends StatefulWidget {
  final String genderDoc;
  final String collectionName;
  const HomeWorkouts({
    super.key,
    required this.genderDoc,
    required this.collectionName,
  });

  @override
  State<HomeWorkouts> createState() => _HomeWorkoutsState();
}

class _HomeWorkoutsState extends State<HomeWorkouts> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Home Workouts",
          style: theme.titleMedium,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          iconSize: 20,
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _homeworkoutData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        createRoute(
                          VideoPlayer(
                            videoUrl: _homeworkoutData[index].hwVideoId,
                            startAt: 0.0,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 225,
                      decoration: BoxDecoration(
                          boxShadow: kElevationToShadow[3],
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20)),
                                color: Theme.of(context).cardColor,
                                boxShadow: kElevationToShadow[3],
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      "https://img.youtube.com/vi/${_homeworkoutData[index].hwVideoId}/maxresdefault.jpg"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_homeworkoutData[index].hwName,
                                    style: theme.titleSmall),
                                const SizedBox(height: 2),
                                Text(
                                  _homeworkoutData[index].hwDescription,
                                  style: theme.labelLarge,
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
            ),
          ),
        ],
      ),
    );
  }

  List _homeworkoutData = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    homeWorkoutData();
  }

  Future homeWorkoutData() async {
    var data = await FirebaseFirestore.instance
        .collection("HomeWorkouts")
        .doc(widget.genderDoc)
        .collection(widget.collectionName)
        .get();
    setState(
      () {
        _homeworkoutData = List.from(
          data.docs.map(
            (doc) => VideosModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }
}
