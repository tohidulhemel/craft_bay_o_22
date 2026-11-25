import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/nav_state.dart';
import '../cart/cart_screen.dart';
import '../categories/categories_screen.dart';
import '../home/home_screen.dart';
import '../wishlist/wishlist_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const List<Widget> _tabs = [
    HomeScreen(),
    CategoriesScreen(),
    CartScreen(),
    WishlistScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavState>();

    // Back button: from any other tab go to Home first, then exit the app.
    return PopScope(
      canPop: nav.index == NavState.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) nav.goHome();
      },
      child: Scaffold(
        // IndexedStack keeps each tab alive, so scroll position and loaded
        // data are not lost when switching tabs.
        body: IndexedStack(index: nav.index, children: _tabs),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: nav.index,
          onTap: nav.goTo,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket_outlined),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard_outlined),
              label: 'Wish',
            ),
          ],
        ),
      ),
    );
  }
}
