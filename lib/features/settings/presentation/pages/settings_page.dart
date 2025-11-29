import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/helper/cache_helper.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc(getIt<CacheHelper>())..add(LoadSettings()),
      child: const _SettingsPageContent(),
    );
  }
}

class _SettingsPageContent extends StatelessWidget {
  const _SettingsPageContent();

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
              // Theme Section
              _buildSectionHeader('Appearance'),
              _buildThemeSelector(context, state),
              SizedBox(height: 24.h),

              // Language Section
              _buildSectionHeader('Language'),
              _buildLanguageSelector(context, state),
              SizedBox(height: 24.h),

              // Speed Section
              _buildSectionHeader('Animation'),
              _buildSpeedSelector(context, state),
              SizedBox(height: 24.h),

              // About Section
              _buildSectionHeader('About'),
              _buildAboutSection(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsState state) {
    return Card(
      child: Column(
        children: [
          _buildThemeOption(
            context: context,
            title: 'System',
            subtitle: 'Follow system settings',
            icon: Icons.settings_brightness,
            value: 'system',
            groupValue: state.themeMode,
          ),
          const Divider(height: 1),
          _buildThemeOption(
            context: context,
            title: 'Light',
            subtitle: 'Always use light theme',
            icon: Icons.light_mode,
            value: 'light',
            groupValue: state.themeMode,
          ),
          const Divider(height: 1),
          _buildThemeOption(
            context: context,
            title: 'Dark',
            subtitle: 'Always use dark theme',
            icon: Icons.dark_mode,
            value: 'dark',
            groupValue: state.themeMode,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String groupValue,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Radio<String>(
        value: value,
        groupValue: groupValue,
        onChanged: (value) {
          if (value != null) {
            context.read<SettingsBloc>().add(ChangeTheme(value));
          }
        },
      ),
      onTap: () {
        context.read<SettingsBloc>().add(ChangeTheme(value));
      },
    );
  }

  Widget _buildLanguageSelector(BuildContext context, SettingsState state) {
    return Card(
      child: Column(
        children: [
          _buildLanguageOption(
            context: context,
            title: 'English',
            value: 'en',
            groupValue: state.locale,
            flag: '🇺🇸',
          ),
          const Divider(height: 1),
          _buildLanguageOption(
            context: context,
            title: 'العربية',
            value: 'ar',
            groupValue: state.locale,
            flag: '🇸🇦',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String title,
    required String value,
    required String groupValue,
    required String flag,
  }) {
    return ListTile(
      leading: Text(flag, style: TextStyle(fontSize: 24.sp)),
      title: Text(title),
      trailing: Radio<String>(
        value: value,
        groupValue: groupValue,
        onChanged: (value) {
          if (value != null) {
            context.read<SettingsBloc>().add(ChangeLocale(value));
            context.setLocale(Locale(value));
          }
        },
      ),
      onTap: () {
        context.read<SettingsBloc>().add(ChangeLocale(value));
        context.setLocale(Locale(value));
      },
    );
  }

  Widget _buildSpeedSelector(BuildContext context, SettingsState state) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Default Animation Speed',
                  style: TextStyle(fontSize: 14.sp),
                ),
                Text(
                  '${state.defaultSpeed.toStringAsFixed(1)}x',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Slider(
              value: state.defaultSpeed,
              min: 0.25,
              max: 4.0,
              divisions: 15,
              onChanged: (value) {
                context.read<SettingsBloc>().add(ChangeDefaultSpeed(value));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0.25x', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                Text('4.0x', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Algorithm Visualizer'),
            subtitle: const Text('Learn algorithms through visualization'),
          ),
        ],
      ),
    );
  }
}
