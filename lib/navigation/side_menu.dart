import 'package:distributers_app/navigation/home_tab_view.dart';
import 'package:distributers_app/view/SalesOrders.dart';
import 'package:distributers_app/view/UserList.dart';
import 'package:distributers_app/view/draftOrders.dart';
import 'package:distributers_app/view/mainScreen.dart';
import 'package:distributers_app/view/outStandingList.dart';
import 'package:distributers_app/view/profileScreen.dart';
import 'package:distributers_app/view/salesInvoice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assets.dart' as app_assets;
import '../components/menu_row.dart';
import '../models/menu_dart.dart'; // Ensure the correct import path
import '../theme.dart';
import 'dart:math' as math;

import '../view/home.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final List<MenuItemModel> _browseMenuIcons = MenuItemModel.menuItems;
  final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
  String _selectedMenu = MenuItemModel.menuItems[0].title;
  bool _isDarkMode = false;
  String? name = '';
  String? division;

  @override
  void initState() {
    getProfile();
    super.initState();
  }
  Future<void> getProfile() async {
    name = await _getName();
    division = await _getDivision();
  }


  Future<String?> _getName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("user"); // Replace with your key
  }

  Future<String?> _getDivision() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("division"); // Replace with your key
  }


  void onThemeRiveIconInit(Artboard artboard) {
    if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon != null) {
      final controller = StateMachineController.fromArtboard(
          artboard, _themeMenuIcon[0].riveIcon!.stateMachine);
      if (controller != null) {
        artboard.addController(controller);
        _themeMenuIcon[0].riveIcon!.status = controller.findInput<bool>("active") as SMIBool;
      }
    }
  }

  void onThemeToggle(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    if (_themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon != null) {
      _themeMenuIcon[0].riveIcon!.status?.change(value); // Ensure riveIcon status is non-null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: math.max(0, MediaQuery.of(context).padding.bottom - 60),
      ),
      constraints: const BoxConstraints(maxWidth: 288),
      decoration: BoxDecoration(
        color: RiveAppTheme.background2,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MenuButtonSection(
                    title: "BROWSE",
                    selectedMenu: _selectedMenu,
                    menuIcons: _browseMenuIcons,
                    onMenuPress: onMenuPress,
                  ),
                ],
              ),
            ),
          ),
          _buildThemeToggle(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          // Navigate to ProfileScreen
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              child: const Icon(Icons.person_outline),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                Text(
                  name! ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: "Inter",
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  division ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: "Inter",
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Limits the text to one line
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Opacity(
              opacity: 0.6,
              child: _buildRiveAnimation(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _themeMenuIcon.isNotEmpty ? _themeMenuIcon[0].title : '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onMenuPress(MenuItemModel menu) {
    setState(() {
      _selectedMenu = menu.title;
    });

    // Handle navigation based on the menu item's route
    if (menu.route != null) {
      if (menu.route == '/logout') {
        // Handle the logout process
        _handleLogout();
      } else {
        // Navigate to the selected route
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return _getPageForRoute(menu.route!);
            },
          ),
        );
      }
    }
  }

  Widget _getPageForRoute(String route) {
    switch (route) {
      case '/home':
        return Home(); // Replace with your Home screen widget
      case '/user':
        return UsersListScreen();
      case '/sales_invoice':
        return SalesInvoiceScreen(); // Your Sales Invoice screen widget
      case '/sales_order':
        return SalesOrderList(); // You may want to change this to the actual order screen
      case '/draft_order':
        return DraftOrderList();
      case '/out_standing':
        return OutStandingList();
      default:
        return Container(); // Fallback widget
    }
  }

  // Logout handling method
  void _handleLogout() {
    // Perform logout logic here, like clearing user session data
    print("Logging out...");

    // Navigate to the MainScreens (Login or Welcome screen)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainScreens()),
    );
  }

  Widget _buildRiveAnimation() {
    if (_themeMenuIcon.isEmpty || _themeMenuIcon[0].riveIcon == null) {
      return const SizedBox.shrink(); // Return an empty widget if there's no valid Rive icon
    }

    return RiveAnimation.asset(
      app_assets.iconsRiv, // Ensure this is a valid path
      stateMachines: [_themeMenuIcon[0].riveIcon!.stateMachine],
      artboard: _themeMenuIcon[0].riveIcon!.artboard,
      onInit: onThemeRiveIconInit,
    );
  }
}

class MenuButtonSection extends StatefulWidget {
  const MenuButtonSection({
    Key? key,
    required this.title,
    required this.menuIcons,
    this.selectedMenu = "Home",
    this.onMenuPress,
  }) : super(key: key);

  final String title;
  final String selectedMenu;
  final List<MenuItemModel> menuIcons;
  final Function(MenuItemModel menu)? onMenuPress;

  @override
  _MenuButtonSectionState createState() => _MenuButtonSectionState();
}

class _MenuButtonSectionState extends State<MenuButtonSection> {
  String? expandedMenu; // To keep track of which menu is expanded

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 8),
          child: Text(
            widget.title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: widget.menuIcons.map((menu) {
              return Column(
                children: [
                  Divider(
                    color: Colors.white.withOpacity(0.1),
                    thickness: 1,
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  MenuRow(
                    menu: menu,
                    selectedMenu: widget.selectedMenu,
                    onMenuPress: () {
                      // Check if the menu item has children
                      if (menu.children.isNotEmpty) {
                        setState(() {
                          expandedMenu = expandedMenu == menu.title ? null : menu.title; // Toggle expansion
                        });
                      } else {
                        widget.onMenuPress!(menu);
                      }
                    },
                  ),
                  // Render child items if the menu is expanded
                  if (expandedMenu == menu.title)
                    ...menu.children.map((childMenu) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 40), // Indent child items
                        child: MenuRow(
                          menu: childMenu,
                          selectedMenu: widget.selectedMenu,
                          onMenuPress: () => widget.onMenuPress!(childMenu),
                        ),
                      );
                    }).toList(),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

