import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tldr_news/core/theme/app_colors.dart';
import 'package:tldr_news/core/theme/app_text_styles.dart';
import 'package:tldr_news/core/utils/extensions.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';

class ArticleContent extends StatelessWidget {
  const ArticleContent({required this.article, super.key});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor =
        AppColors.categoryColors[article.category] ?? AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                article.category.capitalized,
                style: AppTextStyles.labelMedium.copyWith(
                  color: categoryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Icon(
              Icons.access_time,
              size: 16.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            SizedBox(width: 4.w),
            Text(
              article.publishedAt.formatted,
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Hero(
          tag: 'article-title-${article.id}',
          flightShuttleBuilder: (_, animation, direction, fromContext, toContext) {
            final toWidget = toContext.widget as Hero;
            return DefaultTextStyle(
              style: AppTextStyles.headlineMedium.copyWith(
                color: colorScheme.onSurface,
              ),
              child: Material(
                color: Colors.transparent,
                child: toWidget.child,
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Text(
              article.title,
              style: AppTextStyles.headlineMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.summarize,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Summary',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                article.description,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.9),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Icon(
              Icons.link,
              size: 16.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                _getDomain(article.link),
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }
}
