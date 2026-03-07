import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/brand_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/brand.dart';
import '../utils/utils.dart';
import '../config/api_config.dart';
import 'create_brand_dialog.dart';

/// Página de gestión de marcas — solo visible para superadmin.
/// Permite listar, buscar, crear, editar y desactivar marcas.
class BrandsPage extends StatefulWidget {
  const BrandsPage({super.key});

  @override
  State<BrandsPage> createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage> {
  final brandController = Get.find<BrandController>();
  final authController = Get.find<AuthController>();
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      brandController.loadBrands();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Marcas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Utils.colorBotones, Utils.colorGnav],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Obx(() => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.branding_watermark, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${brandController.filteredBrands.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => brandController.refreshBrands(),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Utils.colorFondo.withValues(alpha: 0.3),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Barra de búsqueda
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                onChanged: (value) => brandController.searchBrands(value),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, slug o email...',
                  prefixIcon: Icon(Icons.search, color: Utils.colorBotones),
                  suffixIcon: Obx(() => brandController.filteredBrands.length != brandController.brands.length
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Utils.colorBotones),
                          onPressed: () {
                            searchController.clear();
                            brandController.clearSearch();
                          },
                        )
                      : const SizedBox.shrink()),
                  filled: true,
                  fillColor: Utils.colorFondoCards,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            // Lista de marcas
            Expanded(
              child: Obx(() {
                if (brandController.isLoading) {
                  return Center(child: Utils.loadingCustom());
                }

                if (brandController.filteredBrands.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async => await brandController.refreshBrands(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: brandController.filteredBrands.length,
                    itemBuilder: (context, index) {
                      final brandMap = brandController.filteredBrands[index];
                      final brand = Brand.fromMap(brandMap);
                      return _buildBrandCard(context, brand, brandMap);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBrandDialog(context),
        backgroundColor: Utils.colorBotones,
        icon: const Icon(Icons.add_business, color: Colors.white),
        label: const Text(
          'Nueva Marca',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.branding_watermark_outlined,
            size: 80,
            color: Utils.colorBotones.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay marcas registradas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Utils.colorTexto,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera marca para comenzar',
            style: TextStyle(
              fontSize: 14,
              color: Utils.colorTexto.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCard(
      BuildContext context, Brand brand, Map<String, dynamic> brandMap) {
    final isActive = brand.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Utils.colorFondoCards,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? Utils.colorBotones.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header con logo y nombre
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Logo
                _buildBrandLogo(brand),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              brand.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Utils.colorTexto,
                              ),
                            ),
                          ),
                          _buildStatusBadge(isActive),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${brand.slug}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Utils.colorTexto.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Detalles
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildInfoRow(Icons.email_outlined, brand.contactEmail),
                if (brand.phone != null && brand.phone!.isNotEmpty)
                  _buildInfoRow(Icons.phone_outlined, brand.phone!),
                if (brand.address != null && brand.address!.isNotEmpty)
                  _buildInfoRow(Icons.location_on_outlined, brand.address!),
                _buildInfoRow(Icons.store_outlined,
                    'Máx. ${brand.maxStores} tiendas'),
                _buildInfoRow(
                    Icons.card_membership_outlined, 'Plan: ${brand.planDisplay}'),
              ],
            ),
          ),

          // Acciones
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Utils.colorGnav.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Estadísticas
                TextButton.icon(
                  icon: Icon(Icons.bar_chart, size: 18, color: Utils.colorBotones),
                  label: Text('Stats', style: TextStyle(color: Utils.colorBotones)),
                  onPressed: () => _showBrandStats(context, brand.id!),
                ),
                const SizedBox(width: 8),
                // Editar
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  label: const Text('Editar', style: TextStyle(color: Colors.blue)),
                  onPressed: () => _showEditBrandDialog(context, brandMap),
                ),
                const SizedBox(width: 8),
                // Desactivar (solo si está activa)
                if (isActive)
                  TextButton.icon(
                    icon: const Icon(Icons.block, size: 18, color: Colors.red),
                    label: const Text('Desactivar',
                        style: TextStyle(color: Colors.red)),
                    onPressed: () => _confirmDeactivate(context, brand),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLogo(Brand brand) {
    if (brand.logo != null && brand.logo!.isNotEmpty) {
      final logoUrl = brand.logo!.startsWith('http')
          ? brand.logo!
          : '${ApiConfig.baseUrl.replaceAll('/api', '')}${brand.logo}';
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          logoUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultLogo(brand),
        ),
      );
    }
    return _buildDefaultLogo(brand);
  }

  Widget _buildDefaultLogo(Brand brand) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Utils.colorBotones.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          brand.name.isNotEmpty ? brand.name[0].toUpperCase() : 'B',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Utils.colorBotones,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        isActive ? 'Activa' : 'Inactiva',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Utils.colorTexto.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Utils.colorTexto.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateBrandDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CreateBrandDialog(),
    );
  }

  void _showEditBrandDialog(
      BuildContext context, Map<String, dynamic> brandMap) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreateBrandDialog(existingBrand: brandMap),
    );
  }

  void _showBrandStats(BuildContext context, String brandId) async {
    await brandController.loadBrandStats(brandId);
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => Obx(() {
        final stats = brandController.brandStats;
        if (stats == null) {
          return AlertDialog(
            content: Center(child: Utils.loadingCustom()),
          );
        }

        final brandInfo = stats['brand'] ?? {};
        final statsData = stats['stats'] ?? {};

        return AlertDialog(
          backgroundColor: Utils.colorFondoCards,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.bar_chart, color: Utils.colorBotones),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Stats: ${brandInfo['name'] ?? 'Marca'}',
                  style: TextStyle(
                    color: Utils.colorTexto,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatTile(
                  Icons.store, 'Tiendas', '${statsData['stores'] ?? 0}'),
              _buildStatTile(Icons.people, 'Usuarios totales',
                  '${statsData['totalUsers'] ?? 0}'),
              _buildStatTile(Icons.verified_user, 'Usuarios activos',
                  '${statsData['activeUsers'] ?? 0}'),
              _buildStatTile(Icons.card_membership, 'Plan',
                  '${brandInfo['plan'] ?? 'basic'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar', style: TextStyle(color: Utils.colorBotones)),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Utils.colorBotones),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(color: Utils.colorTexto, fontSize: 14)),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Utils.colorBotones,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, Brand brand) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Utils.colorFondoCards,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_outlined, color: Colors.red),
            const SizedBox(width: 8),
            const Expanded(child: Text('Desactivar Marca')),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas desactivar "${brand.name}"?\n\n'
          'Esto desactivará también todos los usuarios de esta marca.',
          style: TextStyle(color: Utils.colorTexto),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await brandController.deleteBrand(brand.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Desactivar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
