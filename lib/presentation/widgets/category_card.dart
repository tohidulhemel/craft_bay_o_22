import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../domain/models/category.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.boxSize = 68,
  });

  final Category category;
  final VoidCallback onTap;
  final double boxSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: boxSize,
            height: boxSize,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: category.icon.isEmpty
                ? const Icon(
                    Icons.category_outlined,
                    color: AppColors.primary,
                    size: 28,
                  )
                : CachedNetworkImage(
                    imageUrl: category.icon,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, _, _) => const Icon(
                      Icons.category_outlined,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: boxSize + 6,
            child: Text(
              category.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
