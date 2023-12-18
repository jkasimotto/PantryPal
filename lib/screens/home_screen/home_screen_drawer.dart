// my_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_recipes/models/recipe_model.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:provider/provider.dart';

class HomeScreenDrawer extends StatefulWidget {
  @override
  _HomeScreenDrawerState createState() => _HomeScreenDrawerState();
}

class _HomeScreenDrawerState extends State<HomeScreenDrawer> {
  int _minutesRequired = 0;
  List<Difficulty> _difficulty = [];

  @override
  Widget build(BuildContext context) {
    _minutesRequired = Provider.of<GlobalState>(context).minutesRequired;
    print("_minutesRequired: $_minutesRequired");
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Slider(
              value: _minutesRequired.toDouble(),
              min: 0,
              max: 180,
              divisions: 180 ~/ 5,
              
              label: _minutesRequired.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _minutesRequired = value.round();
                  Provider.of<GlobalState>(context, listen: false).setMinutesRequired(_minutesRequired);
                });
              },
            ),
            subtitle: Text('Time'),
          ),
          ...Difficulty.values.map((difficulty) => CheckboxListTile(
            title: Text(difficulty.toString().split('.')[1]),
            value: _difficulty.contains(difficulty),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _difficulty.add(difficulty);
                } else {
                  _difficulty.remove(difficulty);
                }
                Provider.of<GlobalState>(context, listen: false).setDifficulty(_difficulty);
              });
            },
          )).toList(),
        ],
      ),
    );
  }
}