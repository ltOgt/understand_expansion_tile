import 'package:flutter/material.dart';

/// Not only simplified, but also remove Clipping and pruning from tree on collapse
class VisibleExpansionTile extends StatefulWidget {
  const VisibleExpansionTile({
    Key? key,
    required this.title,
    this.children = const <Widget>[],
  }) : super(key: key);

  final Widget title;
  final List<Widget> children;

  @override
  _VisibleExpansionTileState createState() => _VisibleExpansionTileState();
}

class _VisibleExpansionTileState extends State<VisibleExpansionTile> with SingleTickerProviderStateMixin {
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
    final Widget childrenContainer = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widget.children,
    );

    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: childrenContainer,
    );
  }

  Widget _buildChildren(BuildContext context, Widget? childrenContainer) {
    bool _break = false;

    return Container(
      decoration: mainDecoration,
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: _handleTap,
            title: widget.title,
          ),
          if (!_break)
            // Using Align(heightFactor: ...) reduces the size of Aligns underlying RenderPositionedBox while keeping the size of its child the same
            // see move_outside.dart (and PaintChildOutsideTest()) in main to see how RenderBox.paint can draw outside of its own constraints
            Align(
              alignment: Alignment.center,
              // this.height = heightFactor * children.height
              // from 0 -> 1 on animate open
              // from 1 -> 0 on animate close
              heightFactor: _heightFactor.value,
              child: childrenContainer,
            ),
          if (_break)
            // this Container does not use RenderPositionedBox
            // try setting _break=true to see an overflow
            Container(
              alignment: Alignment.center,
              // rough estimate of the childs size for this example
              height: 200 * _heightFactor.value,
              child: childrenContainer,
            ),
        ],
      ),
    );
  }
}
