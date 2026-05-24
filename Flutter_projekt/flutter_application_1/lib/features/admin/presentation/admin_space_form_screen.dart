import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/room.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_messages.dart';
import '../../spaces/application/spaces_providers.dart';
import '../application/admin_providers.dart';

/// Ekran za dodavanje ili uređivanje prostorije.
class AdminSpaceFormScreen extends ConsumerStatefulWidget {
  const AdminSpaceFormScreen({super.key, this.room});

  final Room? room;

  bool get isEditing => room != null;

  @override
  ConsumerState<AdminSpaceFormScreen> createState() =>
      _AdminSpaceFormScreenState();
}

class _AdminSpaceFormScreenState extends ConsumerState<AdminSpaceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _priceController;
  late final TextEditingController _capacityController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _wifiPasswordController;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _hasWifi = false;
  bool _hasWater = false;
  String _type = 'meeting_room';
  bool _isLoading = false;
  bool _isPickingImage = false;

  static const List<Map<String, String>> _typeOptions = [
    {'value': 'meeting_room', 'label': 'Sala za sastanke'},
    {'value': 'office', 'label': 'Ured'},
    {'value': 'desk', 'label': 'Radni stol'},
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.room;
    _nameController = TextEditingController(text: r?.name ?? '');
    _addressController = TextEditingController(text: r?.address ?? '');
    _priceController = TextEditingController(
      text: r?.pricePerHour.toStringAsFixed(2) ?? '0.00',
    );
    _capacityController = TextEditingController(
      text: r?.capacity.toString() ?? '1',
    );
    _imageUrlController = TextEditingController(text: r?.imagePath ?? '');
    _wifiPasswordController = TextEditingController(
      text: r?.wifiPassword ?? '',
    );
    _hasWifi = r?.hasWifi ?? false;
    _hasWater = r?.hasWater ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _imageUrlController.dispose();
    _wifiPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(key: _formKey, child: _buildFormCard()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          Expanded(
            child: Text(
              widget.isEditing ? 'Uredi prostoriju' : 'Nova prostorija',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel('Naziv prostorije'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: AppTheme.inputDecoration('npr. Orlando sala'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Naziv je obavezan' : null,
          ),
          const SizedBox(height: 20),
          _buildLabel('Adresa'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _addressController,
            decoration: AppTheme.inputDecoration('npr. Ul. od Puča 12'),
          ),
          const SizedBox(height: 20),
          _buildLabel('Tip prostorije'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _type,
                isExpanded: true,
                items: _typeOptions
                    .map(
                      (e) => DropdownMenuItem(
                        value: e['value'],
                        child: Text(e['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? 'meeting_room'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Cijena (€/h)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: AppTheme.inputDecoration('4.80'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        final n = double.tryParse(v.replaceAll(',', '.'));
                        if (n == null || n < 0) return 'Unesite valjanu cijenu';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Kapacitet'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      decoration: AppTheme.inputDecoration('30'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        final n = int.tryParse(v);
                        if (n == null || n < 1) return 'Min. 1';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLabel('Slika prostorije (opcionalno)'),
          const SizedBox(height: 8),
          _buildImagePicker(),
          const SizedBox(height: 12),
          TextFormField(
            controller: _imageUrlController,
            keyboardType: TextInputType.url,
            decoration: AppTheme.inputDecoration(
              'URL ili putanja u bucketu spaces',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          _buildLabel('Sadržaji'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAmenityChip(
                  icon: Icons.wifi,
                  label: 'Wi-Fi',
                  value: _hasWifi,
                  onTap: () => setState(() => _hasWifi = !_hasWifi),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmenityChip(
                  icon: Icons.videocam,
                  label: 'Projektor',
                  value: _hasWater,
                  onTap: () => setState(() => _hasWater = !_hasWater),
                ),
              ),
            ],
          ),
          if (_hasWifi) ...[
            const SizedBox(height: 16),
            _buildLabel('Wi-Fi sifra'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _wifiPasswordController,
              decoration: AppTheme.inputDecoration('npr. FlexiSpace-2026'),
              textInputAction: TextInputAction.next,
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: AppTheme.yellowButton,
              onPressed: _isLoading ? null : _onSave,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.isEditing ? 'Spremi promjene' : 'Dodaj prostoriju',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildAmenityChip({
    required IconData icon,
    required String label,
    required bool value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: value
          ? AppTheme.primaryYellow.withValues(alpha: 0.3)
          : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: value ? Colors.black87 : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: value ? Colors.black87 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final imageValue = _imageUrlController.text.trim();
    final previewImageUrl = _resolvePreviewImageUrl(imageValue);
    final hasExistingImage = previewImageUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 180,
            color: Colors.grey.shade200,
            child: _selectedImageBytes != null
                ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                : hasExistingImage
                ? Image.network(
                    previewImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading || _isPickingImage ? null : _pickImage,
                icon: _isPickingImage
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.image_outlined),
                label: Text(
                  _selectedImageName == null
                      ? 'Odaberi sliku'
                      : 'Promijeni sliku',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (_selectedImageBytes != null || hasExistingImage) ...[
              const SizedBox(width: 12),
              IconButton.filledTonal(
                tooltip: 'Ukloni sliku',
                onPressed: _isLoading ? null : _clearImage,
                icon: const Icon(Icons.close),
              ),
            ],
          ],
        ),
        if (_selectedImageName != null) ...[
          const SizedBox(height: 8),
          Text(
            _selectedImageName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.meeting_room_outlined,
        size: 48,
        color: Colors.grey.shade600,
      ),
    );
  }

  Future<void> _pickImage() async {
    setState(() => _isPickingImage = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      final file = result?.files.single;
      final bytes = file?.bytes;
      if (file == null || bytes == null) return;

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = file.name;
      });
    } catch (e) {
      if (mounted) {
        AppSnackBars.showError(
          context,
          e,
          fallback: 'Slika nije odabrana. Pokusajte ponovno.',
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
      _imageUrlController.clear();
    });
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final hourlyPrice =
        double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0;
    final price = hourlyPrice / 60;
    final capacity = int.tryParse(_capacityController.text) ?? 1;
    final imageUrl = _imageUrlController.text.trim();
    final wifiPassword = _hasWifi ? _wifiPasswordController.text.trim() : '';

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final uploadedImagePath = await _uploadSelectedImage(name);
      final savedImageUrl = uploadedImagePath ?? imageUrl;
      if (widget.isEditing) {
        await repo.updateSpace(
          widget.room!.id,
          name: name,
          address: address,
          pricePerMinute: price,
          capacity: capacity,
          hasWifi: _hasWifi,
          hasWater: _hasWater,
          imageUrl: savedImageUrl,
          wifiPassword: wifiPassword,
          type: _type,
        );
      } else {
        await repo.createSpace(
          name: name,
          address: address,
          pricePerMinute: price,
          capacity: capacity,
          hasWifi: _hasWifi,
          hasWater: _hasWater,
          imageUrl: savedImageUrl.isEmpty ? null : savedImageUrl,
          wifiPassword: wifiPassword.isEmpty ? null : wifiPassword,
          type: _type,
        );
      }
      ref.invalidate(adminSpacesProvider);
      ref.invalidate(roomsProvider);
      if (mounted) {
        AppSnackBars.showSuccess(
          context,
          widget.isEditing
              ? 'Prostorija je azurirana.'
              : 'Prostorija je dodana.',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBars.showError(
          context,
          e,
          fallback:
              'Prostorija nije spremljena. Provjerite podatke i pokusajte ponovno.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _resolvePreviewImageUrl(String value) {
    if (value.isEmpty) return '';

    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme && uri.hasAuthority) {
      return value;
    }

    var objectPath = value.replaceAll('\\', '/');
    while (objectPath.startsWith('/')) {
      objectPath = objectPath.substring(1);
    }

    const bucketName = 'spaces';
    if (objectPath.startsWith('$bucketName/')) {
      objectPath = objectPath.substring(bucketName.length + 1);
    }

    if (objectPath.isEmpty) return '';
    return Supabase.instance.client.storage
        .from(bucketName)
        .getPublicUrl(objectPath);
  }

  Future<String?> _uploadSelectedImage(String roomName) async {
    final bytes = _selectedImageBytes;
    final fileName = _selectedImageName;
    if (bytes == null || fileName == null) return null;

    final extension = fileName.split('.').last.toLowerCase();
    final safeExtension = extension.isEmpty || extension.length > 5
        ? 'jpg'
        : extension;
    final safeRoomName = roomName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final objectPath =
        'admin/${safeRoomName.isEmpty ? 'space' : safeRoomName}-$timestamp.$safeExtension';

    final contentType = switch (safeExtension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };

    await Supabase.instance.client.storage
        .from('spaces')
        .uploadBinary(
          objectPath,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );

    return objectPath;
  }
}
