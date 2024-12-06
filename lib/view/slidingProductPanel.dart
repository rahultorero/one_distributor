import 'dart:convert';

import 'package:flutter/material.dart';
import '../components/RipplePageRoute.dart';
import '../dataModels/ProductListModel.dart';
import 'newSalesOrder.dart';

class SlidingProductPanel extends StatefulWidget {
  final List<ProductListItem> productListItem;
  final Widget child;
  final String ledidParty;
  final String smId;
  final Function(List<ProductListItem>)? onProductListUpdated; // Add callback

  const SlidingProductPanel({
    Key? key,
    required this.productListItem,
    required this.child,
    required this.ledidParty,
    required this.smId,
    this.onProductListUpdated,
  }) : super(key: key);

  @override
  _SlidingProductPanelState createState() => _SlidingProductPanelState();
}

class _SlidingProductPanelState extends State<SlidingProductPanel>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _badgeController;
  late AnimationController _buttonController;
  late Animation<double> _badgeScaleAnimation;
  late Animation<Offset> _badgeSlideAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonRotateAnimation;
  late Animation<double> _panelScaleAnimation;
  bool _isOpen = false;

  int _previousItemCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Enhanced badge scale animation
    _badgeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60.0,
      ),
    ]).animate(_badgeController);

    // Enhanced slide animation
    _badgeSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _badgeController,
      curve: Curves.elasticOut,
    ));

    // Button animations
    _buttonScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50.0,
      ),
    ]).animate(_buttonController);

    _buttonRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOutCubicEmphasized,
    ));

    // New panel scale animation
    _panelScaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _badgeController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SlidingProductPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("check the updateee ${json.encode(widget.productListItem)}");
    if (widget.productListItem.length != _previousItemCount) {
      _badgeController.forward(from: 0.0);
      _previousItemCount = widget.productListItem.length ?? 0;
      print("lenghthhhhhh${widget.productListItem.length}");
    }
  }

  void _togglePanel(BuildContext context) {
    // Find the RenderBox of the button
    final RenderBox buttonBox = context.findRenderObject() as RenderBox;

    // Calculate the button's global position
    final buttonPosition = buttonBox.localToGlobal(Offset.zero);

    // Calculate the position of the icon (assuming it is centered in the button)
    final buttonCenter = Offset(
      buttonPosition.dx + buttonBox.size.width - 30, // Adjust this value based on your icon's position
      buttonPosition.dy + buttonBox.size.height - 30, // Adjust this value based on your icon's position
    );

    Navigator.of(context).push(
      RipplePageRoute(
        builder: (context) => _buildPanelContent(context),
        center: buttonCenter,  // Use the new buttonCenter for ripple effect
      ),
    );
  }

  void updateProductList(List<ProductListItem> updatedList) {
    setState(() {
      widget.productListItem.clear();
      widget.productListItem.addAll(updatedList);
      widget.onProductListUpdated?.call(updatedList);
      _badgeController.forward(from: 0.0); // Animate the badge
    });
  }


  Widget _buildPanelContent(BuildContext context) {

    double panelHeight = MediaQuery.of(context).size.height * 0.91;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            width: size.width * 0.99,
            height: panelHeight,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shopping_cart, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                'Order Items',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ProductListWidget(
                        productListItem: widget.productListItem,
                        smId: widget.smId,
                        ledidParty: widget.ledidParty,
                        onProductListUpdated: updateProductList,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery.of(context).size.height * 0.9;
    final size = MediaQuery.of(context).size;
    print("watchhh lenght ${widget.productListItem.length}");
    return Stack(
      children: [
        widget.child,

        // Fixed Cart Button
        Positioned(
          right: 10,
          bottom: 10,
          child: RotationTransition(
            turns: _buttonRotateAnimation,
            child: ScaleTransition(
              scale: _buttonScaleAnimation,
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child:Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () => _togglePanel(context), // Use a closure to call _togglePanel
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                _isOpen ? Icons.close : Icons.shopping_cart,
                                color: Colors.white,
                                size: 25,
                              ),
                              if (widget.productListItem.isNotEmpty)
                                Positioned(
                                  right: -10,
                                  top: -10,
                                  child: SlideTransition(
                                    position: _badgeSlideAnimation,
                                    child: ScaleTransition(
                                      scale: _badgeScaleAnimation,
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          '${widget.productListItem.length}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              ),
            ),
          ),
        ),

        // Animated Panel
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final slideOffset = (1 - _panelScaleAnimation.value) * size.width;
            final scaleValue = 0.3 + (0.7 * _panelScaleAnimation.value);
            final originOffset = Offset(size.width - 60, size.height - 60);

            return Positioned(
              bottom: 0,
              right: 0,
              width: size.width * 0.99,
              height: panelHeight,
              child: Transform.translate(
                offset: Offset(slideOffset, 0),
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(originOffset.dx, originOffset.dy)
                    ..scale(scaleValue)
                    ..translate(-originOffset.dx, -originOffset.dy),
                  child: Material(
                    elevation: 8 * _panelScaleAnimation.value,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade700,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.shopping_cart, color: Colors.white),
                                    SizedBox(width: 12),
                                    Text(
                                      'Order Items',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.white),
                                  onPressed: () => _togglePanel(context), // Wrap in a closure
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),

                              ],
                            ),
                          ),
                          Expanded(
                            child: ProductListWidget(
                              productListItem: widget.productListItem,
                              ledidParty: widget.ledidParty,
                              smId: widget.smId,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}