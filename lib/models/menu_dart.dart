import 'package:flutter/material.dart';
import 'package:distributers_app/models/tab_item.dart';

enum IconType { rive, flutterIcon, asset }

class MenuItemModel {
  MenuItemModel({
    this.id,
    this.title = "",
    this.riveIcon,
    this.flutterIcon,
    this.assetPath,
    required this.iconType,
    this.fontSize = 14,
    this.route,
    this.children = const [], // Add children property
  });

  UniqueKey? id = UniqueKey();
  String title;
  TabItem? riveIcon;
  IconData? flutterIcon;
  String? assetPath;
  IconType iconType;
  double fontSize;
  String? route;
  List<MenuItemModel> children; // New property for child items

  static List<MenuItemModel> menuItems = [
    MenuItemModel(
      title: "Home",
      assetPath: 'assets/images/home_icon.svg',
      iconType: IconType.asset,
      fontSize: 15,
      route: '/home', // Add route
    ),
    MenuItemModel(
      title: "Order",
      assetPath: 'assets/images/order_icon.svg',
      iconType: IconType.asset,
      route: '/order',
      children: [ // Add child items for Order
        MenuItemModel(
          title: "Sales Order",
          assetPath: 'assets/images/order_icon.svg',
          iconType: IconType.asset,
          route: '/sales_order',
        ),
        MenuItemModel(
          title: "Draft Order",
          assetPath: 'assets/images/order_icon.svg',
          iconType: IconType.asset,
          route: '/draft_order',
        ),
      ],
    ),
    MenuItemModel(
      title: "Sales Invoice",
      assetPath: 'assets/images/invoice_icon.svg',
      iconType: IconType.asset,
      route: '/sales_invoice', // Add route
    ),
    MenuItemModel(
      title: "Retailers Mapping",
      assetPath: 'assets/images/retailers_icon.svg',
      iconType: IconType.asset,
      route: '/retailers_mapping', // Add route
    ),
    MenuItemModel(
      title: "Product Mapping",
      assetPath: 'assets/images/product_icon.svg',
      iconType: IconType.asset,
      route: '/product_mapping', // Add route
    ),
    MenuItemModel(
      title: "Upload Data",
      assetPath: 'assets/images/upload_icon.svg',
      iconType: IconType.asset,
      route: '/upload_data', // Add route
    ),
    MenuItemModel(
      title: "User",
      assetPath: 'assets/images/user_icon.svg',
      iconType: IconType.asset,
      route: '/user', // Add route
    ),
    MenuItemModel(
      title: "OutStanding",
      assetPath: 'assets/images/cloud_icon.svg',
      iconType: IconType.asset,
      route: '/out_standing', // Add route
    ),
    MenuItemModel(
      title: "Settings",
      assetPath: 'assets/images/setting_icon.svg',
      iconType: IconType.asset,
      route: '/settings', // Add route
    ),
  ];

  static List<MenuItemModel> menuItems3 = [
    MenuItemModel(
      title: "Logout",
      flutterIcon: Icons.logout,
      iconType: IconType.flutterIcon,
      route: '/logout', // Optional route for logout
    ),
  ];
}
