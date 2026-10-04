
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/asset_category.dart';

class AssetCategoryTabs extends StatelessWidget {
  const AssetCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<AssetCategory> categories;
  final String selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final availableCategories = [
      const AssetCategory(name: 'all'),
      ...categories,
    ];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: availableCategories.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = availableCategories[index];

          final isAll = category.name.toLowerCase() == 'all';

          final isSelected = isAll
              ? selectedCategory.toLowerCase() == 'all'
              : selectedCategory.toLowerCase() ==
                  category.name.toLowerCase();

          return _CategoryChip(
            label: isAll ? 'All Assets' : category.displayName,
            selected: isSelected,
            onTap: () {
              onCategorySelected(
                isAll ? null : category.name,
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary
          : Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}