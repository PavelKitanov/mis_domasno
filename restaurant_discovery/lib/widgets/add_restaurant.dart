import 'package:flutter/material.dart';
import 'package:restaurant_discovery/models/restaurant.dart';

class AddRestaurant extends StatefulWidget {
  final Function addItem;

  AddRestaurant(this.addItem);

  @override
  State<StatefulWidget> createState() => _AddRestaurantState();
}

class _AddRestaurantState extends State<AddRestaurant> {
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _addressController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  void _submitData() {
    final String name = _nameController.text;
    final String typeFood = _typeController.text;
    final String address = _addressController.text;
    final String startTime = _startController.text;
    final String endTime = _endController.text;

    if (name.isEmpty ||
        typeFood.isEmpty ||
        address.isEmpty ||
        startTime.isEmpty ||
        endTime.isEmpty) return;

    final newItem = RestaurantData(
        name: name,
        typeOfFood: typeFood,
        address: address,
        start: TimeOfDay(
            hour: int.parse(startTime.split(":")[0]),
            minute: int.parse(startTime.split(":")[1])),
        end: TimeOfDay(
            hour: int.parse(endTime.split(":")[0]),
            minute: int.parse(endTime.split(":")[1])));
    widget.addItem(newItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Ensures the view is resized when the keyboard is shown
      appBar: AppBar(
        title: Text('Add restaurant'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                onSubmitted: (_) => _submitData(),
              ),
              TextField(
                controller: _typeController,
                decoration: InputDecoration(labelText: "Type of Food"),
                onSubmitted: (_) => _submitData(),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: "Address"),
                onSubmitted: (_) => _submitData(),
              ),
              TextField(
                controller: _startController,
                decoration: InputDecoration(labelText: "Start time"),
                onSubmitted: (_) => _submitData(),
              ),
              TextField(
                controller: _endController,
                decoration: InputDecoration(labelText: "End time"),
                onSubmitted: (_) => _submitData(),
              ),
              OutlinedButton(
                child: Text("Add"),
                onPressed: _submitData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
