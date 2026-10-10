import 'package:flutter/material.dart';

import '../../data/models/admin_staff_model.dart';
import '../../data/models/admin_staff_role_model.dart';

class StaffFormDialog extends StatefulWidget {
  const StaffFormDialog({
    super.key,
    required this.roles,
    required this.onSubmit,
    this.staff,
  });

  final List<AdminStaffRoleModel> roles;
  final AdminStaffModel? staff;

  /// Returns true when the parent successfully saves the staff member.
  final Future<bool> Function(Map<String, dynamic> values) onSubmit;

  @override
  State<StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  String? _selectedRoleCode;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.staff != null;

  @override
  void initState() {
    super.initState();

    final staff = widget.staff;

    _firstNameController = TextEditingController(text: staff?.firstName ?? '');
    _lastNameController = TextEditingController(text: staff?.lastName ?? '');
    _emailController = TextEditingController(text: staff?.email ?? '');
    _phoneController = TextEditingController(text: staff?.phone ?? '');

    _selectedRoleCode = staff?.roleCode;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Staff Member' : 'Create Staff Account'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameController,
                        label: 'First name',
                        requiredField: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _lastNameController,
                        label: 'Last name',
                        requiredField: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email address',
                  requiredField: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRoleCode,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Staff role',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.roles
                      .where((role) => role.isActive)
                      .map(
                        (role) => DropdownMenuItem<String>(
                          value: role.code,
                          child: Text(role.name),
                        ),
                      )
                      .toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a staff role.';
                    }

                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedRoleCode = value;
                    });
                  },
                ),
                if (!_isEditing) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'The backend should securely provision the initial '
                      'credentials and communicate them through its '
                      'approved onboarding process.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(_isEditing ? Icons.save_outlined : Icons.person_add),
          label: Text(_isEditing ? 'Save Changes' : 'Create Account'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool requiredField = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator:
          validator ??
          (value) {
            if (requiredField && (value == null || value.trim().isEmpty)) {
              return '$label is required.';
            }

            return null;
          },
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required.';
    }

    final email = value.trim();

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final values = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      'roleCode': _selectedRoleCode,
    };

    try {
      final success = await widget.onSubmit(values);

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage =
              'Unable to save the staff member. '
              'Check the error message on the page and try again.';
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
