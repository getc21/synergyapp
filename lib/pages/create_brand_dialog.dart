import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../controllers/brand_controller.dart';
import '../utils/utils.dart';

/// Diálogo para crear o editar una marca.
/// En modo creación, también solicita datos del admin de la marca.
class CreateBrandDialog extends StatefulWidget {
  final Map<String, dynamic>? existingBrand;

  const CreateBrandDialog({super.key, this.existingBrand});

  @override
  State<CreateBrandDialog> createState() => _CreateBrandDialogState();
}

class _CreateBrandDialogState extends State<CreateBrandDialog> {
  final _formKey = GlobalKey<FormState>();
  final brandController = Get.find<BrandController>();

  bool get isEditing => widget.existingBrand != null;

  // Brand fields
  late final TextEditingController _nameController;
  late final TextEditingController _slugController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _maxStoresController;
  File? _logoFile;

  // Admin fields (solo en creación)
  final _adminFirstNameController = TextEditingController();
  final _adminLastNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  bool _obscurePassword = true;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final brand = widget.existingBrand;
    _nameController = TextEditingController(text: brand?['name'] ?? '');
    _slugController = TextEditingController(text: brand?['slug'] ?? '');
    _emailController = TextEditingController(text: brand?['contactEmail'] ?? '');
    _phoneController = TextEditingController(text: brand?['phone'] ?? '');
    _addressController = TextEditingController(text: brand?['address'] ?? '');
    _maxStoresController =
        TextEditingController(text: '${brand?['maxStores'] ?? 3}');
    // Auto-generar slug a partir del nombre
    _nameController.addListener(_autoGenerateSlug);
  }

  void _autoGenerateSlug() {
    if (!isEditing) {
      final slug = _nameController.text
          .toLowerCase()
          .trim()
          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '-');
      _slugController.text = slug;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _maxStoresController.dispose();
    _adminFirstNameController.dispose();
    _adminLastNameController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _logoFile = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      if (isEditing) {
        // Actualizar marca
        final data = <String, dynamic>{
          'name': _nameController.text.trim(),
          'contactEmail': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'maxStores': int.tryParse(_maxStoresController.text) ?? 3,
        };

        final success = await brandController.updateBrand(
          id: widget.existingBrand!['_id'],
          data: data,
          logoFile: _logoFile,
        );

        if (success && mounted) Navigator.pop(context);
      } else {
        // Crear marca + admin
        final brandData = <String, dynamic>{
          'name': _nameController.text.trim(),
          'slug': _slugController.text.trim(),
          'contactEmail': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'maxStores': int.tryParse(_maxStoresController.text) ?? 3,
        };

        final adminData = <String, dynamic>{
          'firstName': _adminFirstNameController.text.trim(),
          'lastName': _adminLastNameController.text.trim(),
          'email': _adminEmailController.text.trim(),
          'username': _adminEmailController.text.trim().split('@').first,
          'password': _adminPasswordController.text,
        };

        final success = await brandController.createBrand(
          brandData: brandData,
          adminData: adminData,
          logoFile: _logoFile,
        );

        if (success && mounted) Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Utils.colorFondoCards,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Utils.colorBotones, Utils.colorGnav],
                ),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_outlined : Icons.add_business,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Editar Marca' : 'Nueva Marca',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo picker
                      Center(child: _buildLogoPicker()),
                      const SizedBox(height: 20),

                      // ── Sección: Datos de la Marca ──
                      _buildSectionTitle('Datos de la Marca'),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _nameController,
                        label: 'Nombre de la Marca *',
                        icon: Icons.business,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email de Contacto *',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Requerido';
                          if (!GetUtils.isEmail(v.trim())) {
                            return 'Email no válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _phoneController,
                        label: 'Teléfono',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _addressController,
                        label: 'Dirección',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _maxStoresController,
                        label: 'Límite de Sucursales *',
                        icon: Icons.store,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Requerido';
                          }
                          final n = int.tryParse(v);
                          if (n == null || n < 1) return 'Mín. 1';
                          return null;
                        },
                      ),

                      // ── Sección: Admin de la Marca (solo en creación) ──
                      if (!isEditing) ...[
                        const SizedBox(height: 24),
                        _buildSectionTitle('Administrador de la Marca'),
                        const SizedBox(height: 4),
                        Text(
                          'Se creará un usuario admin para gestionar esta marca',
                          style: TextStyle(
                            fontSize: 12,
                            color: Utils.colorTexto.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _adminFirstNameController,
                                label: 'Nombre *',
                                icon: Icons.person_outline,
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Requerido'
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _adminLastNameController,
                                label: 'Apellido *',
                                icon: Icons.person_outline,
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Requerido'
                                        : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _buildTextField(
                          controller: _adminEmailController,
                          label: 'Email del Admin *',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Requerido';
                            if (!GetUtils.isEmail(v.trim())) {
                              return 'Email no válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _adminPasswordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña *',
                            prefixIcon:
                                Icon(Icons.lock_outline, color: Utils.colorBotones),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Utils.colorBotones,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: Utils.colorFondo.withValues(alpha: 0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requerido';
                            if (v.length < 6) return 'Mínimo 6 caracteres';
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Footer con botones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Utils.colorGnav.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Utils.colorBotones,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing ? 'Guardar Cambios' : 'Crear Marca',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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

  Widget _buildLogoPicker() {
    return GestureDetector(
      onTap: _pickLogo,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Utils.colorFondo.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Utils.colorBotones.withValues(alpha: 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: _logoFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(_logoFile!, fit: BoxFit.cover),
              )
            : widget.existingBrand?['logo'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      _getLogoUrl(widget.existingBrand!['logo']),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildLogoPlaceholder(),
                    ),
                  )
                : _buildLogoPlaceholder(),
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, color: Utils.colorBotones, size: 28),
        const SizedBox(height: 4),
        Text(
          'Logo',
          style: TextStyle(
            fontSize: 11,
            color: Utils.colorBotones,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getLogoUrl(String logo) {
    if (logo.startsWith('http')) return logo;
    return '${ApiConfig.baseUrl.replaceAll('/api', '')}$logo';
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Utils.colorBotones,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Utils.colorBotones),
        filled: true,
        fillColor: readOnly
            ? Utils.colorFondo.withValues(alpha: 0.5)
            : Utils.colorFondo.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }
}
