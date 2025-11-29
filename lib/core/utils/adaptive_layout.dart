import 'package:flutter/material.dart';

/// Screen breakpoints for responsive design
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1800;
}

/// Device type enum
enum DeviceType { mobile, tablet, desktop, largeDesktop }

/// Adaptive layout utilities
class AdaptiveLayout {
  /// Get the current device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < Breakpoints.mobile) return DeviceType.mobile;
    if (width < Breakpoints.tablet) return DeviceType.tablet;
    if (width < Breakpoints.desktop) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  /// Check if the screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < Breakpoints.mobile;
  }

  /// Check if the screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.mobile && width < Breakpoints.tablet;
  }

  /// Check if the screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.tablet;
  }

  /// Check if the screen is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.desktop;
  }

  /// Get adaptive padding based on screen size
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(12);
      case DeviceType.tablet:
        return const EdgeInsets.all(16);
      case DeviceType.desktop:
        return const EdgeInsets.all(24);
      case DeviceType.largeDesktop:
        return const EdgeInsets.all(32);
    }
  }

  /// Get adaptive horizontal padding
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < Breakpoints.mobile) return 12;
    if (width < Breakpoints.tablet) return 16;
    if (width < Breakpoints.desktop) return 24;
    if (width < Breakpoints.largeDesktop) return 48;
    // For very large screens, center content with max width
    return (width - 1400) / 2;
  }

  /// Get grid cross axis count based on screen width
  static int getGridCrossAxisCount(BuildContext context, {int mobileCols = 1, int tabletCols = 2, int desktopCols = 3, int largeCols = 4}) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobileCols;
      case DeviceType.tablet:
        return tabletCols;
      case DeviceType.desktop:
        return desktopCols;
      case DeviceType.largeDesktop:
        return largeCols;
    }
  }

  /// Get adaptive font size multiplier
  static double getFontMultiplier(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 1.0;
      case DeviceType.tablet:
        return 1.1;
      case DeviceType.desktop:
        return 1.15;
      case DeviceType.largeDesktop:
        return 1.2;
    }
  }

  /// Get adaptive icon size
  static double getIconSize(BuildContext context, {double baseSize = 24}) {
    return baseSize * getFontMultiplier(context);
  }

  /// Get adaptive spacing
  static double getSpacing(BuildContext context, {double baseSpacing = 16}) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return baseSpacing * 0.75;
      case DeviceType.tablet:
        return baseSpacing;
      case DeviceType.desktop:
        return baseSpacing * 1.25;
      case DeviceType.largeDesktop:
        return baseSpacing * 1.5;
    }
  }
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = AdaptiveLayout.getDeviceType(context);
        return builder(context, deviceType);
      },
    );
  }
}

/// Widget that shows different layouts based on screen size
class AdaptiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const AdaptiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.tablet && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= Breakpoints.mobile && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

/// Constrained content wrapper for large screens
class ConstrainedContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = 1400,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? AdaptiveLayout.getAdaptivePadding(context),
          child: child,
        ),
      ),
    );
  }
}
