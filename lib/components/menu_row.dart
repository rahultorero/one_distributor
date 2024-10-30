import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Add this package for SVG support
import 'package:rive/rive.dart';
import '../models/menu_dart.dart';

class MenuRow extends StatelessWidget {
  const MenuRow(
      {Key? key, required this.menu, this.selectedMenu = "Home", this.onMenuPress,required this.isSelected})
      : super(key: key);

  final MenuItemModel menu;
  final String selectedMenu;
  final Function? onMenuPress;
  final bool isSelected;

  void _onMenuIconInit(Artboard artboard) {
    if (menu.riveIcon != null) {
      final controller = StateMachineController.fromArtboard(
          artboard, menu.riveIcon!.stateMachine);
      artboard.addController(controller!);
      menu.riveIcon!.status = controller.findInput<bool>("active") as SMIBool;
    }
  }

  void onMenuPressed() {
    if (selectedMenu != menu.title) {
      onMenuPress!();
      if (menu.riveIcon != null) {
        menu.riveIcon!.status!.change(true);
        Future.delayed(const Duration(seconds: 1), () {
          menu.riveIcon!.status!.change(false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The menu button background that animates as we click on it
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: selectedMenu == menu.title ? 288 - 16 : 0,
          height: 56,
          curve: const Cubic(0.2, 0.8, 0.2, 1),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        CupertinoButton(
          padding: const EdgeInsets.all(12),
          pressedOpacity: 1, // disable touch effect
          onPressed: onMenuPressed,
          child: Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: _buildIcon(),
              ),
              const SizedBox(width: 14),
              Text(
                menu.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w600,
                    fontSize: 17),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    switch (menu.iconType) {
      case IconType.rive:
        return RiveAnimation.asset(
          menu.riveIcon!.artboard!,
          stateMachines: [menu.riveIcon!.stateMachine],
          artboard: menu.riveIcon!.artboard,
          onInit: _onMenuIconInit,
        );
      case IconType.flutterIcon:
        return Icon(menu.flutterIcon, color: Colors.white.withOpacity(0.6));
      case IconType.asset:
        if (menu.assetPath != null) {
          return SvgPicture.asset(menu.assetPath!); // Use SVG for assetPath
        } else {
          return const SizedBox.shrink();
        }
      default:
        return const SizedBox.shrink();
    }
  }
}
