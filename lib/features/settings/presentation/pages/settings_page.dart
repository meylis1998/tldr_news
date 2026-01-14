import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tldr_news/core/constants/api_constants.dart';
import 'package:tldr_news/core/constants/app_constants.dart';
import 'package:tldr_news/core/theme/app_colors.dart';
import 'package:tldr_news/core/theme/app_text_styles.dart';
import 'package:tldr_news/core/utils/extensions.dart';
import 'package:tldr_news/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _SectionHeader(title: 'Appearance'),
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: _getThemeModeText(state.themeMode),
                onTap: () => _showThemeDialog(context, state.themeMode),
              ),
              SizedBox(height: 24.h),
              _SectionHeader(title: 'Notifications'),
              _SwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive daily news updates',
                value: state.notificationsEnabled,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(NotificationsToggled(value));
                },
              ),
              SizedBox(height: 24.h),
              _SectionHeader(title: 'Preferences'),
              _SettingsTile(
                icon: Icons.category_outlined,
                title: 'Default Category',
                subtitle: ApiConstants.getCategory(state.defaultCategory)?.name ?? state.defaultCategory,
                onTap: () => _showCategoryDialog(context, state.defaultCategory),
              ),
              SizedBox(height: 24.h),
              _SectionHeader(title: 'About'),
              _SettingsTile(
                icon: Icons.info_outlined,
                title: 'Version',
                subtitle: AppConstants.appVersion,
              ),
              _SettingsTile(
                icon: Icons.public_outlined,
                title: 'Visit TLDR',
                subtitle: 'tldr.tech',
                onTap: () => _launchUrl('https://tldr.tech'),
              ),
              _SettingsTile(
                icon: Icons.code_outlined,
                title: 'Source Code',
                subtitle: 'View on GitHub',
                onTap: () => _launchUrl('https://github.com/meylis1998/tldr_news'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  void _showThemeDialog(BuildContext context, ThemeMode currentMode) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeModeText(mode)),
              value: mode,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(ThemeModeChanged(value));
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, String currentCategory) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Default Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ApiConstants.newsletters.map((newsletter) {
              return RadioListTile<String>(
                title: Text('${newsletter.emoji} ${newsletter.name}'),
                value: newsletter.slug,
                groupValue: currentCategory,
                onChanged: (value) {
                  if (value != null) {
                    context
                        .read<SettingsBloc>()
                        .add(DefaultCategoryChanged(value));
                    Navigator.pop(ctx);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurface.withValues(alpha: 0.7)),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            )
          : null,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SwitchListTile(
      secondary: Icon(icon, color: colorScheme.onSurface.withValues(alpha: 0.7)),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
    );
  }
}
