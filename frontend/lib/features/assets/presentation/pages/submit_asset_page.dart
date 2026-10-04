
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/colors.dart';
import '../controllers/asset_submission_controller.dart';
import '../providers/asset_providers.dart';

class SubmitAssetPage extends ConsumerStatefulWidget {
  const SubmitAssetPage({super.key});

  @override
  ConsumerState<SubmitAssetPage> createState() =>
      _SubmitAssetPageState();
}

class _SubmitAssetPageState extends ConsumerState<SubmitAssetPage> {
  final _formKey = GlobalKey<FormState>();

  // =========================
  // FORM CONTROLLERS
  // =========================

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _registrationController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  final _currencyController = TextEditingController(text: 'KES');

  // =========================
  // FILE PICKERS
  // =========================

  final ImagePicker _imagePicker = ImagePicker();

  List<XFile> _selectedPhotos = [];
  List<PlatformFile> _selectedDocuments = [];

  // =========================
  // FORM STATE
  // =========================

  String? _selectedAssetType;

  String _selectedDocumentType = 'ownership';

  // =========================
  // SUBMISSION STATE
  // =========================

  int? _createdAssetId;

  bool _isUploading = false;
  bool _isPickingFiles = false;

  bool _photosUploaded = false;
  bool _documentsUploaded = false;

  // =========================
  // ASSET CATEGORIES
  // =========================

  static const List<Map<String, String>> _assetTypes = [
    {'value': 'land', 'label': 'Land'},
    {'value': 'livestock', 'label': 'Livestock'},
    {'value': 'produce', 'label': 'Agricultural Produce'},
    {'value': 'vehicle', 'label': 'Vehicle'},
    {'value': 'property', 'label': 'Property'},
    {'value': 'equipment', 'label': 'Equipment'},
    {'value': 'other', 'label': 'Other'},
  ];

  // =========================
  // DOCUMENT CATEGORIES
  // =========================

  static const List<Map<String, String>> _documentTypes = [
    {'value': 'ownership', 'label': 'Ownership Document'},
    {'value': 'valuation', 'label': 'Valuation Report'},
    {'value': 'registration', 'label': 'Registration Document'},
    {'value': 'identification', 'label': 'Identification Document'},
    {'value': 'legal', 'label': 'Legal Document'},
    {'value': 'inspection', 'label': 'Inspection Report'},
    {'value': 'other', 'label': 'Other'},
  ];

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _registrationController.dispose();
    _estimatedValueController.dispose();
    _currencyController.dispose();

    super.dispose();
  }

  // =========================
  // SELECT ASSET PHOTOS
  // =========================

  Future<void> _pickPhotos() async {
    if (_isPickingFiles ||
        _isUploading ||
        _createdAssetId != null) {
      return;
    }

    final remaining = 5 - _selectedPhotos.length;

    if (remaining <= 0) {
      _showMessage('You can select a maximum of 5 photos.');
      return;
    }

    try {
      setState(() {
        _isPickingFiles = true;
      });

      final photos = await _imagePicker.pickMultiImage();

      if (!mounted || photos.isEmpty) return;

      final selectedPhotos = photos.take(remaining).toList();

      setState(() {
        _selectedPhotos = [
          ..._selectedPhotos,
          ...selectedPhotos,
        ];
      });

      if (photos.length > remaining) {
        _showMessage(
          'Only $remaining additional photo(s) were added. '
          'The maximum is 5.',
        );
      }
    } catch (error) {
      if (mounted) {
        _showMessage(
          'Unable to select photos: $error',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFiles = false;
        });
      }
    }
  }

  // =========================
  // SELECT SUPPORTING DOCUMENTS
  // =========================


