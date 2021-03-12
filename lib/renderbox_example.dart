import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PaintChildOutsideTest extends StatelessWidget {
  const PaintChildOutsideTest();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      color: Colors.red,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          YellowHeader(),
          PaintChildOutside(
            /// Play with this parameter to see how the child can be positioned outside of the parents position
            offset: Offset(20, 20),

            /// Play with this parameter to see how the renderObject will have a smaller size than its child
            //thisSmallerThanChild: 100,
            thisSmallerThanChild: 0,
            child: Container(
              // : These sizes will still be limited by the constraints from above
              width: 100,
              height: 100,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class PaintChildOutside extends SingleChildRenderObjectWidget {
  const PaintChildOutside({
    Key? key,
    required Widget child,
    required this.offset,
    this.thisSmallerThanChild = 0,
  }) : super(
          key: key,
          // child is passed to SingleChildRenderObjectWidget
          child: child,
        );

  final Offset offset;
  final double thisSmallerThanChild;

  @override
  RenderChildOutsideBox createRenderObject(BuildContext context) {
    return RenderChildOutsideBox(
      offset: offset,
      smallerThanChild: thisSmallerThanChild,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderChildOutsideBox renderObject) {
    renderObject
      ..offset = offset
      ..smallerThanChild = thisSmallerThanChild;
  }
}

class RenderChildOutsideBox extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  /// Creates a render object that positions its child.
  RenderChildOutsideBox({
    RenderBox? child,
    required Offset offset,
    double smallerThanChild = 0,
  }) {
    // ? from mixin
    this.child = child;

    // need to be internal and non-final so the render object can be updated
    this._offset = offset;
    this._smallerThanChild = smallerThanChild;
  }

  late Offset _offset;
  late double _smallerThanChild;
  set offset(Offset offset) {
    _offset = offset;
    markNeedsLayout();
  }

  set smallerThanChild(double smallerThanChild) {
    _smallerThanChild = smallerThanChild;
    markNeedsLayout();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final bool shrinkWrapWidth = constraints.maxWidth == double.infinity;
    final bool shrinkWrapHeight = constraints.maxHeight == double.infinity;
    if (child != null) {
      final Size childSize = child!.getDryLayout(constraints);
      // : This renderbox is now smaller than the child (try "Toggle Debug Painting")
      return constraints.constrain(Size(
        childSize.width - _smallerThanChild,
        childSize.height - _smallerThanChild,
      ));
    }
    // never reached in this example
    return constraints.constrain(Size(
      shrinkWrapWidth ? 0.0 : double.infinity,
      shrinkWrapHeight ? 0.0 : double.infinity,
    ));
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final bool shrinkWrapWidth = constraints.maxWidth == double.infinity;
    final bool shrinkWrapHeight = constraints.maxHeight == double.infinity;

    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      // : This renderbox is now smaller than the child (try "Toggle Debug Painting")
      size = constraints.constrain(Size(
        child!.size.width - _smallerThanChild,
        child!.size.height - _smallerThanChild,
      ));
    } else {
      // never reached in this example
      size = constraints.constrain(Size(
        shrinkWrapWidth ? 0.0 : double.infinity,
        shrinkWrapHeight ? 0.0 : double.infinity,
      ));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      // Here we paint the child with an offset
      context.paintChild(child!, childParentData.offset + offset + this._offset);
    }
  }
}

class YellowHeader extends StatelessWidget {
  const YellowHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      width: 100,
      height: 50,
    );
  }
}
