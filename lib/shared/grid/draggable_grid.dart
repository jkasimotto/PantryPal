import 'package:flutter/material.dart';

class DraggableGrid extends StatefulWidget {
  final List<Widget> items;
  final Function(int oldIndex, int newIndex) onReorder;
  final int crossAxisCount;
  final double childAspectRatio;
  final double elevation;

  const DraggableGrid({
    super.key,
    required this.items,
    required this.onReorder,
    this.crossAxisCount = 3,
    this.childAspectRatio = 1.0,
    this.elevation = 4.0,
  });

  @override
  _DraggableGridState createState() => _DraggableGridState();
}

class _DraggableGridState extends State<DraggableGrid> {
  late List<Widget> items;
  late List<ValueNotifier<bool>> isDraggingList;

  @override
  void initState() {
    super.initState();
    items = widget.items;
    isDraggingList = List.generate(items.length, (_) => ValueNotifier(false));
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return DragTarget<int>(
          builder: (context, candidateData, rejectedData) {
            return Draggable<int>(
              data: index,
              onDragStarted: () => isDraggingList[index].value = true,
              onDragCompleted: () => isDraggingList[index].value = false,
              onDraggableCanceled: (_, __) =>
                  isDraggingList[index].value = false,
              feedback: Material(
                elevation: widget.elevation,
                child: items[index],
              ),
              child: ValueListenableBuilder<bool>(
                valueListenable: isDraggingList[index],
                builder: (context, isDragging, child) {
                  return isDragging ? Container() : items[index];
                },
              ),
            );
          },
          onWillAccept: (data) => true,
          onAccept: (data) {
            setState(() {
              Widget temp = items[data];
              items[data] = items[index];
              items[index] = temp;
            });
            widget.onReorder(data, index);
          },
        );
      },
    );
  }
}
