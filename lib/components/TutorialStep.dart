// Tutorial Step Model
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TutorialStep {
  final String title;
  final String content;
  final GlobalKey targetKey;
  final bool showArrow; // Whether to show arrow for this step


  TutorialStep({
    required this.title,
    required this.content,
    required this.targetKey,
    this.showArrow = true,
  });
}

class SalesOrderTutorial extends StatefulWidget {
  final Widget child;
  final VoidCallback onComplete;
  final GlobalKey frequentlyPurchasedKey;
  final GlobalKey bouncedProductsKey;
  final GlobalKey customerDropdownKey;
  final GlobalKey retailerSelectorKey;
  final GlobalKey productSelectorKey;
  final GlobalKey showMoreKey;
  final GlobalKey addButtonKey;
  final GlobalKey osAmountKey;

  const SalesOrderTutorial({
    Key? key,
    required this.child,
    required this.onComplete,
    required this.frequentlyPurchasedKey,
    required this.bouncedProductsKey,
    required this.customerDropdownKey,
    required this.retailerSelectorKey,
    required this.productSelectorKey,
    required this.showMoreKey,
    required this.addButtonKey,
    required this.osAmountKey,
  }) : super(key: key);

  @override
  _SalesOrderTutorialState createState() => _SalesOrderTutorialState();
}

class _SalesOrderTutorialState extends State<SalesOrderTutorial> {
  int currentStep = 0;
  bool showTutorial = true;
  OverlayEntry? _currentOverlay;
  late List<TutorialStep> tutorialSteps;


  @override
  void initState() {
    super.initState();
    print("Tutorial State Initialized"); // Debug print

    print(widget.frequentlyPurchasedKey.currentContext);
    print(widget.bouncedProductsKey.currentContext);

    tutorialSteps = [
      TutorialStep(
        title: 'Frequently Purchased',
        content: 'Click here to quickly add products from your frequently purchased items history.',
        targetKey: widget.frequentlyPurchasedKey,
      ),
      TutorialStep(
        title: 'Bounced Products',
        content: 'Access and manage products that were previously bounced or returned.',
        targetKey: widget.bouncedProductsKey,
      ),
      TutorialStep(
        title: 'Customer Selection',
        content: 'Select the customer you want to create the sales order for.',
        targetKey: widget.customerDropdownKey,
      ),
      TutorialStep(
        title: 'Retailer Selection',
        content: 'Choose the specific retailer for this order.',
        targetKey: widget.retailerSelectorKey,
      ),
      TutorialStep(
        title: 'Product Selection',
        content: 'Select the products you want to add to the order.',
        targetKey: widget.productSelectorKey,
      ),
      TutorialStep(
        title: 'Show More Options',
        content: 'Click here to view additional product details like MRP, PTR, Stock, and Scheme.',
        targetKey: widget.showMoreKey,
      ),
      TutorialStep(
        title: 'Add Products',
        content: 'After setting quantity and other details, click here to add products to your order.',
        targetKey: widget.addButtonKey,
      ),
      TutorialStep(
        title: 'Outstanding Amount',
        content: 'View and manage the outstanding amount for this customer.',
        targetKey: widget.osAmountKey,
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCurrentStep();
    });


    print("Tutorial steps created: ${tutorialSteps.length}");

  }


  Widget _buildArrow(Offset targetPosition, Size targetSize, double tutorialBoxPosition) {
    return Positioned(
      left: targetPosition.dx + (targetSize.width / 2) - 12,
      top: tutorialBoxPosition - 8,
      child: CustomPaint(
        size: Size(24, 8),
        painter: ArrowPainter(
          color: Colors.black,
          shadowColor: Colors.black26,
        ),
      ),
    );
  }


  void _initializeTutorial() {
    if (showTutorial) {
      bool allTargetsAvailable = tutorialSteps.every((step) =>
      step.targetKey.currentContext?.findRenderObject() != null);

      if (allTargetsAvailable) {
        _showCurrentStep();
      } else {
        // Retry with a delay
        Future.delayed(Duration(milliseconds: 500), _initializeTutorial);
      }
    }
  }


  void _showCurrentStep() {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }

    if (currentStep >= tutorialSteps.length) {
      _completeTutorial();
      return;
    }

    final step = tutorialSteps[currentStep];
    final RenderBox? target = step.targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (target == null) {
      print("Target is null for step: ${step.title}");
      _nextStep();
      return;
    }

    final targetPosition = target.localToGlobal(Offset.zero);
    final targetSize = target.size;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate initial position
    double boxYPosition = targetPosition.dy + targetSize.height + 20;

    // Adjust position for bottom elements
    if (step.targetKey == widget.showMoreKey ||
        step.targetKey == widget.addButtonKey ||
        step.targetKey == widget.osAmountKey ||
        boxYPosition > screenHeight - 200) {
      boxYPosition = targetPosition.dy - 180; // Position above the target
    }

