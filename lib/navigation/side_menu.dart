import 'package:distributers_app/view/MappedProductScreen.dart';
import 'package:distributers_app/view/MappedRetailerScreen.dart';
import 'package:distributers_app/view/UnmappedRetailerScreen.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assets.dart' as app_assets;
import '../components/menu_row.dart';
import '../models/menu_dart.dart';
import '../theme.dart';
import 'dart:math' as math;
import '../view/ProductMappingScreen.dart';
import '../view/SalesOrders.dart';
import '../view/UserList.dart';
import '../view/draftOrders.dart';
import '../view/home.dart';
import '../view/mainScreen.dart';
import '../view/outStandingList.dart';
import '../view/profileScreen.dart';
import '../view/salesInvoice.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final List<MenuItemModel> _browseMenuIcons = MenuItemModel.menuItems;
  final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;

  String? _selectedMenu;
  String? _currentRoute;
  bool _isDarkMode = false;
  String? name;
  String? division;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        name = prefs.getString("user") ?? '';
        division = prefs.getString("division") ?? '';
      });
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  Future<void> _handleLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("user");
      await prefs.remove("division");
      await prefs.remove("isLoggedIn");
      await prefs.remove("reg_code");
      await prefs.remove("u_id");
      await prefs.remove("companyId");
      await prefs.remove("smid");
      await prefs.setBool("isLoggedIn", false);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MainScreens()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  void onMenuPress(MenuItemModel menu) {
    if (menu.route != null) {
      if (menu.route == '/logout') {
        _showLogoutDialog();
        return;
      }

      // If the menu item is already selected and the route is the same,
      // don't navigate again but reset the selection
      if (_selectedMenu == menu.title && _currentRoute == menu.route) {
        setState(() {
          _selectedMenu = null;
          _currentRoute = null;
        });
        return;
      }

      // Update selection and route
      setState(() {
        _selectedMenu = menu.title;
        _currentRoute = menu.route;
      });

      // Navigate to the new route
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => _getPageForRoute(menu.route!),
        ),
      ).then((_) {
        // When returning, reset both selection and route
        if (mounted) {
          setState(() {
            _selectedMenu = null;
            _currentRoute = null;
          });
        }
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedMenu = null;
                  _currentRoute = null;
                });
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _getPageForRoute(String route) {
    switch (route) {
      case '/home':
        return Home();
      case '/user':
        return UsersListScreen();
      case '/sales_invoice':
        return SalesInvoiceScreen();
      case '/sales_order':
        return SalesOrderList();
      case '/draft_order':
        return DraftOrderList();
      case '/product_map':
        return ProductMappingScreen();
      case '/map_product':
        return MappedProductScreen();
      case '/retailers_mapping':
        return MappedRetailerScreen();
      case '/unmapped_retailer':
        return UnmappedRetailerScreen();
      case '/out_standing':
        return OutStandingList();
      default:
        return Container();
    }
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
                    selectedMenu: _selectedMenu ?? "",
                    currentRoute: _currentRoute,
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
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          ).then((_) {
            // Reset selection when returning from profile
            if (mounted) {
              setState(() {
                _selectedMenu = null;
                _currentRoute = null;
              });
            }
          });
        },
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              child: const Icon(Icons.person_outline),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: "Inter",
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    division ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: "Inter",
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return InkWell(
      onTap: () {
        if (_themeMenuIcon.isNotEmpty) {
          final logoutMenu = _themeMenuIcon[0];
          if (logoutMenu.route == '/logout') {
            _showLogoutDialog();
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Opacity(
                opacity: 0.6,
                child: _themeMenuIcon.isNotEmpty && _themeMenuIcon[0].riveIcon != null
                    ? RiveAnimation.asset(
                  app_assets.iconsRiv,
                  stateMachines: [_themeMenuIcon[0].riveIcon!.stateMachine],
                  artboard: _themeMenuIcon[0].riveIcon!.artboard,
                  onInit: onThemeRiveIconInit,
                )
                    : Icon(
                  _themeMenuIcon.isNotEmpty
                      ? _themeMenuIcon[0].flutterIcon ?? Icons.logout
                      : Icons.logout,
                  color: Colors.white,
                ),
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
      ),
    );
  }
}

class MenuButtonSection extends StatefulWidget {
  const MenuButtonSection({
    Key? key,
    required this.title,
    required this.menuIcons,
    required this.selectedMenu,
    this.currentRoute,
    this.onMenuPress,
  }) : super(key: key);

  final String title;
  final String selectedMenu;
  final String? currentRoute;
  final List<MenuItemModel> menuIcons;
  final Function(MenuItemModel menu)? onMenuPress;

  @override
  State<MenuButtonSection> createState() => _MenuButtonSectionState();
}

class _MenuButtonSectionState extends State<MenuButtonSection> {
  String? expandedMenu;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        _buildMenuItems(),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
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
    );
  }

  Widget _buildMenuItems() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: widget.menuIcons.map((menu) {
          final bool isSelected = widget.selectedMenu == menu.title;

          return Column(
            children: [
              Divider(
                color: Colors.white.withOpacity(0.1),
                thickness: 1,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: MenuRow(
                  menu: menu,
                  selectedMenu: widget.selectedMenu,
                  onMenuPress: () => _handleMenuPress(menu),
                  isSelected: isSelected,
                ),
              ),
              if (expandedMenu == menu.title) ..._buildChildMenuItems(menu),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildChildMenuItems(MenuItemModel parentMenu) {
    return parentMenu.children.map((childMenu) {
      final bool isChildSelected = widget.selectedMenu == childMenu.title;

      return Padding(
        padding: const EdgeInsets.only(left: 40),
        child: Container(
          decoration: BoxDecoration(
            color: isChildSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: MenuRow(
            menu: childMenu,
            selectedMenu: widget.selectedMenu,
            onMenuPress: () => widget.onMenuPress?.call(childMenu),
            isSelected: isChildSelected,
          ),
        ),
      );
    }).toList();
  }

  void _handleMenuPress(MenuItemModel menu) {
    if (menu.children.isNotEmpty) {
      setState(() {
        expandedMenu = expandedMenu == menu.title ? null : menu.title;
      });
    } else {
      widget.onMenuPress?.call(menu);
    }
  }
}