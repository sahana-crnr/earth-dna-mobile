import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../models/catalog_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shoes_provider.dart';
import '../../widgets/condition_badge.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../scan/camera_capture_screen.dart';
import '../shoes/shoe_profile_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({
    super.key,
    this.onMarketplaceTap,
    this.onViewAllTap,
  });

  final VoidCallback? onMarketplaceTap;
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    final shoesProvider = Provider.of<ShoesProvider>(context);
    final shoes = shoesProvider.shoes;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: RefreshIndicator(
              onRefresh: () => shoesProvider.fetchShoesAndSummary(),
              color: AppColors.primaryGreenDark,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: 110,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header: S.H.O.E.S. + Profile Avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'S.H.O.E.S.',
                            style: GoogleFonts.instrumentSans(
                              color: AppColors.textLightPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Semantics(
                          button: true,
                          label: 'User profile and account settings',
                          child: GestureDetector(
                            onTap: () => _showProfileModal(context, authProvider),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE2E8F0),
                                border: Border.all(
                                  color: authProvider.isAuthenticated
                                      ? AppColors.buttonLime
                                      : AppColors.cardLightBorder,
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  AppAssets.avatar,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Center(
                                    child: Text(
                                      user?.fullName.isNotEmpty == true
                                          ? user!.fullName[0].toUpperCase()
                                          : 'G',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                        color: Color(0xFF2D2C72),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // 4 Action Icons: Repair, Donate, Recycle, Resale (Figma PNG assets)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 350,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildActionIcon('Repair', AppAssets.actionRepair),
                            _buildActionIcon('Donate', AppAssets.actionDonate),
                            _buildActionIcon('Recycle', AppAssets.actionRecycle),
                            _buildActionIcon('Resale', AppAssets.actionResale),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),

                // "Your Recent Scans" Section Header
                _buildSectionHeader(
                  title: 'Your Recent Scans',
                  svgAsset: AppAssets.conditionShoes,
                  trailing: shoes.isNotEmpty && onViewAllTap != null
                      ? GestureDetector(
                          onTap: onViewAllTap,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View All',
                                style: TextStyle(
                                  color: Color(0xFF586B4D),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: Color(0xFF586B4D),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),

                // Scans Content: Empty State Banner vs Horizontal Recent Scans List
                if (shoes.isEmpty && shoesProvider.isLoading)
                  const _HomeStatusCard(
                    icon: CircularProgressIndicator(),
                    title: 'Loading your shoes',
                    message: 'Your recent scans will appear here.',
                  )
                else if (shoes.isEmpty && shoesProvider.errorMessage != null)
                  _HomeStatusCard(
                    icon: const Icon(Icons.cloud_off_outlined),
                    title: 'Your scans could not load',
                    message: 'Check your connection and try again.',
                    action: TextButton(
                      onPressed: shoesProvider.fetchShoesAndSummary,
                      child: const Text('Try again'),
                    ),
                  )
                else if (shoes.isEmpty)
                  _buildFirstTimeBanner(context)
                else
                  SizedBox(
                    height: 236,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: shoes.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (ctx, index) {
                        final shoe = shoes[index];
                        return _buildRecentScanCard(ctx, shoe);
                      },
                    ),
                  ),

                const SizedBox(height: 28),

                // "Marketplace" Section Header
                _buildSectionHeader(
                  title: 'Marketplace',
                  svgAsset: AppAssets.tag,
                  trailing: GestureDetector(
                    onTap: onMarketplaceTap,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Browse All',
                          style: TextStyle(
                            color: Color(0xFF586B4D),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Color(0xFF586B4D),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Horizontal Marketplace Preview Cards (Live from Database / Catalog)
                Builder(
                  builder: (context) {
                    final liveItems = shoesProvider.marketplaceItems;
                    final displayItems =
                        liveItems.isNotEmpty ? liveItems : _marketplacePreviewItems;
                    return SizedBox(
                      height: 195,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: displayItems.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (ctx, index) {
                          final item = displayItems[index];
                          return _buildMarketplaceCard(context, item);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
  }

  // ─── User Profile Bottom Sheet (Connected to AuthProvider & DB) ───────────
  void _showProfileModal(BuildContext context, AuthProvider auth) {
    final user = auth.currentUser;
    final isAuthenticated = auth.isAuthenticated;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (ctx) {
        return Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Large Avatar with border
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF1F5F9),
                    border: Border.all(
                      color: isAuthenticated
                          ? AppColors.buttonLime
                          : const Color(0xFFCBD5E1),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      AppAssets.avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(
                          user?.fullName.isNotEmpty == true
                              ? user!.fullName[0].toUpperCase()
                              : 'G',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2D2C72),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Full Name
                Text(
                  isAuthenticated
                      ? (user?.fullName.isNotEmpty == true
                          ? user!.fullName
                          : 'Planetary Healer')
                      : 'Guest Healer',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),

                // Email
                Text(
                  isAuthenticated
                      ? (user?.email.isNotEmpty == true
                          ? user!.email
                          : 'Connected Account')
                      : 'Not signed in',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),

                // Status / Role Pill Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isAuthenticated
                        ? const Color(0xFFEAF8D7)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAuthenticated
                              ? const Color(0xFF15803D)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAuthenticated
                            ? 'Planetary Healer · ${user?.role ?? "USER"}'
                            : 'Guest Mode · No account',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isAuthenticated
                              ? const Color(0xFF15803D)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info Cards (Location, Zip) if authenticated
                if (isAuthenticated) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildProfileRow(
                          icon: Icons.public_outlined,
                          label: 'Country / Region',
                          value: user?.country ?? 'USA',
                        ),
                        if (user?.zipCode != null && user!.zipCode!.isNotEmpty) ...[
                          const Divider(height: 18, color: Color(0xFFE2E8F0)),
                          _buildProfileRow(
                            icon: Icons.place_outlined,
                            label: 'Zip / Postal Code',
                            value: user.zipCode!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action Buttons
                if (isAuthenticated) ...[
                  // Edit Profile button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showEditProfileModal(context, auth, user);
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Color(0xFF0F172A),
                      ),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await auth.logout();
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ] else ...[
                  // Guest: Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonLime,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Sign In to Account',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Guest: Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  },
);
  }

  static void _showEditProfileModal(
    BuildContext context,
    AuthProvider auth,
    UserModel? user,
  ) {
    final nameController = TextEditingController(text: user?.fullName ?? '');
    final countryController = TextEditingController(text: user?.country ?? '');
    final zipController = TextEditingController(text: user?.zipCode ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (ctx) {
        return Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width.clamp(0.0, 430.0),
            child: StatefulBuilder(
              builder: (modalCtx, setModalState) {
            final bottomInset = MediaQuery.of(modalCtx).viewInsets.bottom;
            return Container(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Full Name (Editable)
                      _buildEditLabel('Full Name'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: _buildInputDecoration(
                          hint: 'Enter your full name',
                          prefixIcon: Icons.person_outline,
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Full name is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Email (LOCKED - Read only)
                      Row(
                        children: [
                          _buildEditLabel('Email address'),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock, size: 11, color: Color(0xFF64748B)),
                                SizedBox(width: 3),
                                Text(
                                  'Locked',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        initialValue: user?.email ?? '',
                        readOnly: true,
                        enabled: false,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                        decoration: _buildInputDecoration(
                          prefixIcon: Icons.email_outlined,
                          suffixIcon: const Icon(Icons.lock_outline, size: 18, color: Color(0xFF94A3B8)),
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Email address is tied to your account identity and cannot be edited.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 16),

                      // Country / Region (Editable)
                      _buildEditLabel('Country / Region'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: countryController,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: _buildInputDecoration(
                          hint: 'e.g. USA, IND, GBR',
                          prefixIcon: Icons.public_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Zip / Postal Code (Editable)
                      _buildEditLabel('Zip / Postal Code'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: zipController,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: _buildInputDecoration(
                          hint: 'e.g. 560001, 90210',
                          prefixIcon: Icons.place_outlined,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonLime,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setModalState(() => isSaving = true);

                                  await auth.updateProfile(
                                    fullName: nameController.text.trim(),
                                    country: countryController.text.trim(),
                                    zipCode: zipController.text.trim(),
                                  );

                                  if (modalCtx.mounted) {
                                    Navigator.pop(modalCtx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Profile updated successfully!'),
                                        backgroundColor: Color(0xFF15803D),
                                      ),
                                    );
                                  }
                                },
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  },
);
  }

  static Widget _buildEditLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
    );
  }

  static InputDecoration _buildInputDecoration({
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    Color? fillColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFF64748B), size: 20)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor ?? const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2D2C72), width: 1.5),
      ),
    );
  }

  static Widget _buildProfileRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF64748B)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // ─── Section Header (Capsule + Overlapping SVG Icon matching Figma) ────────
  Widget _buildSectionHeader({
    required String title,
    required String svgAsset,
    Widget? trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC7D2FE), // Indigo/200
                          borderRadius: BorderRadius.circular(32.5),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6,
                      top: 3,
                      child: AppAssets.svg(
                        svgAsset,
                        width: 30,
                        height: 30,
                        color: const Color(0xFF2D2C72), // Indigo/900
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
      ],
    );
  }

  // ─── Marketplace Shoe Card (Live Catalog / Preview) ─────────────────────
  Widget _buildMarketplaceCard(
    BuildContext context,
    MarketplacePreviewItem item,
  ) {
    return GestureDetector(
      onTap: onMarketplaceTap,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardLightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: Container(
                height: 125,
                width: double.infinity,
                color: const Color(0xFFF8FAFC),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Center(
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 40,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      )
                    : item.asset != null
                        ? Image.asset(
                            item.asset!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Center(
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 40,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFF1F5F9),
                            child: const Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 40,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.price,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 4 Action Icons (Figma assets) ──────────────────────────────────────────
  Widget _buildActionIcon(
    String label,
    String assetPath,
  ) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardLightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              assetPath,
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.check_circle_outline,
                size: 28,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  // ─── First Time Empty State Banner ─────────────────────────────────────────
  Widget _buildFirstTimeBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8D7), // Light lime green from Figma
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Got Shoes You Don't\nWear Anymore?",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'See what they could become next.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 90,
                  child: Image.asset(
                    AppAssets.closetBanner,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.door_sliding_outlined,
                      size: 50,
                      color: Color(0xFF84CC16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonLime,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CameraCaptureScreen(),
                  ),
                );
              },
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Scan your first pair',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Recent Scan Card ──────────────────────────────────────────────────────
  Widget _buildRecentScanCard(BuildContext context, dynamic shoe) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ShoeProfileScreen(shoeId: shoe.id)),
        );
      },
      child: Container(
        width: 175,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Condition Badge in Top-Left
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  child: shoe.primaryPhotoUrl != null
                      ? Image.network(
                          shoe.primaryPhotoUrl!,
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildShoePlaceholder(),
                        )
                      : _buildShoePlaceholder(),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: ConditionBadge(
                    code: shoe.conditionCode,
                    label: shoe.conditionLabel ?? 'Condition unavailable',
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shoe.brandName.isNotEmpty ? shoe.brandName : 'Brand unavailable',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [shoe.model, shoe.color]
                            .whereType<String>()
                            .where((value) => value.isNotEmpty)
                            .join(' - ')
                            .isEmpty
                        ? 'Model details unavailable'
                        : [shoe.model, shoe.color]
                              .whereType<String>()
                              .where((value) => value.isNotEmpty)
                              .join(' - '),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    shoe.resaleValueFormatted != null
                        ? 'Resell - ${shoe.resaleValueFormatted}'
                        : (shoe.recommendedAction != null
                            ? shoe.recommendedAction!
                            : 'Scan completed'),
                    style: const TextStyle(
                      color: Color(0xFF15803D),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoePlaceholder() {
    return Container(
      height: 125,
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.roller_skating, size: 48, color: Color(0xFF94A3B8)),
      ),
    );
  }
}

const List<MarketplacePreviewItem> _marketplacePreviewItems = [
  MarketplacePreviewItem(
    title: 'On Running · Cloudmonster',
    price: r'$35',
    asset: AppAssets.shoeHome1,
  ),
  MarketplacePreviewItem(
    title: 'Nike · Air Max 90 · White / Grey',
    price: r'$25',
    asset: AppAssets.shoeHome2,
  ),
  MarketplacePreviewItem(
    title: 'Adidas Originals',
    price: r'$40',
    asset: AppAssets.shoeHome3,
  ),
  MarketplacePreviewItem(
    title: 'Puma Suede Classic',
    price: r'$30',
    asset: AppAssets.shoeHome4,
  ),
];

class _HomeStatusCard extends StatelessWidget {
  const _HomeStatusCard({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final Widget icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardLightBorder),
      ),
      child: Row(
        children: [
          SizedBox(width: 28, height: 28, child: Center(child: icon)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
                ?action,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
