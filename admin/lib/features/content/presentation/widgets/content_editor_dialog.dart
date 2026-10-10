import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/admin_content_model.dart';
import '../controllers/admin_content_controller.dart';

class ContentEditorDialog extends StatefulWidget {
  const ContentEditorDialog({super.key, required this.type, this.item});

  final String type;
  final AdminContentModel? item;

  @override
  State<ContentEditorDialog> createState() => _ContentEditorDialogState();
}

class _ContentEditorDialogState extends State<ContentEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  late final TextEditingController _contentController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _documentUrlController;

  late String? _category;
  DateTime? _expiresAt;

  bool _isSaving = false;

  static const Color _primaryRed = Color(0xFFD32F2F);
  static const Color _primaryBlue = Color(0xFF1565C0);
  static const Color _borderColor = Color(0xFFE0E5ED);

  bool get _isEditing => widget.item != null;

  bool get _isAnnouncement => widget.type == 'announcements';

  bool get _isNews => widget.type == 'news';

  bool get _isPublication => widget.type == 'publications';

  String get _typeLabel {
    switch (widget.type) {
      case 'announcements':
        return 'Announcement';
      case 'news':
        return 'News / Article';
      case 'publications':
        return 'Publication';
      default:
        return 'Content';
    }
  }

  List<DropdownMenuItem<String>> get _categoryItems {
    final categories = switch (widget.type) {
      'news' => const [
        ('market', 'Market'),
        ('asset', 'Asset'),
        ('tokenization', 'Tokenization'),
        ('education', 'Education'),
        ('company', 'Company'),
        ('general', 'General'),
      ],
      'publications' => const [
        ('education', 'Education'),
        ('guide', 'Guide'),
        ('report', 'Report'),
        ('platform', 'Platform'),
        ('general', 'General'),
      ],
      _ => const <(String, String)>[],
    };

    return categories
        .map(
          (category) => DropdownMenuItem<String>(
            value: category.$1,
            child: Text(category.$2),
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _titleController = TextEditingController(text: item?.title ?? '');
    _summaryController = TextEditingController(text: item?.summary ?? '');
    _contentController = TextEditingController(text: item?.content ?? '');
    _imageUrlController = TextEditingController(text: item?.imageUrl ?? '');
    _documentUrlController = TextEditingController(
      text: item?.documentUrl ?? '',
    );

    _category = item?.category;
    _expiresAt = item?.expiresAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    _documentUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 760,
          maxHeight: screenSize.height * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: _borderColor),
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeading(
                        'Content details',
                        'Enter the main information for this $_typeLabel.',
                      ),
                      const SizedBox(height: 20),
                      _buildTitleField(),
                      if (!_isAnnouncement) ...[
                        const SizedBox(height: 18),
                        _buildSummaryField(),
                      ],
                      if (!_isAnnouncement) ...[
                        const SizedBox(height: 18),
                        _buildCategoryField(),
                      ],
                      const SizedBox(height: 18),
                      _buildContentField(),
                      const SizedBox(height: 24),
                      _buildSectionHeading(
                        'Media and attachments',
                        'Provide optional links to supporting media.',
                      ),
                      const SizedBox(height: 18),
                      _buildImageUrlField(),
                      if (_isPublication) ...[
                        const SizedBox(height: 18),
                        _buildDocumentUrlField(),
                      ],
                      if (_isAnnouncement) ...[
                        const SizedBox(height: 24),
                        _buildExpiryField(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: _borderColor),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _primaryRed.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isEditing ? Icons.edit_note_outlined : Icons.add_circle_outline,
              color: _primaryRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_isEditing ? 'Edit' : 'Create'} $_typeLabel',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF202B3C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditing
                      ? 'Update the existing content record.'
                      : 'Add new content to the AssetCoin platform.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF758195),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: _isSaving
                ? null
                : () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF202B3C),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          description,
          style: const TextStyle(fontSize: 12, color: Color(0xFF758195)),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return _buildTextField(
      controller: _titleController,
      label: 'Title',
      hint: 'Enter a clear, descriptive title',
      icon: Icons.title,
      requiredField: true,
      maxLength: 200,
    );
  }

  Widget _buildSummaryField() {
    return _buildTextField(
      controller: _summaryController,
      label: 'Summary',
      hint: 'Write a short introduction or preview',
      icon: Icons.short_text,
      maxLines: 3,
      maxLength: 1000,
    );
  }

  Widget _buildContentField() {
    return _buildTextField(
      controller: _contentController,
      label: 'Content body',
      hint: 'Write the full content here...',
      icon: Icons.notes_outlined,
      maxLines: 8,
      requiredField: true,
    );
  }

  Widget _buildImageUrlField() {
    return _buildTextField(
      controller: _imageUrlController,
      label: 'Image URL (optional)',
      hint: 'https://example.com/image.jpg',
      icon: Icons.image_outlined,
      keyboardType: TextInputType.url,
      validator: _validateOptionalUrl,
    );
  }

  Widget _buildDocumentUrlField() {
    return _buildTextField(
      controller: _documentUrlController,
      label: 'Document URL (optional)',
      hint: 'https://example.com/document.pdf',
      icon: Icons.picture_as_pdf_outlined,
      keyboardType: TextInputType.url,
      validator: _validateOptionalUrl,
    );
  }

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      initialValue: _category,
      isExpanded: true,
      decoration: _inputDecoration(
        label: 'Category',
        hint: 'Select a category',
        icon: Icons.category_outlined,
      ),
      items: _categoryItems,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category.';
        }
        return null;
      },
      onChanged: _isSaving
          ? null
          : (value) => setState(() => _category = value),
    );
  }

  Widget _buildExpiryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Announcement expiry',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF202B3C),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: _borderColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_outlined, color: _primaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _expiresAt == null
                      ? 'No expiry date selected'
                      : _formatDate(_expiresAt!),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF202B3C),
                  ),
                ),
              ),
              TextButton(
                onPressed: _isSaving ? null : _selectExpiryDate,
                child: const Text('Choose date'),
              ),
              if (_expiresAt != null)
                IconButton(
                  tooltip: 'Clear expiry date',
                  onPressed: _isSaving
                      ? null
                      : () => setState(() => _expiresAt = null),
                  icon: const Icon(Icons.close, size: 18),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Optional. The announcement can have no expiry date.',
          style: TextStyle(fontSize: 11, color: Color(0xFF758195)),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool requiredField = false,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isSaving,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator:
          validator ??
          (requiredField
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label is required.';
                  }
                  return null;
                }
              : null),
      decoration: _inputDecoration(label: label, hint: hint, icon: icon),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: _primaryBlue),
      alignLabelWithHint: true,
      filled: true,
      fillColor: const Color(0xFFFAFBFD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primaryRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primaryRed, width: 1.5),
      ),
    );
  }

  String? _validateOptionalUrl(String? value) {
    final input = value?.trim() ?? '';

    if (input.isEmpty) return null;

    final uri = Uri.tryParse(input);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      return 'Enter a valid HTTP or HTTPS URL.';
    }

    return null;
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 10),
      helpText: 'Select announcement expiry date',
    );

    if (selected != null && mounted) {
      setState(() {
        _expiresAt = DateTime(
          selected.year,
          selected.month,
          selected.day,
          23,
          59,
          59,
        );
      });
    }
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 12,
        runSpacing: 10,
        children: [
          OutlinedButton(
            onPressed: _isSaving
                ? null
                : () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF596579),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveContent,
            style: FilledButton.styleFrom(
              backgroundColor: _primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: _isSaving
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(_isEditing ? Icons.save_outlined : Icons.add),
            label: Text(_isSaving ? 'Saving...' : 'Save as draft'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveContent() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'imageUrl': _emptyToNull(_imageUrlController.text),
    };

    if (!_isAnnouncement) {
      data['summary'] = _emptyToNull(_summaryController.text);
      data['category'] = _category;
    }

    if (_isPublication) {
      data['documentUrl'] = _emptyToNull(_documentUrlController.text);
    }

    if (_isAnnouncement) {
      data['expiresAt'] = _expiresAt?.toIso8601String();
    }

    setState(() => _isSaving = true);

    try {
      final controller = AdminContentControllerRef.read(context);

      if (_isEditing) {
        await controller.updateContent(
          type: widget.type,
          id: widget.item!.id,
          data: data,
        );
      } else {
        await controller.createContent(type: widget.type, data: data);
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save $_typeLabel: $error'),
          backgroundColor: _primaryRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  static String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

/// Small adapter for obtaining the existing Riverpod controller from a
/// dialog context without changing the rest of the editor implementation.
class AdminContentControllerRef {
  static dynamic read(BuildContext context) {
    throw UnimplementedError(
      'Replace this adapter with the WidgetRef from a ConsumerStatefulWidget.',
    );
  }
}
