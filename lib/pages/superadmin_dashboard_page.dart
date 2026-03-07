import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/brand_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/utils.dart';
import 'brands_page.dart';

/// Dashboard principal para el SuperAdmin.
/// Muestra resumen de marcas, accesos rápidos y estadísticas globales.
class SuperAdminDashboardPage extends StatelessWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final brandController = Get.find<BrandController>();
    final authController = Get.find<AuthController>();

    return RefreshIndicator(
      onRefresh: () => brandController.refreshBrands(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de bienvenida
            _buildWelcomeCard(authController),
            const SizedBox(height: 20),

            // Estadísticas rápidas
            _buildStatsSection(brandController),
            const SizedBox(height: 20),

            // Acciones rápidas
            _buildQuickActions(context),
            const SizedBox(height: 20),

            // Lista de marcas recientes
            _buildRecentBrands(brandController),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AuthController authController) {
    final user = authController.currentUser;
    final name = user?['firstName'] ?? 'Super Admin';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4F46E5),
            Color(0xFF8B5CF6),
            Color(0xFFDB2777),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, $name!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Super Administrador',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Gestiona todas las marcas y usuarios del sistema desde aquí.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BrandController brandController) {
    return Obx(() {
      final brands = brandController.brands;
      final active = brands.where((b) => b['isActive'] == true).length;
      final inactive = brands.length - active;

      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Marcas',
              '${brands.length}',
              Icons.business,
              const Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Activas',
              '$active',
              Icons.check_circle_outline,
              const Color(0xFF059669),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Inactivas',
              '$inactive',
              Icons.pause_circle_outline,
              const Color(0xFFEF4444),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Utils.colorFondoCards,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Utils.colorTexto.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Utils.colorTexto,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Gestionar\nMarcas',
                Icons.branding_watermark_outlined,
                const Color(0xFF4F46E5),
                () => Get.to(() => const BrandsPage()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Nueva\nMarca',
                Icons.add_business,
                const Color(0xFFDB2777),
                () {
                  Get.to(() => const BrandsPage());
                  // El FAB de BrandsPage permite crear
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Utils.colorFondoCards,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Utils.colorTexto,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBrands(BrandController brandController) {
    return Obx(() {
      final brands = brandController.brands;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Marcas Registradas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Utils.colorTexto,
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => const BrandsPage()),
                child: Text(
                  'Ver todas',
                  style: TextStyle(color: Utils.colorBotones),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (brandController.isLoading)
            Center(child: Utils.loadingCustom(60))
          else if (brands.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Utils.colorFondoCards,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 48,
                    color: Utils.colorTexto.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No hay marcas registradas',
                    style: TextStyle(
                      color: Utils.colorTexto.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primera marca desde "Gestionar Marcas"',
                    style: TextStyle(
                      color: Utils.colorTexto.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...brands.take(5).map((brand) => _buildBrandTile(brand)),
        ],
      );
    });
  }

  Widget _buildBrandTile(Map<String, dynamic> brand) {
    final isActive = brand['isActive'] == true;
    final initial = (brand['name'] ?? 'M')[0].toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Utils.colorFondoCards,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? const Color(0xFF059669).withValues(alpha: 0.2)
              : const Color(0xFFEF4444).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Avatar/Logo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4F46E5).withValues(alpha: 0.8),
                  const Color(0xFF8B5CF6),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand['name'] ?? 'Sin nombre',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Utils.colorTexto,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  brand['slug'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Utils.colorTexto.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF059669).withValues(alpha: 0.1)
                  : const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isActive ? 'Activa' : 'Inactiva',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? const Color(0xFF059669)
                    : const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
