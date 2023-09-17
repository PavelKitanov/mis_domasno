import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_discovery/models/restaurant.dart';
import 'package:restaurant_discovery/pages/change_credentials_page.dart';
import 'package:restaurant_discovery/widgets/add_restaurant.dart';

import '../services/authentication.dart';
import 'detail_page.dart';
import 'map_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Restaurant> _restaurants = [];

  late DatabaseReference dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('Restaurants');
    fetchData();
  }

  void fetchData() {
    dbRef.onChildAdded.listen((data) {
      RestaurantData restaurantData =
          RestaurantData.fromJson(data.snapshot.value as Map);
      Restaurant restaurant =
          Restaurant(key: data.snapshot.key, restaurantData: restaurantData);
      _restaurants.add(restaurant);
      if (this.mounted) {
        setState(() {
          // Your state change code goes here
        });
      }
    });
  }

  void _addItemFunction(BuildContext ct) {
    showModalBottomSheet(
        context: ct,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            child: AddRestaurant(_addNewItemToList),
            behavior: HitTestBehavior.opaque,
          );
        });
  }

  void _addNewItemToList(RestaurantData item) {
    Map<String, dynamic> restaurants = {
      'name': item.name,
      'typeOfFood': item.typeOfFood,
      'address': item.address,
      'start': item.start!.format(context),
      'end': item.end!.format(context),
    };
    dbRef
        .push()
        .set(restaurants)
        .then((value) => {Navigator.of(context).pop()});
  }

  void _deleteItem(Restaurant item) {
    dbRef.child(item.key!).remove().then(
      (value) {
        int index =
            _restaurants.indexWhere((element) => element.key == item.key!);
        _restaurants.removeAt(index);
      },
    );
    setState(() {
      _restaurants.removeWhere((element) => element.key == item.key);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color customPrimaryColor = Color(0xFFFF6B6B);
    Color customCardColor = Color.fromARGB(255, 245, 224, 208);

    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: customPrimaryColor,
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            _addItemFunction(context);
          },
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
              onPressed: () {},
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
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChangeCredentialsPage(),
                ));
              },
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                Auth().signOut();
              },
            ),
          ],
        ),
      ),
    );

    final makeBody = SingleChildScrollView(
        child: Container(
        child: _restaurants.isEmpty
          ? Center(
              child: Text(
                "No restaurants.",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  elevation: 8.0,
                  margin:
                      new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Container(
                    decoration: BoxDecoration(color: customCardColor),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      title: Text(
                        "Name: ${_restaurants[index].restaurantData?.name}",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      subtitle: Row(
                        children: <Widget>[
                          Icon(Icons.fastfood,
                              color: customPrimaryColor, size: 30),
                          Expanded(
                            child: Text(
                              " ${_restaurants[index].restaurantData?.typeOfFood}",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: customPrimaryColor, size: 30.0),
                            onPressed: () => _deleteItem(_restaurants[index]),
                          ),
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_right,
                                color: customPrimaryColor, size: 34.0),
                            onPressed: () => _deleteItem(_restaurants[
                                index]), // Change this to the action you want to perform
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailPage(
                                    restaurant: _restaurants[index])));
                      },
                    ),
                  ),
                );
              },
              itemCount: _restaurants.length,
            ),
        )
    );

    return Scaffold(
      backgroundColor: Color(0xFFFFC3A0),
      appBar: topAppBar,
      body: makeBody,
      bottomNavigationBar: makeBottom,
    );
  }
}
