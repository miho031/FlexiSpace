import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/room.dart';
import '../../../core/theme/app_theme.dart';
import '../../spaces/application/spaces_providers.dart';
import '../application/admin_providers.dart';

/// Ekran za dodavanje ili uređivanje prostorije.
class AdminSpaceFormScreen extends ConsumerStatefulWidget {
  const AdminSpaceFormScreen({super.key, this.room});

  final Room? room;

  bool get isEditing => room != null;

  @override
  ConsumerState<AdminSpaceFormScreen> createState() => _AdminSpaceFormScreenState();
}

class _AdminSpaceFormScreenState extends ConsumerState<AdminSpaceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _priceController;
  late final TextEditingController _capacityController;
  late final TextEditingController _imageUrlController;
  bool _hasWifi = false;
  bool _hasWater = false;
  String _type = 'meeting_room';
  bool _isLoading = false;

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
      text: r?.pricePerMinute.toStringAsFixed(2) ?? '0.00',
    );
    _capacityController = TextEditingController(text: r?.capacity.toString() ?? '1');
    _imageUrlController = TextEditingController(text: r?.imagePath ?? '');
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
                  child: Form(
                    key: _formKey,
                    child: _buildFormCard(),
                  ),
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
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Naziv je obavezan' : null,
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
                    .map((e) => DropdownMenuItem(
                          value: e['value'],
                          child: Text(e['label']!),
                        ))
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
                    _buildLabel('Cijena (€/min)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: AppTheme.inputDecoration('0.08'),
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
          _buildLabel('URL slike (opcionalno)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _imageUrlController,
            keyboardType: TextInputType.url,
            decoration: AppTheme.inputDecoration('https://...'),
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
                  : Text(widget.isEditing ? 'Spremi promjene' : 'Dodaj prostoriju'),
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
      color: value ? AppTheme.primaryYellow.withValues(alpha: 0.3) : Colors.grey.shade200,
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

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0;
    final capacity = int.tryParse(_capacityController.text) ?? 1;
    final imageUrl = _imageUrlController.text.trim();

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      if (widget.isEditing) {
        await repo.updateSpace(
          widget.room!.id,
          name: name,
          address: address,
          pricePerMinute: price,
          capacity: capacity,
          hasWifi: _hasWifi,
          hasWater: _hasWater,
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
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
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
          type: _type,
        );
      }
      ref.invalidate(adminSpacesProvider);
      ref.invalidate(roomsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing ? 'Prostorija ažurirana' : 'Prostorija dodana'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
