# understand_tile_expand

Wondered why [ExpansionTile](https://github.com/flutter/flutter/blob/c5a4b4029c0798f37c4a39b479d7cb75daa7b05c/packages/flutter/lib/src/material/expansion_tile.dart#L30) did not have overflow issues.

Turns out [Align](https://github.com/flutter/flutter/blob/fa06b34024e84f4cba2b67f4c66c20297b4710de/packages/flutter/lib/src/widgets/basic.dart#L1891) uses a [RenderPositionedBox](https://github.com/flutter/flutter/blob/bd69fa59356d2d007730b83635f5cf99c032f94b/packages/flutter/lib/src/rendering/shifted_box.dart#L366) that can [loosen the constraints of its child](https://github.com/flutter/flutter/blob/bd69fa59356d2d007730b83635f5cf99c032f94b/packages/flutter/lib/src/rendering/shifted_box.dart#L430) if `Align(heightFactor: ...)` or `Align(widthFactor: ...)` is set.
