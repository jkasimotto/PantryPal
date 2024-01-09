import 'package:flutter/material.dart';

class ProgressWithAnimatedWidget extends StatefulWidget {
  final Widget customWidget;
  final Duration duration;

  ProgressWithAnimatedWidget(
      {Key? key, required this.customWidget, required this.duration})
      : super(key: key);

  @override
  _ProgressWithAnimatedWidgetState createState() =>
      _ProgressWithAnimatedWidgetState();
}

class _ProgressWithAnimatedWidgetState extends State<ProgressWithAnimatedWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _progressAnimation =
        Tween<double>(begin: 0, end: 1).animate(_progressController)
          ..addListener(() {
            setState(() {});
          });

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              Positioned(
                left: _progressAnimation.value * constraints.maxWidth,
                child: widget.customWidget,
              ),
            ],
          );
        },
      ),
    );
  }
}
