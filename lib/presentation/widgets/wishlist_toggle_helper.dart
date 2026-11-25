import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/snackbar_utils.dart';
import '../../domain/models/product.dart';
import '../state/wishlist_state.dart';

Future<void> toggleWishlistWithFeedback(
  BuildContext context,
  Product product,
) async {
  final wishlist = context.read<WishlistState>();
  final added = await wishlist.toggleWishlist(product);
  if (!context.mounted) return;

  if (added == true) {
    SnackbarUtils.show(context, 'Added to wish list.');
  } else if (added == false) {
    SnackbarUtils.show(context, 'Removed from wish list.');
  } else {
    SnackbarUtils.show(
      context,
      wishlist.errorMessage ?? 'Could not update wish list.',
      isError: true,
    );
  }
}
