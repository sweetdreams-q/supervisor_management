import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HoverCard extends StatefulWidget {
  const HoverCard({super.key, required this.child, this.onTap, this.margin, this.padding, this.color, this.elevation = 0});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double elevation;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isInteractive = widget.onTap != null;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      transform: Matrix4.identity()..setTranslationRaw(0.0, _isHovered && kIsWeb ? -4.0 : 0.0, 0.0),
      child: Card(
        elevation: _isHovered && kIsWeb ? widget.elevation + 4 : widget.elevation,
        color: widget.color ?? colorScheme.surfaceContainerLow,
        margin: widget.margin,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (hovered) {
            if (!isInteractive) {
              return;
            }
            setState(() {
              _isHovered = hovered;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(16),
            child: widget.child,
          ),
        ),
      ),
    );

    if (!isInteractive) {
      return card;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (kIsWeb) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (kIsWeb) {
          setState(() => _isHovered = false);
        }
      },
      child: card,
    );
  }
}
