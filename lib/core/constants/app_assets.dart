import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppAssets {
  // Figma Static PNG Assets (assets/images/figma/)
  static const String avatar = 'assets/images/figma/avatar.png';
  static const String actionRepair = 'assets/images/figma/action_repair.png';
  static const String actionDonate = 'assets/images/figma/action_donate.png';
  static const String actionRecycle = 'assets/images/figma/action_recycle.png';
  static const String actionResale = 'assets/images/figma/action_resale.png';
  static const String closetBanner = 'assets/images/figma/closet_banner.png';
  static const String emptyShoes = 'assets/images/figma/empty_shoes.png';

  // Home Marketplace Shoe Images
  static const String shoeHome1 = 'assets/images/figma/shoe_home_1.png';
  static const String shoeHome2 = 'assets/images/figma/shoe_home_2.png';
  static const String shoeHome3 = 'assets/images/figma/shoe_home_3.png';
  static const String shoeHome4 = 'assets/images/figma/shoe_home_4.png';

  // Snap Tips Angles
  static const String snapTop = 'assets/images/figma/snap_top.png';
  static const String snapRight = 'assets/images/figma/snap_right.png';
  static const String snapLeft = 'assets/images/figma/snap_left.png';
  static const String snapBottom = 'assets/images/figma/snap_bottom.png';

  // Snap Tips Avoid
  static const String avoidMultiple = 'assets/images/figma/avoid_multiple.png';
  static const String avoidCropped = 'assets/images/figma/avoid_cropped.png';
  static const String avoidDark = 'assets/images/figma/avoid_dark.png';
  static const String avoidBlurry = 'assets/images/figma/avoid_blurry.png';

  // Figma Navigation SVGs
  static const String navHome = 'assets/images/figma/nav_home.svg';
  static const String navShoes = 'assets/images/figma/nav_shoes.svg';
  static const String navMarketplace =
      'assets/images/figma/nav_marketplace.svg';
  static const String navScan = 'assets/images/figma/nav_scan.svg';

  // Figma Action & Metric SVGs
  static const String metricShoes = 'assets/images/figma/metric_shoes.svg';
  static const String metricValue = 'assets/images/figma/metric_value.svg';
  static const String metricImpact = 'assets/images/figma/metric_impact.svg';
  static const String filter = 'assets/images/figma/filter.svg';
  static const String dismiss = 'assets/images/figma/dismiss.svg';
  static const String success = 'assets/images/figma/success.svg';
  static const String chevron = 'assets/images/figma/chevron.svg';
  static const String conditionShoes =
      'assets/images/figma/condition_shoes.svg';
  static const String tag = 'assets/images/figma/tag.svg';

  // Splash / Loading Screen Assets
  static const String loadingScreen = 'assets/images/figma/loading_screen.png';
  static const String splashLockup =
      'assets/images/figma/splash_project_shoes_lockup.png';
  static const String splashEmblem =
      'assets/images/figma/splash_project_shoes_emblem.png';
  static const String splashEarthDnaSeal =
      'assets/images/figma/splash_earthdna_seal.png';
  static const String earthSatelliteGlobe =
      'assets/images/figma/earth_satellite_globe.png';
  static const String ftue2ShoesIllustration =
      'assets/images/figma/ftue2_shoes_illustration.png';
  static const String ftue2HeelIllustration =
      'assets/images/figma/ftue2_heel_illustration.png';
  static const String ftue3ViewfinderShoe =
      'assets/images/figma/ftue3_viewfinder_shoe.png';
  static const String ftue4WireframeKnot =
      'assets/images/figma/ftue4_wireframe_knot.png';
  static const String ftue5SoleSaverBadge =
      'assets/images/figma/ftue5_sole_saver_badge.png';

  // Video Assets (Set to asset path if an mp4 file is added to assets/videos/)
  static const String? earthOrbitVideo = null;

  /// Renders a local SVG asset with optional tint color and dimensions
  static Widget svg(
    String assetPath, {
    Color? color,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Renders a local image with a fallback widget if the asset is missing
  static Widget imageOrFallback(
    String assetPath, {
    required Widget fallback,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
