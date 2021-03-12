import 'package:flutter/material.dart';
import 'package:tile_expand/simplified_example.dart';
import 'package:tile_expand/visible_example.dart';
import 'package:tile_expand/renderbox_example.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  List<Widget> children = [
    Text("Child 1"),
    Text("Child 2"),
    Text("Child 3"),
    CircularProgressIndicator(),
    Text("Child 4"),
    Text("Child 5"),
    Text("Child 6"),
  ];

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: Scaffold(
        /// Reduced example with same visual result as original ExpansionTile
        // body: SimplifiedExpansionTile(
        //   title: Text('Click Me'),
        //   children: children,
        // ),

        /// Reduced example without clipping or hiding the child on collapse
        //body: VisibleExpansionTile(
        //  title: Text('Click Me'),
        //  children: children,
        //),

        /// RenderBox.paint can paint child outside its ~position-constraints
        /// It can also have a smaller size than its child
        body: PaintChildOutsideTest(),
      ),
    );
  }
}
