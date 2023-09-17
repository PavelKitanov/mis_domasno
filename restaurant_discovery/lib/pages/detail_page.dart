import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restaurant_discovery/imageUtils/imageUtils.dart';
import 'package:restaurant_discovery/models/restaurant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/post.dart';
import '../resources/ImageStoreMethods.dart';
import '../services/authentication.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'navigation_page.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.restaurant}) : super(key: key);

  final Restaurant restaurant;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Uint8List? _file;
  List<String> imagesUrl = [];
  LatLng? destLocation;

  int activeIndex = 0;
  final controller = CarouselController();

  late DatabaseReference dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('Posts');
    fetchData();
    getLatLng();
  }

  Future<void> getLatLng() async {
    destLocation =
        await getLatLngFromAddress(widget.restaurant.restaurantData!.address!);
  }

  bool isTimeBetween(TimeOfDay startTime, TimeOfDay endTime) {
    final now = TimeOfDay.now();
    final currentTimeInMinutes = now.hour * 60 + now.minute;
    final startTimeInMinutes = startTime.hour * 60 + startTime.minute;
    final endTimeInMinutes = endTime.hour * 60 + endTime.minute;

    return currentTimeInMinutes >= startTimeInMinutes &&
        currentTimeInMinutes <= endTimeInMinutes;
  }

  void fetchData() {
    dbRef.onChildAdded.listen((data) {
      PostData postData = PostData.fromJson(data.snapshot.value as Map);
      Post post = Post(key: data.snapshot.key, postData: postData);
      if (post.postData!.restaurantKey! == widget.restaurant.key)
        imagesUrl.add(post.postData!.postUrl!);
      if (this.mounted) {
        setState(() {
          // Your state change code goes here
        });
      }
    });
  }

  // bool _isLoading = false;
  // void postImage() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     String res =
  //         await ImageStoreMethods().uploadPost(widget.restaurant.key!, _file!);
  //     if (res == 'success') {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       showSnackBar('Posted', context);
  //       clearImage();
  //     } else {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       showSnackBar(res, context);
  //     }
  //   } catch (err) {
  //     showSnackBar(err.toString(), context);
  //   }
  // }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  _imageSelect(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Select Image'),
            children: [
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Text('Take a Photo'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() async {
                    _file = file;
                    await ImageStoreMethods()
                        .uploadPost(widget.restaurant.key!, _file!);
                    clearImage();
                  });
                },
              ),
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Text('Choose From Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(
                    ImageSource.gallery,
                  );
                  setState(() async {
                    _file = file;
                    await ImageStoreMethods()
                        .uploadPost(widget.restaurant.key!, _file!);
                    clearImage();
                  });
                },
              ),
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Color customPrimaryColor = Color(0xFFFF6B6B);
    Color customCardColor = Color.fromARGB(255, 245, 224, 208);

    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: customPrimaryColor,
      title: Text("Restaurant details"),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add_a_photo),
          onPressed: () {
            _imageSelect(context);
          },
          iconSize: 35,
        )
      ],
    );

    final makeBottom = Container(
      height: 55.0,
      child: BottomAppBar(
        color: customPrimaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(Icons.map, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MapPage(),
                ));
              },
            ),
            IconButton(
              icon: Icon(Icons.account_box, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
                Auth().signOut();
              },
            ),
          ],
        ),
      ),
    );

    Widget buildImage(String urlImage, int index) =>
        Container(child: Image.network(urlImage, fit: BoxFit.cover));

    void animateToSlide(int index) => controller.animateToPage(index);

    Widget buildIndicator() => AnimatedSmoothIndicator(
          onDotClicked: animateToSlide,
          effect: ExpandingDotsEffect(
              dotWidth: 15, activeDotColor: customPrimaryColor),
          activeIndex: activeIndex,
          count: imagesUrl.length,
        );

    final topContent = Container(
      height: MediaQuery.of(context).size.height *
          0.4, // Set the desired height here
      child: Scaffold(
        backgroundColor: Color(0xFFFFC3A0),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imagesUrl.isEmpty
                ? Center(
                    child: Text(
                      "There are no images for this restaurant.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : CarouselSlider.builder(
                    carouselController: controller,
                    itemCount: imagesUrl.length,
                    itemBuilder: (context, index, realIndex) {
                      final urlImage = imagesUrl[index];
                      return buildImage(urlImage, index);
                    },
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height / 3,
                      autoPlay: true,
                      enableInfiniteScroll: false,
                      autoPlayAnimationDuration: Duration(seconds: 2),
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) =>
                          setState(() => activeIndex = index),
                    ),
                  ),
            SizedBox(height: 12),
            buildIndicator()
          ],
        ),
      ),
    );

    final bottomContent = Container(
      height: MediaQuery.of(context).size.height *
          0.5, // Replace with your desired height
      child: Scaffold(
        backgroundColor: Color(0xFFFFC3A0),
        body: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the content vertically
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center text horizontally
          children: [
            ListTile(
              title: Center(
                child: Text('Name',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: customPrimaryColor)),
              ),
              subtitle: Center(
                child: Text(widget.restaurant.restaurantData!.name!,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            ListTile(
              title: Center(
                child: Text('Type of Food',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: customPrimaryColor)),
              ),
              subtitle: Center(
                child: Text(
                  widget.restaurant.restaurantData!.typeOfFood!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              title: Center(
                child: Text('Address',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: customPrimaryColor)),
              ),
              subtitle: Center(
                child: Text(
                  widget.restaurant.restaurantData!.address!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              title: Center(
                child: Text('Working hours',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: customPrimaryColor)),
              ),
              subtitle: Center(
                child: Column(
                  children: [
                    Text(
                      '${widget.restaurant.restaurantData!.start!.format(context)} - ${widget.restaurant.restaurantData!.end!.format(context)}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isTimeBetween(widget.restaurant.restaurantData!.start!,
                              widget.restaurant.restaurantData!.end!)
                          ? "Open"
                          : "Closed",
                      style: TextStyle(
                        fontSize: 16,
                        color: isTimeBetween(
                                widget.restaurant.restaurantData!.start!,
                                widget.restaurant.restaurantData!.end!)
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => NavigationPage(
                      destLocation!.latitude, destLocation!.longitude),
                ),
                (route) => false);
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.all(16.0),
                ),
              ),
              child: Text(
                'Get directions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: topAppBar,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[topContent, bottomContent],
        ),
      ),
      bottomNavigationBar: makeBottom,
    );
  }
}

Future<LatLng> getLatLngFromAddress(String address) async {
  //final addresses = await Geocoder.local.findAddressesFromQuery(address);
  final addresses = await Geocoder2.getDataFromAddress(
      address: address,
      googleMapApiKey: "AIzaSyCEoNuZhn5JZIh82XrOu6ogNV09Gb3Dezg");

  return LatLng(addresses.latitude, addresses.longitude);
}
