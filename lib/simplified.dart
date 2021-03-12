import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: SimpleExpansionTile(
          title: Text('Click Me'),
          children: [
            Text("Child 1"),
            Text("Child 2"),
            Text("Child 3"),
            CircularProgressIndicator(),
            Text("Child 4"),
            Text("Child 5"),
            Text("Child 6"),
          ],
        ),
      ),
    );
  }
}

class SimpleExpansionTile extends StatefulWidget {
  const SimpleExpansionTile({
    Key? key,
    required this.title,
    this.children = const <Widget>[],
  }) : super(key: key);

  final Widget title;
  final List<Widget> children;

  @override
  _SimpleExpansionTileState createState() => _SimpleExpansionTileState();
}

class _SimpleExpansionTileState extends State<SimpleExpansionTile> with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);

  late AnimationController _controller;
  late Animation<double> _heightFactor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _heightFactor = _controller.drive(_easeInTween);

    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  final mainDecoration = BoxDecoration(
    color: Colors.transparent,
    border: Border(
      top: BorderSide(color: Colors.blue),
      bottom: BorderSide(color: Colors.blue),
    ),
  );
  final subDecoration = BoxDecoration(
    color: Colors.transparent,
    border: Border(
      top: BorderSide(color: Colors.red),
      bottom: BorderSide(color: Colors.red),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;

    final Widget childrenContainer = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widget.children,
    );

    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      // The null here does not seem to matter
      // but probably more performant to simply not have the subtree if it is invisible anyway
      child: closed ? null : childrenContainer,
    );
  }

  Widget _buildChildren(BuildContext context, Widget? childrenContainer) {
    return Container(
      decoration: mainDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            onTap: _handleTap,
            title: widget.title,
          ),
          // withouth the clip, the child would just be drawn on top
          Align(
            alignment: Alignment.center,
            // this.height = heightFactor * children.height
            // from 0 -> 1 on animate open
            // from 1 -> 0 on animate close
            //
            // This uses RenderPositionedBox to get the childs size via getDryLayout
            // (See below snippet)
            heightFactor: _heightFactor.value,
            child: childrenContainer,
          ),
        ],
      ),
    );
  }
}
