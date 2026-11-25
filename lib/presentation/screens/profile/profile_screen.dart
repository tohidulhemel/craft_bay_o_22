import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_routes.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../domain/models/user_profile.dart';
import '../../state/auth_state.dart';
import '../../state/cart_state.dart';
import '../../state/nav_state.dart';
import '../../state/wishlist_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  String? _populatedSignature;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile({bool force = false}) async {
    final auth = context.read<AuthState>();
    final ok = await auth.loadProfile(force: force);
    if (!mounted) return;
    if (ok && auth.profile != null) {
      _syncControllers(auth.profile!);
    }
  }

  void _syncControllers(UserProfile profile) {
    final signature =
        '${profile.id}|${profile.firstName}|${profile.lastName}|${profile.email}|${profile.phone}|${profile.city}|${profile.address}';
    if (_populatedSignature == signature) return;
    _populatedSignature = signature;

    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _cityController.text = profile.city;
    _addressController.text = profile.address;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthState>();
    final ok = await auth.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
    );
    if (!mounted) return;

    if (ok) {
      if (auth.profile != null) _syncControllers(auth.profile!);
      SnackbarUtils.show(context, 'Profile updated successfully.');
    } else {
      SnackbarUtils.show(
        context,
        auth.errorMessage ?? 'Could not update profile.',
        isError: true,
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to log out of CraftyBay?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await context.read<AuthState>().logout();
    if (!mounted) return;
    context.read<CartState>().clearLocal();
    context.read<WishlistState>().clearLocal();
    context.read<NavState>().goHome();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final profile = auth.profile;

    if (profile != null) {
      _syncControllers(profile);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadProfile(force: true),
        child: _buildBody(auth, profile),
      ),
    );
  }

  Widget _buildBody(AuthState auth, UserProfile? profile) {
    if (auth.isProfileLoading && profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profile == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          Text(
            auth.errorMessage ?? 'Could not load profile.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textGrey),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () => _loadProfile(force: true),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 42),
              ),
              child: const Text('Retry'),
            ),
          ),
          const SizedBox(height: 24),
          _LogoutButton(onPressed: _logout),
        ],
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHeaderCard(profile: profile),
          const SizedBox(height: 20),
          const Text(
            'Profile Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _firstNameController,
                  hint: 'First Name',
                  validator: (v) =>
                      Validators.notEmpty(v, field: 'First name'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _lastNameController,
                  hint: 'Last Name',
                  validator: (v) => Validators.notEmpty(v, field: 'Last name'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  readOnly: true,
                  enabled: false,
                  decoration: const InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _phoneController,
                  hint: 'Mobile',
                  keyboardType: TextInputType.phone,
                  validator: Validators.mobile,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _cityController,
                  hint: 'City',
                  validator: (v) => Validators.notEmpty(v, field: 'City'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _addressController,
                  hint: 'Shipping Address',
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.notEmpty(v, field: 'Address'),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Save Changes',
                  isLoading: auth.isLoading,
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          _LogoutButton(onPressed: _logout),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile.avatarUrl;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            backgroundImage: avatarUrl != null
                ? CachedNetworkImageProvider(avatarUrl)
                : null,
            child: avatarUrl == null
                ? Text(
                    profile.initials,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                if (profile.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    profile.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
                if (profile.city.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          profile.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.logout, size: 18),
      label: const Text('Logout'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
