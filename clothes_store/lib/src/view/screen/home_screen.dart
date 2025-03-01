import 'package:clothes_store/src/view/screen/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:clothes_store/core/app_data.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:clothes_store/src/view/screen/cart_screen.dart';
import 'package:clothes_store/src/view/screen/profile_screen.dart';
import 'package:clothes_store/src/view/screen/favorite_screen.dart';
import 'package:clothes_store/src/view/screen/product_list_screen.dart';
import 'package:clothes_store/src/view/animation/page_transition_switcher_wrapper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const List<Widget> screens = [
    ProductListScreen(),
    FavoriteScreen(),
    CartScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int newIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Scaffold(
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.6),
                  spreadRadius: 8,
                  blurRadius: 8,
                  offset: Offset(0, 3), // Điều chỉnh vị trí shadow
                ),
              ],
            ),
            child: StylishBottomBar(
              currentIndex: newIndex,
              onTap: (index) {
                newIndex = index;
                setState(() {});
              },
              items: AppData.bottomNavBarItems
                  .map(
                    (item) => BottomBarItem(
                      backgroundColor: item.activeColor,
                      icon: item.icon,
                      title: Text(
                        item.title,
                        style: TextStyle(
                          color: item.activeColor,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              option: BubbleBarOptions(
                opacity: 0.3,
                unselectedIconColor: Colors.grey,
                borderRadius: BorderRadius.circular(
                  15.0,
                ),
              ),
            ),
          ),
          body: PageTransitionSwitcherWrapper(
            child: HomeScreen.screens[newIndex],
          ),
        ),
      ),
    );
  }
}
