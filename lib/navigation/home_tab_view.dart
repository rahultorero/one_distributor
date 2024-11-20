import 'package:distributers_app/view/DashBoard.dart';
import 'package:flutter/material.dart';

import '../components/hcard.dart';
import '../components/vcard.dart';
import '../models/courses.dart';
import '../theme.dart';


class HomeTabView extends StatefulWidget {
  const HomeTabView({Key? key}) : super(key: key);

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final List<CourseModel> _courses = CourseModel.courses;
  final List<CourseModel> _courseSections = CourseModel.courseSections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: RiveAppTheme.background,
          borderRadius: BorderRadius.circular(30),
        ),
        child:DashBoardContent(),
      ),
    );
  }
}
