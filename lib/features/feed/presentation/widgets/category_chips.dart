import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tldr_news/core/constants/api_constants.dart';
import 'package:tldr_news/core/theme/app_colors.dart';
import 'package:tldr_news/core/theme/app_text_styles.dart';

class CategoryChips extends StatefulWidget {
  const CategoryChips({
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _chipKeys = List.generate(
    ApiConstants.newsletters.length,
    (_) => GlobalKey(),
  );

  @override
  void didUpdateWidget(CategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _scrollToSelectedChip();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedChip() {
    final index = ApiConstants.newsletters
        .indexWhere((n) => n.slug == widget.selectedCategory);
    if (index < 0) return;

    final key = _chipKeys[index];
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final scrollPosition = _scrollController.position;
    final chipPosition = renderBox.localToGlobal(Offset.zero).dx;
    final chipWidth = renderBox.size.width;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate target scroll position to center the chip
    final currentScroll = scrollPosition.pixels;
    final targetScroll = currentScroll + chipPosition - (screenWidth / 2) + (chipWidth / 2);

    // Clamp to valid scroll range
    final clampedScroll = targetScroll.clamp(
      scrollPosition.minScrollExtent,
      scrollPosition.maxScrollExtent,
    );

    _scrollController.animateTo(
      clampedScroll,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: ApiConstants.newsletters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final newsletter = ApiConstants.newsletters[index];
          final isSelected = newsletter.slug == widget.selectedCategory;
          final color = _getCategoryColor(index);

          return FilterChip(
            key: _chipKeys[index],
            selected: isSelected,
            label: Text('${newsletter.emoji} ${newsletter.name}'),
            labelStyle: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? Colors.white : color,
            ),
            backgroundColor: color.withValues(alpha: 0.1),
            selectedColor: color,
            checkmarkColor: Colors.white,
            showCheckmark: false,
            side: BorderSide(
              color: isSelected ? color : color.withValues(alpha: 0.3),
            ),
            onSelected: (_) => widget.onCategorySelected(newsletter.slug),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppColors.primary,        // tech
      const Color(0xFF8B5CF6),  // ai
      const Color(0xFF3B82F6),  // webdev
      const Color(0xFFEF4444),  // infosec
      const Color(0xFF06B6D4),  // devops
      const Color(0xFF10B981),  // founders
      const Color(0xFFF59E0B),  // product
      const Color(0xFFEC4899),  // design
      const Color(0xFFFF6B6B),  // marketing
      const Color(0xFFF7931A),  // crypto
      const Color(0xFF00D4AA),  // fintech
      const Color(0xFF14B8A6),  // data
    ];
    return colors[index % colors.length];
  }
}
