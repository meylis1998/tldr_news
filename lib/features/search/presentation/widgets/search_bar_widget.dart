import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tldr_news/core/theme/app_text_styles.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search articles...',
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }
}
