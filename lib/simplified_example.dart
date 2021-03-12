import 'package:flutter/material.dart';

/// Removed all but the essential parts from ExpansionTile
/// Also added some comments
class SimplifiedExpansionTile extends StatefulWidget {
  const SimplifiedExpansionTile({
    Key? key,
    required this.title,
    this.children = const <Widget>[],
  }) : super(key: key);

  final Widget title;
  final List<Widget> children;

  @override
  _SimplifiedExpansionTileState createState() => _SimplifiedExpansionTileState();
}

class _SimplifiedExpansionTileState extends State<SimplifiedExpansionTile> with SingleTickerProviderStateMixin {
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
      // needs another build to choose `null` after animation completes, see above in _handleTap
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
          // withouth the clip, the child would just be drawn on top (see visible_example.dart)
          ClipRect(
            child: Container(
              decoration: subDecoration,
              // Using Align(heightFactor: ...) reduces the size of Aligns underlying RenderPositionedBox while keeping the size of its child the same
              // see renderbox_example.dart (and PaintChildOutsideTest()) in main to see how RenderBox.paint can draw outside of its own constraints
              child: Align(
                alignment: Alignment.center,
                // this.height = heightFactor * children.height
                // from 0 -> 1 on animate open
                // from 1 -> 0 on animate close
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