    _currentOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) {
                if (!_isTapInTutorialBox(details.globalPosition, targetPosition, targetSize)) {
                  _nextStep();
                }
              },
              child: Container(color: Colors.black54),
            ),
          ),
          _buildTutorialBox(step, targetPosition, targetSize, boxYPosition),
        ],
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }
  bool _isTapInTutorialBox(Offset tapPosition, Offset boxPosition, Size boxSize) {
    final tutorialBoxRect = Rect.fromLTWH(
      boxPosition.dx,
      boxPosition.dy + boxSize.height + 8,
      300, // Tutorial box width
      150, // Approximate tutorial box height
    );
    return tutorialBoxRect.contains(tapPosition);
  }

  Widget _buildTutorialBox(TutorialStep step, Offset targetPosition, Size targetSize, double boxYPosition) {
    final screenSize = MediaQuery.of(context).size;
    final boxWidth = 300.0;
    final boxHeight = 180.0;
    final arrowSize = Size(40.0, 20.0);

    // Calculate initial position
    double leftPosition = targetPosition.dx;
    if (leftPosition + boxWidth > screenSize.width) {
      leftPosition = screenSize.width - boxWidth - 16;
    }
    if (leftPosition < 16) {
      leftPosition = 16;
    }

    final arrowDirection = _calculateArrowDirection(
      targetPosition,
      targetSize,
      screenSize,
      boxWidth,
      boxHeight,
      leftPosition,
      boxYPosition,
    );

    // Adjust box position based on arrow direction
    switch (arrowDirection) {
      case ArrowDirection.top:
        boxYPosition = targetPosition.dy + targetSize.height + arrowSize.height;
        break;
      case ArrowDirection.bottom:
        boxYPosition = targetPosition.dy - boxHeight - arrowSize.height;
        break;
      case ArrowDirection.left:
        leftPosition = targetPosition.dx + targetSize.width + arrowSize.width;
        boxYPosition = targetPosition.dy - (boxHeight - targetSize.height) / 2;
        break;
      case ArrowDirection.right:
        leftPosition = targetPosition.dx - boxWidth - arrowSize.width;
        boxYPosition = targetPosition.dy - (boxHeight - targetSize.height) / 2;
        break;
    }

    return Stack(
      children: [
        // Tutorial Box
        Positioned(
          left: leftPosition,
          top: boxYPosition,
          child: Material(
            color: Colors.transparent,
            elevation: 8,
            child: Container(
              width: boxWidth,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                step.title,
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${currentStep + 1}/${tutorialSteps.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          step.content,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white24,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: currentStep > 0 ? _previousStep : null,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: currentStep > 0 ? Colors.amber : Colors.white38,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _nextStep,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: Text(
                            currentStep < tutorialSteps.length - 1 ? 'Next' : 'Done',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Directional Arrow
        _buildDirectionalArrow(
          arrowDirection,
          targetPosition,
          targetSize,
          leftPosition,
          boxYPosition,
          boxWidth,
          boxHeight,
          arrowSize,
        ),
      ],
    );
  }
  Widget _buildDirectionalArrow(
      ArrowDirection direction,
      Offset targetPosition,
      Size targetSize,
      double boxLeft,
      double boxTop,
      double boxWidth,
      double boxHeight,
      Size arrowSize,
      ) {
    double arrowLeft = 0;
    double arrowTop = 0;

    switch (direction) {
      case ArrowDirection.top:
        arrowLeft = targetPosition.dx + (targetSize.width / 2) - (arrowSize.width / 2);
        arrowTop = targetPosition.dy + targetSize.height;
        break;
      case ArrowDirection.bottom:
        arrowLeft = targetPosition.dx + (targetSize.width / 2) - (arrowSize.width / 2);
        arrowTop = targetPosition.dy - arrowSize.height;
        break;
      case ArrowDirection.left:
        arrowLeft = targetPosition.dx + targetSize.width;
        arrowTop = targetPosition.dy + (targetSize.height / 2) - (arrowSize.height / 2);
        break;
      case ArrowDirection.right:
        arrowLeft = targetPosition.dx - arrowSize.width;
        arrowTop = targetPosition.dy + (targetSize.height / 2) - (arrowSize.height / 2);
        break;
    }

    return Positioned(
      left: arrowLeft,
      top: arrowTop,
      child: CustomPaint(
        size: direction == ArrowDirection.left || direction == ArrowDirection.right
            ? Size(arrowSize.height, arrowSize.width)
            : arrowSize,
        painter: DirectionalArrowPainter(
          color: Colors.black,
          shadowColor: Colors.black26,
          direction: direction,
        ),
      ),
    );
  }

  void _nextStep() {
    setState(() {
      currentStep++;
      if (currentStep < tutorialSteps.length) {
        _showCurrentStep();
      } else {
        _completeTutorial();
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (currentStep > 0) {
        currentStep--;
        _showCurrentStep();
      }
    });
  }

  void _completeTutorial() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    setState(() {
      showTutorial = false;
    });
    widget.onComplete();
  }

  bool isElementVisible(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final position = renderObject.localToGlobal(Offset.zero);
      return position.dy >= 0 && position.dy <= MediaQuery.of(context).size.height;
    }
    return false;
  }


  @override
  void dispose() {
    _currentOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (showTutorial)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
      ],
    );
  }



  ArrowDirection _calculateArrowDirection(
      Offset targetPosition,
      Size targetSize,
      Size screenSize,
      double boxWidth,
      double boxHeight,
      double leftPosition,
      double boxYPosition,
      ) {
    final targetCenter = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );
    final boxCenter = Offset(
      leftPosition + boxWidth / 2,
      boxYPosition + boxHeight / 2,
    );

    // Calculate available space in each direction
    final spaceAbove = targetPosition.dy;
    final spaceBelow = screenSize.height - (targetPosition.dy + targetSize.height);
    final spaceLeft = targetPosition.dx;
    final spaceRight = screenSize.width - (targetPosition.dx + targetSize.width);

    // If target is near the top of the screen
    if (spaceAbove < boxHeight && spaceBelow > boxHeight) {
      return ArrowDirection.top;
    }
    // If target is near the bottom of the screen
    if (spaceBelow < boxHeight && spaceAbove > boxHeight) {
      return ArrowDirection.bottom;
    }
    // If target is near the right edge
    if (spaceRight < boxWidth && spaceLeft > boxWidth) {
      return ArrowDirection.right;
    }
    // If target is near the left edge
    if (spaceLeft < boxWidth && spaceRight > boxWidth) {
      return ArrowDirection.left;
    }

    // Default to the direction with most space
    final spaces = [spaceAbove, spaceBelow, spaceLeft, spaceRight];
    final maxSpace = spaces.reduce(max);
    if (maxSpace == spaceAbove) return ArrowDirection.bottom;
    if (maxSpace == spaceBelow) return ArrowDirection.top;
    if (maxSpace == spaceLeft) return ArrowDirection.right;
    return ArrowDirection.left;
  }
}

