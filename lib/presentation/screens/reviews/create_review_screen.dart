import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../domain/repositories/catalog_repository.dart';

class CreateReviewScreen extends StatefulWidget {
  const CreateReviewScreen({super.key, required this.productId});

  final String productId;

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _reviewController = TextEditingController();

  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);
    try {
      await context.read<CatalogRepository>().createReview(
            productId: widget.productId,
            rating: _rating,
            comment: _reviewController.text.trim(),
          );
      if (!mounted) return;
      SnackbarUtils.show(context, 'Review submitted successfully.');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      SnackbarUtils.show(context, e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      SnackbarUtils.show(
        context,
        'Could not submit review. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Review',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                AppTextField(
                  controller: _firstNameController,
                  hint: 'First Name',
                  validator: (v) =>
                      Validators.notEmpty(v, field: 'First name'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _lastNameController,
                  hint: 'Last Name',
                  validator: (v) =>
                      Validators.notEmpty(v, field: 'Last name'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Rating:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    for (int star = 1; star <= 5; star++)
                      IconButton(
                        onPressed: () => setState(() => _rating = star),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: Icon(
                          star <= _rating ? Icons.star : Icons.star_border,
                          color: AppColors.star,
                          size: 26,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _reviewController,
                  hint: 'Write Review',
                  maxLines: 6,
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.notEmpty(v, field: 'Review'),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Submit',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
