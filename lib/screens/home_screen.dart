import 'package:flutter/material.dart';
import 'package:raktosewa/widgets/upcoming_camp.dart';
import '../widgets/top_profile.dart';
import '../widgets/search_box.dart';
import '../widgets/banner_card.dart';
import '../widgets/activity_section.dart';
import '../widgets/blood_group_section.dart';
import '../widgets/emergency_card.dart';
import '../widgets/contribution_section.dart';
import 'package:raktosewa/widgets/custom_navbar.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      bottomNavigationBar: CustomNavBar(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopProfile(),
              SizedBox(height: 20),
              SearchBox(),
              SizedBox(height: 20),
              BannerCard(),
              SizedBox(height: 25),
              ActivitySection(),
              SizedBox(height: 25),
              BloodGroupSection(),
              SizedBox(height: 25),
              EmergencyCard(),
              SizedBox(height: 25),
              ContributionSection(),
              SizedBox(height: 25),
              UpcomingCamps(),
            ],
          ),
        ),
      ),
    );
  }
}
