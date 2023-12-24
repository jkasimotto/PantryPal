// my_drawer.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipes/shared/global_state.dart';
import 'package:provider/provider.dart';

class HomeScreenDrawer extends StatefulWidget {
  const HomeScreenDrawer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenDrawerState createState() => _HomeScreenDrawerState();
}

class _HomeScreenDrawerState extends State<HomeScreenDrawer> {
  int _minutesRequired = 0;

  @override
  Widget build(BuildContext context) {
    _minutesRequired = Provider.of<GlobalState>(context).minutesRequired;
    if (kDebugMode) {
      print("_minutesRequired: $_minutesRequired");
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
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
                  Provider.of<GlobalState>(context, listen: false)
                      .setMinutesRequired(_minutesRequired);
                });
              },
            ),
            subtitle: const Text('Time'),
          ),
        ],
      ),
    );
  }
}
