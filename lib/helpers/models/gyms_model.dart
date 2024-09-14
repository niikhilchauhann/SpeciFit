class GymsModel {
  String gName;
  String gAddress;
  String gImage;
  List gImages;
  String gTrainer;
  String gOrientation;
  String gFacilities;
  int gSize;
  int gFees;
  dynamic gRating;
  String gCity;
  dynamic gContact;

  GymsModel({
    required this.gName,
    required this.gAddress,
    required this.gImage,
    required this.gTrainer,
    required this.gOrientation,
    required this.gFacilities,
    required this.gSize,
    required this.gFees,
    required this.gRating,
    required this.gCity,
    required this.gContact,
    required this.gImages,
  });

  Map<String, dynamic> toJson() => {
        'gName': gName,
        'gAddress': gAddress,
        'gImage': gImage,
        'gTrainer': gTrainer,
        'gOrientation': gOrientation,
        'gFacilities': gFacilities,
        'gSize': gSize,
        'gFees': gFees,
        'gRating': gRating,
        'gCity': gCity,
        'gContact': gContact,
        'gImages': gImages,
      };
  GymsModel.fromSnapshot(snapshot)
      : gName = snapshot.data()['gName'],
        gAddress = snapshot.data()['gAddress'],
        gImage = snapshot.data()['gImage'],
        gTrainer = snapshot.data()['gTrainer'],
        gOrientation = snapshot.data()['gOrientation'],
        gFacilities = snapshot.data()['gFacilities'],
        gSize = snapshot.data()['gSize'],
        gFees = snapshot.data()['gFees'],
        gRating = snapshot.data()['gRating'],
        gCity = snapshot.data()['gCity'],
        gContact = snapshot.data()['gContact'],
        gImages = snapshot.data()['gImages'];
}
