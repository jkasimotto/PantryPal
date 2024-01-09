import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExpandableFab extends StatefulWidget {
  final bool? initialOpen;
  final double distance;
  final List<Widget> children;
  final ValueNotifier<bool>? toggleController;

  const ExpandableFab({
    Key? key,
    this.initialOpen,
    required this.distance,
    required this.children,
    this.toggleController,
  }) : super(key: key);

  @override
  _ExpandableFabState createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );

    widget.toggleController?.addListener(_toggleControllerListener);
  }

  @override
  void dispose() {
    widget.toggleController?.removeListener(_toggleControllerListener);
    _controller.dispose();
    super.dispose();
  }

  void _toggleControllerListener() {
    if (widget.toggleController?.value != _open) {
      _toggle();
    }
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          ..._buildExpandingActionButtons(),
          FloatingActionButton(
            heroTag: 'floating-fab-up',
            onPressed: _toggle,
            child: _open
                ? const Icon(FontAwesomeIcons.arrowDown)
                : const Icon(FontAwesomeIcons.arrowUp),
          ),
          FloatingActionButton(
            heroTag: 'floating-fab-down',
            onPressed: _toggle,
            child: _open
                ? const Icon(FontAwesomeIcons.arrowDown)
                : const Icon(FontAwesomeIcons.arrowUp),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = (widget.distance * 2) / (count - 1);
    for (var i = 0, offset = step; i < count; i++, offset += step) {
      children.add(
        _ExpandingActionButton(
          offset: offset,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }
}

class _ExpandingActionButton extends StatelessWidget {
  final double offset;
  final Animation<double> progress;
  final Widget child;

  const _ExpandingActionButton({
    required this.offset,
    required this.progress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        return Positioned(
          right: 0.0,
          bottom: offset * progress.value,
          child: Transform.scale(
            scale: progress.value,
            child: child!,
          ),
        );
      },
      child: child,
    );
  }
}

class ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;

  const ActionButton({
    Key? key,
    this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'tagtag3',
      onPressed: onPressed,
      child: icon,
    );
  }
}
