class VideosModel {
  String hwName;
  String hwDescription;
  String? hwTime;
  String hwVideoId;
  dynamic hwStartAt;

  VideosModel({
    required this.hwName,
    required this.hwDescription,
    required this.hwTime,
    required this.hwVideoId,
    required this.hwStartAt,
    // required this.eName,
    // required this.eTarget,
    // required this.eTime
  });

  Map<String, dynamic> toJson() => {
        'hwName': hwName,
        'hwDescription': hwDescription,
        'hwTime': hwTime,
        'hwVideoId': hwVideoId,
        'hwStartAt': hwStartAt,
        // 'eName': eName,
        // 'eTarget': eTarget,
        // 'eTime': eTime
      };
  VideosModel.fromSnapshot(snapshot)
      : hwName = snapshot.data()['hwName'],
        hwDescription = snapshot.data()['hwDescription'],
        hwTime = snapshot.data()['hwTime'],
        hwVideoId = snapshot.data()['hwVideoId'],
        hwStartAt = snapshot.data()['hwStartAt'];
  // eName = snapshot.data()['eName'],
  // eTarget = snapshot.data()['eTarget'],
  // eTime = snapshot.data()['eTime'];
}
