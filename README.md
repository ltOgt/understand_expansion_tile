# understand_tile_expand

Wondered why [ExpansionTile](https://github.com/flutter/flutter/blob/c5a4b4029c0798f37c4a39b479d7cb75daa7b05c/packages/flutter/lib/src/material/expansion_tile.dart#L30) did not have overflow issues.

It seems like [Align](https://github.com/flutter/flutter/blob/fa06b34024e84f4cba2b67f4c66c20297b4710de/packages/flutter/lib/src/widgets/basic.dart#L1891) uses a [RenderPositionedBox](https://github.com/flutter/flutter/blob/bd69fa59356d2d007730b83635f5cf99c032f94b/packages/flutter/lib/src/rendering/shifted_box.dart#L366) that can [reduce its own size](https://github.com/flutter/flutter/blob/bd69fa59356d2d007730b83635f5cf99c032f94b/packages/flutter/lib/src/rendering/shifted_box.dart#L431) if `Align(heightFactor: ...)` or `Align(widthFactor: ...)` is set,
while [drawing its child with an offset](https://github.com/flutter/flutter/blob/bd69fa59356d2d007730b83635f5cf99c032f94b/packages/flutter/lib/src/rendering/shifted_box.dart#L69) determined by [some alignment logic](https://github.com/flutter/flutter/blob/bd69fa59356d2d007730b83635f5cf99c032f94b/packages/flutter/lib/src/rendering/shifted_box.dart#L337)


## files
`lib/main.dart` contains the entry to three examples.

`lib/simplified_example.dart` is a reduced version of `ExpansionTile` with some comments written while trying to understand what circumvents the overflow issues.

![2021031212:41:35_screenshot_sel](https://user-images.githubusercontent.com/24209580/110935924-61f44780-8330-11eb-996c-30c8e07f10d7.png)


`lib/visible_example.dart` contains an even more reduced version of `ExpansionTile` which highlights the role of `Align` (and its RenderBox).
It looks differently, since the align is not clipped.
Also the subtree is never removed on the closed state:

![2021031209:23:42_screenshot_sel](https://user-images.githubusercontent.com/24209580/110915948-90662880-8318-11eb-8435-4f18c4eab4f0.png)

`lib/renderbox_example.dart` is a stripped down version of `RenderPositionedBox` without the alignment.
You can specify an `offset` to move the child away from the parent and `thisSmallerThanChild` to reduce the parents size in relation to its child.

![2021031212:42:03_screenshot_sel](https://user-images.githubusercontent.com/24209580/110935938-66206500-8330-11eb-81a2-c35e9dfc10f9.png)

