import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../utilities/export.dart';

class Account extends StatefulWidget {
  const Account({super.key, required this.image, required this.userdata});
  final String image;
  final dynamic userdata;
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final BannerAd bannerAdUnit = BannerAd(
    adUnitId: AdService.adUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: AdService.bannerAdListener,
  )..load();

  final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance.collection('users');

  final List genderItems = ['Male', 'Female'];
  final List goalItems = ['Gain', 'Lose', 'Maintain'];
  final List levelItems = ['Beginner', 'Intermediate', 'Advanced'];
  final List lifestyleItems = [
    'Sedentary',
    'Lightly active',
    'Moderately active',
    'Very active',
    'Extremely active'
  ];

  String? selectedValue;

  final _formKey = GlobalKey<FormState>();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _age = TextEditingController();
  final _firstName = TextEditingController();
  String gender = "";
  String goal = "";
  String level = "";
  String lifestyle = "";
  @override
  void initState() {
    _firstName.text = widget.userdata['firstname'];
    _height.text = widget.userdata['height'].toString();
    _weight.text = widget.userdata['weight'].toString();
    _age.text = widget.userdata['age'].toString();
    super.initState();
  }

  Future updateUserdata() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      int height = int.parse(_height.text);
      int weight = int.parse(_weight.text);
      int age = int.parse(_age.text);
      db.doc(user!.uid).update({
        'firstname': _firstName.text,
        'gender': gender,
        'height': height,
        'weight': weight,
        'age': age,
        'goal': goal,
        'level': level,
        'lifestyle': lifestyle,
      });
      successMsg('Changes Saved. Please restart the App!', context);

      setState(() {
        document = db.doc(user.uid).get();
      });
    } catch (e) {
      errorMsg(e.toString(), context);
    }
  }

  @override
  void dispose() {
    _age.dispose();
    _weight.dispose();
    _height.dispose();
    _firstName.dispose();
    super.dispose();
  }

  dynamic document;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Account",
          style: Theme.of(context).textTheme.titleMedium,
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
                image: DecorationImage(
                  image: CachedNetworkImageProvider(widget.image),
                ),
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                SizedBox(
                  height: 85,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textCapitalization: TextCapitalization.words,
                    controller: _firstName,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This is a required field';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                        borderSide: BorderSide(
                          width: 1,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      label: const Text("First Name"),
                      labelStyle: theme.labelLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 85,
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textCapitalization: TextCapitalization.words,
                          keyboardType: TextInputType.number,
                          controller: _height,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This is a required field';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                              borderSide: BorderSide(
                                width: 1,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            label: const Text("Height (cm)"),
                            labelStyle: theme.labelLarge,
                            filled: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: SizedBox(
                        height: 85,
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textCapitalization: TextCapitalization.words,
                          keyboardType: TextInputType.number,
                          controller: _weight,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This is a required field';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                              borderSide: BorderSide(
                                width: 1,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            label: const Text("Weight (kg)"),
                            labelStyle: theme.labelLarge,
                            filled: true,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 85,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.number,
                    controller: _age,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This is a required field';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                        borderSide: BorderSide(
                          width: 1,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      label: const Text("Age"),
                      labelStyle: theme.labelLarge,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 85,
                  child: DropdownButtonFormField2(
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    isExpanded: true,
                    hint: Text(
                      'Select Your Gender',
                      style: theme.labelLarge,
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                    ),
                    iconSize: 30,
                    buttonHeight: 60,
                    buttonPadding: const EdgeInsets.only(right: 10),
                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    items: genderItems
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item, style: theme.labelLarge),
                            ))
                        .toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your gender.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        gender = value!;
                      });
                    },
                    onSaved: (value) {
                      selectedValue = value.toString();
                    },
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 85,
                  child: DropdownButtonFormField2(
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    isExpanded: true,
                    hint: Text(
                      'Select Your Goal',
                      style: theme.labelLarge,
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                    ),
                    iconSize: 30,
                    buttonHeight: 60,
                    buttonPadding: const EdgeInsets.only(right: 10),
                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    items: goalItems
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item, style: theme.labelLarge),
                            ))
                        .toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your goal.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        goal = value!;
                      });
                    },
                    onSaved: (value) {
                      selectedValue = value.toString();
                    },
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 85,
                  child: DropdownButtonFormField2(
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    isExpanded: true,
                    hint: Text(
                      'Select Your Lifestyle',
                      style: theme.labelLarge,
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                    ),
                    iconSize: 30,
                    buttonHeight: 60,
                    buttonPadding: const EdgeInsets.only(right: 10),
                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    items: lifestyleItems
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item, style: theme.labelLarge),
                            ))
                        .toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your lifestyle.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        lifestyle = value!;
                      });
                    },
                    onSaved: (value) {
                      selectedValue = value.toString();
                    },
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 85,
                  child: DropdownButtonFormField2(
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    isExpanded: true,
                    hint: Text(
                      'Select Your Level',
                      style: theme.labelLarge,
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                    ),
                    iconSize: 30,
                    buttonHeight: 60,
                    buttonPadding: const EdgeInsets.only(right: 10),
                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    items: levelItems
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item, style: theme.labelLarge),
                            ))
                        .toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your level.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        level = value!;
                      });
                    },
                    onSaved: (value) {
                      selectedValue = value.toString();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          CupertinoButton.filled(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                updateUserdata();
              }
            },
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'Save Changes',
              style: theme.titleSmall,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 50, width: width, child: AdWidget(ad: bannerAdUnit)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
