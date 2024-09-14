
class GymWorkoutModel {
  String eCategory;
  String? eReps;
  String? eSets;
  String eHowTo;
  String? eHowToVideo;
  String eImage;
  String? eKcal;
  String eName;
  String eTarget;

  GymWorkoutModel({
    required this.eCategory,
    this.eReps,
    required this.eHowTo,
    this.eHowToVideo,
    this.eSets,
    required this.eImage,
    this.eKcal,
    required this.eName,
    required this.eTarget,
  });

  Map<String, dynamic> toJson() => {
        'eCategory': eCategory,
        'eReps': eReps,
        'eHowTo': eHowTo,
        'eHowToVideo': eHowToVideo,
        'eSets': eSets,
        'eImage': eImage,
        'eKcal': eKcal,
        'eName': eName,
        'eTarget': eTarget,
      };
  GymWorkoutModel.fromSnapshot(snapshot)
      : eCategory = snapshot.data()['eCategory'],
        eReps = snapshot.data()['eReps'],
        eHowTo = snapshot.data()['eHowTo'],
        eHowToVideo = snapshot.data()['eHowToVideo'],
        eSets = snapshot.data()['eSets'],
        eImage = snapshot.data()['eImage'],
        eKcal = snapshot.data()['eKcal'],
        eName = snapshot.data()['eName'],
        eTarget = snapshot.data()['eTarget'];
}
