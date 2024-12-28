import 'package:flutter/material.dart';

class RequirementItem extends StatelessWidget {
  final String text;
  final bool isMet;

  const RequirementItem({
    super.key,
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              isMet ? Icons.check_circle_outline : Icons.cancel_outlined,
              key: ValueKey<bool>(isMet),
              color: isMet ? Colors.green[400] : Colors.red[400],
              size: 16,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Requirement text with animation
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: isMet ? Colors.green[400] : Colors.red[400],
              fontSize: 13,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}

// Versi alternatif dengan hover effect untuk web
class RequirementItemWeb extends StatefulWidget {
  final String text;
  final bool isMet;

  const RequirementItemWeb({
    super.key,
    required this.text,
    required this.isMet,
  });

  @override
  State<RequirementItemWeb> createState() => _RequirementItemWebState();
}

class _RequirementItemWebState extends State<RequirementItemWeb> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: _isHovered ? 4 : 2,
        ),
        decoration: BoxDecoration(
          color: _isHovered
              ? (widget.isMet ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: Icon(
                widget.isMet ? Icons.check_circle_outline : Icons.cancel_outlined,
                key: ValueKey<bool>(widget.isMet),
                color: widget.isMet ? Colors.green[400] : Colors.red[400],
                size: 16,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Requirement text with animation
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: widget.isMet ? Colors.green[400] : Colors.red[400],
                fontSize: 13,
                fontWeight: widget.isMet ? FontWeight.w500 : FontWeight.normal,
              ),
              child: Text(widget.text),
            ),
          ],
        ),
      ),
    );
  }
}

// Tooltip version
class RequirementItemWithTooltip extends StatelessWidget {
  final String text;
  final bool isMet;
  final String? tooltipMessage;

  const RequirementItemWithTooltip({
    super.key,
    required this.text,
    required this.isMet,
    this.tooltipMessage,
  });

  @override
  Widget build(BuildContext context) {
    final Widget requirementItem = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              isMet ? Icons.check_circle_outline : Icons.cancel_outlined,
              key: ValueKey<bool>(isMet),
              color: isMet ? Colors.green[400] : Colors.red[400],
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: isMet ? Colors.green[400] : Colors.red[400],
              fontSize: 13,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
            child: Text(text),
          ),
        ],
      ),
    );

    if (tooltipMessage != null) {
      return Tooltip(
        message: tooltipMessage!,
        child: requirementItem,
      );
    }

    return requirementItem;
  }
}