Future<void> _pickDocuments() async {
  if (_isPickingFiles) return;

  setState(() {
    _isPickingFiles = true;
  });

  try {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (!mounted || files.isEmpty) return;

    final availableFiles = files
        .where((file) => file.path != null)
        .toList();

    if (availableFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to access the selected PDF files.'),
        ),
      );
      return;
    }

    final remainingSlots = 5 - _selectedDocuments.length;

    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can upload a maximum of 5 documents.'),
        ),
      );
      return;
    }

    setState(() {
      _selectedDocuments.addAll(
        availableFiles.take(remainingSlots),
      );
    });

    if (availableFiles.length > remainingSlots) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only 5 documents can be selected.'),
        ),
      );
    }
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not select documents: $error'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isPickingFiles = false;
      });
    }
  }
}

  // =========================
  // REMOVE SELECTED PHOTO
  // =========================

  void _removePhoto(int index) {
    if (_createdAssetId != null || _isUploading) return;

    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  // =========================
  // REMOVE SELECTED DOCUMENT
  // =========================

  void _removeDocument(int index) {
    if (_createdAssetId != null || _isUploading) return;

    setState(() {
      _selectedDocuments.removeAt(index);
    });
  }

  // =========================
  // SHOW SNACKBAR
  // =========================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // =========================
  // SUBMIT ASSET
  // =========================

  Future<void> _submitAsset() async {
    FocusScope.of(context).unfocus();

    if (_isUploading || _isPickingFiles) return;

    // Only create the asset once.
    // If it has already been created, retry file uploads instead.

    if (_createdAssetId != null) {
      await _uploadSelectedFiles();
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAssetType == null) {
      _showMessage('Please select an asset category.');
      return;
    }

    final estimatedValue =
        _estimatedValueController.text.trim();

    final latitude = _latitudeController.text.trim();

    final longitude = _longitudeController.text.trim();

    // Preserve the original submission payload.

    final assetData = <String, dynamic>{
      'assetType': _selectedAssetType,
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'registrationNumber': _registrationController.text.trim(),
      'currency': _currencyController.text.trim().toUpperCase(),
      if (estimatedValue.isNotEmpty)
        'estimatedValue': double.parse(estimatedValue),
      if (latitude.isNotEmpty)
        'latitude': double.parse(latitude),
      if (longitude.isNotEmpty)
        'longitude': double.parse(longitude),
    };

    // Create the asset using the existing controller.

    await ref
        .read(assetSubmissionControllerProvider.notifier)
        .submitAsset(assetData);

    if (!mounted) return;

    final submissionState =
        ref.read(assetSubmissionControllerProvider);

    if (submissionState.hasError) {
      _showMessage(
        submissionState.error.toString(),
        isError: true,
      );
      return;
    }

    // Retrieve the newly created submission and its database ID.

    final submission = ref
        .read(assetSubmissionControllerProvider.notifier)
        .lastCreatedSubmission;

    if (submission == null) {
      _showMessage(
        'Your asset submission was processed, but its ID '
        'could not be retrieved. Please check My Submissions.',
        isError: true,
      );
      return;
    }

    setState(() {
      _createdAssetId = submission.id;
    });

    // Upload selected files using the returned asset ID.

    await _uploadSelectedFiles();
  }

  // =========================
  // UPLOAD PHOTOS AND DOCUMENTS
  // =========================

  Future<void> _uploadSelectedFiles() async {
    final assetId = _createdAssetId;

    if (assetId == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final repository = ref.read(assetRepositoryProvider);

      // -------------------------
      // UPLOAD PHOTOS
      // -------------------------

      if (!_photosUploaded && _selectedPhotos.isNotEmpty) {
        final photoFiles = <http.MultipartFile>[];

        for (final photo in _selectedPhotos) {
          final multipartFile =
              await http.MultipartFile.fromPath(
            'photos',
            photo.path,
            filename: photo.name,
          );

          photoFiles.add(multipartFile);
        }

        await repository.uploadAssetPhotos(
          assetId: assetId,
          photos: photoFiles,
        );

        _photosUploaded = true;
      } else if (_selectedPhotos.isEmpty) {
        _photosUploaded = true;
      }

      // -------------------------
      // UPLOAD DOCUMENTS
      // -------------------------

      if (!_documentsUploaded &&
          _selectedDocuments.isNotEmpty) {
        final documentFiles = <http.MultipartFile>[];

        for (final document in _selectedDocuments) {
          final documentPath = document.path;

          if (documentPath == null || documentPath.isEmpty) {
            throw Exception(
              'Unable to access ${document.name}. '
              'Please select the document again.',
            );
          }

          final multipartFile =
              await http.MultipartFile.fromPath(
            'documents',
            documentPath,
            filename: document.name,
          );

          documentFiles.add(multipartFile);
        }

        await repository.uploadAssetDocuments(
          assetId: assetId,
          documents: documentFiles,
          documentType: _selectedDocumentType,
        );

        _documentsUploaded = true;
      } else if (_selectedDocuments.isEmpty) {
        _documentsUploaded = true;
      }

      if (!mounted) return;

      // Refresh the user's submissions.

      ref.invalidate(myAssetSubmissionsProvider);

      _showMessage(
        'Your asset has been submitted successfully.',
      );

      // Preserve the original navigation destination.

      context.go(RouteNames.mySubmissions);
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Your asset has been created, but a file upload failed. '
        'Your asset ID is $assetId. '
        'You can retry the upload without creating another asset. '
        'Details: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // =========================
  // BUILD PAGE
  // =========================

  @override
  Widget build(BuildContext context) {
    final submissionState =
        ref.watch(assetSubmissionControllerProvider);

    final isSubmitting = submissionState.isLoading ||
        _isUploading ||
        _isPickingFiles;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        title: const Text(
          'Submit an Asset',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
            children: [
              _buildIntroduction(),

              const SizedBox(height: 24),

              _buildSectionHeading(
                'Basic Asset Information',
                'Tell us about the real-world asset you want to register.',
              ),

              const SizedBox(height: 16),

              _buildAssetTypeField(),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _nameController,
                label: 'Asset Name',
                hint: 'e.g. Agricultural Land in Nakuru',
                icon: Icons.inventory_2_outlined,
                required: true,
                maxLength: 150,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the asset name.';
                  }

                  if (value.trim().length > 150) {
                    return 'Asset name cannot exceed 150 characters.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _descriptionController,
                label: 'Asset Description',
                hint: 'Describe your asset and its key features.',
                icon: Icons.description_outlined,
                maxLines: 4,
              ),

              const SizedBox(height: 26),

              _buildSectionHeading(
                'Asset Location',
                'Provide the location where the asset is situated.',
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'e.g. Nakuru County, Kenya',
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _latitudeController,
                      label: 'Latitude',
                      hint: 'Optional',
                      icon: Icons.public_outlined,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^-?\d*\.?\d*'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }

                        final number = double.tryParse(value);

                        if (number == null ||
                            number < -90 ||
                            number > 90) {
                          return 'Enter a value from -90 to 90.';
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildTextField(
                      controller: _longitudeController,
                      label: 'Longitude',
                      hint: 'Optional',
                      icon: Icons.public_outlined,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^-?\d*\.?\d*'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }

                        final number = double.tryParse(value);

                        if (number == null ||
                            number < -180 ||
                            number > 180) {
                          return 'Enter a value from -180 to 180.';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              _buildSectionHeading(
                'Ownership and Valuation',
                'Add available registration and valuation information.',
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _registrationController,
                label: 'Registration Number',
                hint: 'Optional registration or identification number',
                icon: Icons.badge_outlined,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _estimatedValueController,
                label: 'Estimated Asset Value',
                hint: 'e.g. 500000',
                icon: Icons.account_balance_wallet_outlined,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d*'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }

                  final number = double.tryParse(value);

                  if (number == null ||
                      !number.isFinite ||
                      number < 0) {
                    return 'Enter a valid non-negative amount.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _currencyController,
                label: 'Currency',
                hint: 'KES',
                icon: Icons.currency_exchange_outlined,
                textCapitalization: TextCapitalization.characters,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z]'),
                  ),
                  UpperCaseTextFormatter(),
                ],
                validator: (value) {
                  final currency = value?.trim() ?? '';

                  if (currency.isEmpty) {
                    return 'Please enter a currency code.';
                  }

                  if (!RegExp(r'^[A-Z]{3,10}$').hasMatch(currency)) {
                    return 'Use 3–10 uppercase letters.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 26),

              // =========================
              // ASSET PHOTOS
              // =========================

              _buildSectionHeading(
                'Asset Photos',
                'Upload clear photographs to help identify and review your asset.',
              ),

              const SizedBox(height: 16),

              _buildPhotoPicker(),

              const SizedBox(height: 26),

              // =========================
              // SUPPORTING DOCUMENTS
              // =========================

              _buildSectionHeading(
                'Supporting Documents',
                'Attach ownership, valuation, registration or other supporting PDF documents.',
              ),

              const SizedBox(height: 16),

              _buildDocumentPicker(),

              const SizedBox(height: 24),

              _buildInformationNotice(),

              const SizedBox(height: 24),

              if (_createdAssetId != null) ...[
                _buildRetryNotice(),
                const SizedBox(height: 16),
              ],

              _buildSubmitButton(isSubmitting),

              const SizedBox(height: 14),

              Text(
                'By submitting, you confirm that the information provided is accurate.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // INTRODUCTION
  // =========================

  Widget _buildIntroduction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.add_business_outlined,
            color: Colors.white,
            size: 35,
          ),

          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register Your Asset',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 7),

                Text(
                  'Submit your real-world asset for review and potential tokenization on AssetCoin.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // SECTION HEADING
  // =========================

  Widget _buildSectionHeading(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // =========================
  // ASSET TYPE FIELD
  // =========================

  Widget _buildAssetTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Asset Category', required: true),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          value: _selectedAssetType,
          isExpanded: true,
          decoration: _inputDecoration(
            hint: 'Select asset category',
            icon: Icons.category_outlined,
          ),
          items: _assetTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type['value'],
              child: Text(type['label']!),
            );
          }).toList(),
          onChanged: _createdAssetId != null
              ? null
              : (value) {
                  setState(() {
                    _selectedAssetType = value;
                  });
                },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an asset category.';
            }

            return null;
          },
        ),
      ],
    );
  }

  // =========================
  // TEXT FIELD
  // =========================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, required: required),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          readOnly: _createdAssetId != null,
          decoration: _inputDecoration(
            hint: hint,
            icon: icon,
          ),
        ),
      ],
    );
  }

  // =========================
  // PHOTO PICKER UI
  // =========================

  Widget _buildPhotoPicker() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _fileSectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
                size: 23,
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Asset Photographs',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              Text(
                '${_selectedPhotos.length}/5',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Select up to 5 JPG, JPEG, PNG or WEBP images.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 14),

          OutlinedButton.icon(
            onPressed: _createdAssetId != null ||
                    _isPickingFiles ||
                    _isUploading ||
                    _selectedPhotos.length >= 5
                ? null
                : _pickPhotos,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Choose Photos'),
            style: _outlinedButtonStyle(),
          ),

          if (_selectedPhotos.isNotEmpty) ...[
            const SizedBox(height: 14),

            ...List.generate(
              _selectedPhotos.length,
              (index) {
                final photo = _selectedPhotos[index];

                return _buildSelectedFileTile(
                  icon: Icons.image_outlined,
                  name: photo.name,
                  subtitle: 'Selected photo',
                  onRemove: _createdAssetId == null
                      ? () => _removePhoto(index)
                      : null,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // =========================
  // DOCUMENT PICKER UI
  // =========================

  Widget _buildDocumentPicker() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _fileSectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.picture_as_pdf_outlined,
                color: AppColors.primary,
                size: 23,
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Supporting Documents',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              Text(
                '${_selectedDocuments.length}/5',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'PDF documents only. Select up to 5 files.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 16),

          _fieldLabel('Document Type'),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: _selectedDocumentType,
            isExpanded: true,
            decoration: _inputDecoration(
              hint: 'Select document type',
              icon: Icons.description_outlined,
            ),
            items: _documentTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type['value'],
                child: Text(
                  type['label']!,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: _createdAssetId != null
                ? null
                : (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedDocumentType = value;
                    });
                  },
          ),

          const SizedBox(height: 14),

          OutlinedButton.icon(
            onPressed: _createdAssetId != null ||
                    _isPickingFiles ||
                    _isUploading ||
                    _selectedDocuments.length >= 5
                ? null
                : _pickDocuments,
            icon: const Icon(Icons.attach_file_rounded),
            label: const Text('Choose PDF Documents'),
            style: _outlinedButtonStyle(),
          ),

          if (_selectedDocuments.isNotEmpty) ...[
            const SizedBox(height: 14),

            ...List.generate(
              _selectedDocuments.length,
              (index) {
                final document = _selectedDocuments[index];

                return _buildSelectedFileTile(
                  icon: Icons.picture_as_pdf_outlined,
                  name: document.name,
                  subtitle: 'PDF document',
                  onRemove: _createdAssetId == null
                      ? () => _removeDocument(index)
                      : null,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // =========================
  // SELECTED FILE TILE
  // =========================

  Widget _buildSelectedFileTile({
    required IconData icon,
    required String name,
    required String subtitle,
    VoidCallback? onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 21,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              tooltip: 'Remove file',
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  // =========================
  // FILE SECTION DECORATION
  // =========================

  BoxDecoration _fileSectionDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // =========================
  // OUTLINED BUTTON STYLE
  // =========================

  ButtonStyle _outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: BorderSide(
        color: AppColors.primary.withValues(alpha: 0.35),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
      ),
    );
  }

  // =========================
  // FIELD LABEL
  // =========================

  Widget _fieldLabel(
    String label, {
    bool required = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        if (required) ...[
          const SizedBox(width: 4),

          const Text(
            '*',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  // =========================
  // INPUT DECORATION
  // =========================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 12,
      ),
      prefixIcon: Icon(
        icon,
        color: AppColors.primary,
        size: 20,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  // =========================
  // INFORMATION NOTICE
  // =========================

  Widget _buildInformationNotice() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFD4E3FF),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF2765B0),
            size: 21,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Submitting an asset does not automatically tokenize it. '
              'Your submission will first enter the review process. '
              'You can monitor its status under My Submissions.',
              style: TextStyle(
                color: Color(0xFF315780),
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // RETRY NOTICE
  // =========================

  Widget _buildRetryNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFFFD9A8),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFFB56A13),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Your asset has already been created. '
              'If a file upload failed, you can retry it without '
              'creating another asset submission.',
              style: TextStyle(
                color: Color(0xFF80521E),
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // SUBMIT BUTTON
  // =========================

  Widget _buildSubmitButton(bool isSubmitting) {
    final buttonText = _createdAssetId != null
        ? 'Retry File Upload'
        : 'Submit Asset for Review';

    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submitAsset,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AppColors.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _createdAssetId != null
                        ? Icons.refresh_rounded
                        : Icons.send_rounded,
                    size: 19,
                  ),

                  const SizedBox(width: 9),

                  Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// =========================
// UPPERCASE TEXT FORMATTER
// =========================

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}