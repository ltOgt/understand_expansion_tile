import 'package:flutter/material.dart';
import 'package:tile_expand/simplified.dart';

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
        //body: ExpansionTile(
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

class ExpansionTile extends StatefulWidget {
  /// Creates a single-line [ListTile] with a trailing button that expands or collapses
  /// the tile to reveal or hide the [children]. The [initiallyExpanded] property must
  /// be non-null.
  const ExpansionTile({
    Key? key,
    required this.title,
    this.children = const <Widget>[],
  }) : super(key: key);

  final Widget title;
  final List<Widget> children;

  @override
  _ExpansionTileState createState() => _ExpansionTileState();
}

class _ExpansionTileState extends State<ExpansionTile> with SingleTickerProviderStateMixin {
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
        _controller.reverse()
            // this triggers another build after the animation finishes
            // without this the AnimatedBuilder.child will never be set to null
            .then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
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

    // I think the Offstage lets the subtree be measured without taking any space it self
    // Although removing Offstage does not seem to make a difference
    final Widget childrenContainer = Offstage(
      // The TickerMode seems to just pause animations in the subtree when the subtree is not visible
      // (manually set via TickerMode(enabled: __))
      // Take away the negation below to see this effect
      child: TickerMode(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.children,
        ),
        // Take away the negation and you see that the CircularProgressIndicator is paused
        enabled: !closed,
      ),
      offstage: closed,
    );

    // From AnimatedBuilder docstring:
    // If your [builder] function contains a subtree that does not depend on the
    // animation, it's more efficient to build that subtree once instead of
    // rebuilding it on every animation tick.
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
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
          ClipRect(
            child: Container(
              decoration: subDecoration,
              // Without the Align, the size of the child would never change
              // So no animation would be visible
              // Just (visible -> invisible) and (invisible -> visible)
              child: Align(
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
            ),
          ),
        ],
      ),
    );
  }
}

/* From RenderPositionedBox used by Align

@override
  Size computeDryLayout(BoxConstraints constraints) {
    final bool shrinkWrapWidth = _widthFactor != null || constraints.maxWidth == double.infinity;
    final bool shrinkWrapHeight = _heightFactor != null || constraints.maxHeight == double.infinity;
    if (child != null) {
      final Size childSize = child!.getDryLayout(constraints.loosen());
      return constraints.constrain(Size(
        shrinkWrapWidth ? childSize.width * (_widthFactor ?? 1.0) : double.infinity,
        shrinkWrapHeight ? childSize.height * (_heightFactor ?? 1.0) : double.infinity),
      );
    }
    return constraints.constrain(Size(
      shrinkWrapWidth ? 0.0 : double.infinity,
      shrinkWrapHeight ? 0.0 : double.infinity,
    ));
  }
*/