// Custom painter for spotlight effect
class SpotlightPainter extends CustomPainter {
  final Offset targetPosition;
  final Size targetSize;
  final double borderRadius;

  SpotlightPainter({
    required this.targetPosition,
    required this.targetSize,
    this.borderRadius = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..blendMode = BlendMode.dstOut;

    final spotlightPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
          targetPosition.dx - 4,
          targetPosition.dy - 4,
          targetSize.width + 8,
          targetSize.height + 8,
        ),
        Radius.circular(borderRadius),
      ));

    canvas.drawPath(spotlightPath, paint);
  }

  @override
  bool shouldRepaint(SpotlightPainter oldDelegate) =>
      targetPosition != oldDelegate.targetPosition ||
          targetSize != oldDelegate.targetSize ||
          borderRadius != oldDelegate.borderRadius;
}

// Extension method to safely find RenderBox
extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final translation = renderObject.localToGlobal(Offset.zero);
      return renderObject.paintBounds.shift(translation);
    }
    return null;
  }
}

class ArrowPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final bool pointingUp;

  ArrowPainter({
    required this.color,
    required this.shadowColor,
    this.pointingUp = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;

    final path = Path();
    if (pointingUp) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();

    // Draw shadow
    canvas.drawPath(path.shift(Offset(0, 2)), shadowPaint);
    // Draw arrow
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) =>
      color != oldDelegate.color ||
          shadowColor != oldDelegate.shadowColor ||
          pointingUp != oldDelegate.pointingUp;
}

enum ArrowDirection {
  top,
  bottom,
  left,
  right
}

class DirectionalArrowPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final ArrowDirection direction;

  DirectionalArrowPainter({
    required this.color,
    required this.shadowColor,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;

    final path = Path();

    switch (direction) {
      case ArrowDirection.top:
        path.moveTo(0, size.height);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        break;
      case ArrowDirection.bottom:
        path.moveTo(0, 0);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(size.width, 0);
        break;
      case ArrowDirection.left:
        path.moveTo(0, size.height / 2);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case ArrowDirection.right:
        path.moveTo(0, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        break;
    }
    path.close();

    // Draw shadow
    canvas.drawPath(path.shift(Offset(1, 1)), shadowPaint);
    // Draw arrow
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DirectionalArrowPainter oldDelegate) =>
      color != oldDelegate.color ||
          shadowColor != oldDelegate.shadowColor ||
          direction != oldDelegate.direction;
}