import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tldr_news/core/theme/app_colors.dart';
import 'package:tldr_news/core/theme/app_text_styles.dart';
import 'package:tldr_news/core/utils/extensions.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    required this.article,
    required this.onTap,
    this.onBookmarkTap,
    super.key,
  });

  final Article article;
  final VoidCallback onTap;
  final VoidCallback? onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor =
        AppColors.categoryColors[article.category] ?? AppColors.primary;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      article.category.capitalized,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    article.publishedAt.timeAgo,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const Spacer(),
                  if (onBookmarkTap != null)
                    GestureDetector(
                      onTap: onBookmarkTap,
                      child: Icon(
                        article.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: article.isBookmarked
                            ? AppColors.primary
                            : colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 22.sp,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                article.title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: article.isRead
                      ? colorScheme.onSurface.withValues(alpha: 0.6)
                      : colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Text(
                article.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    Icons.open_in_new,
                    size: 14.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      _getDomain(article.link),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
