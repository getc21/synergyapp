import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../providers/supplier_provider.dart';
import 'auth_controller.dart';
import 'store_controller.dart';

class SupplierController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  
  // ⭐ MULTI-TENANT: necesitamos acceso al StoreController para el contexto de tienda/brand
  StoreController get _storeController => Get.find<StoreController>();
  
  SupplierProvider get _supplierProvider => SupplierProvider(_authController.token);

  // Estados observables
  final RxList<Map<String, dynamic>> _suppliers = <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  List<Map<String, dynamic>> get suppliers => _suppliers;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    loadSuppliers();
  }

  // ⭐ MULTI-TENANT: Método para refrescar cuando cambie la tienda
  Future<void> refreshForStore() async {
    await loadSuppliers();
  }

  // Cargar proveedores
  Future<void> loadSuppliers() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      // ⭐ MULTI-TENANT: pasar storeId para filtrado contextual
      final result = await _supplierProvider.getSuppliers(
        storeId: _storeController.currentStoreId,
      );

      if (result['success']) {
        _suppliers.value = List<Map<String, dynamic>>.from(result['data']);
      } else {
        _errorMessage.value = result['message'] ?? 'Error cargando proveedores';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _errorMessage.value = 'Error de conexión: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Obtener proveedor por ID
  Future<Map<String, dynamic>?> getSupplierById(String id) async {
    _isLoading.value = true;

    try {
      final result = await _supplierProvider.getSupplierById(id);

      if (result['success']) {
        return result['data'];
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Error obteniendo proveedor',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error de conexión: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // Crear proveedor
  Future<bool> createSupplier({
    required String name,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? address,
    File? imageFile,
  }) async {
    _isLoading.value = true;

    try {
      final result = await _supplierProvider.createSupplier(
        name: name,
        contactName: contactName,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        address: address,
        imageFile: imageFile,
        brandId: _authController.brandId, // ⭐ MULTI-TENANT
      );

      if (result['success']) {
        // No mostrar snackbar aquí, se manejará en la página
        await loadSuppliers();
        return true;
      } else {
        // No mostrar snackbar aquí, se manejará en la página si es necesario
        return false;
      }
    } catch (e) {
      // No mostrar snackbar aquí, se manejará en la página si es necesario
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Actualizar proveedor
  Future<bool> updateSupplier({
    required String id,
    String? name,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? address,
    File? imageFile,
  }) async {
    _isLoading.value = true;

    try {
      final result = await _supplierProvider.updateSupplier(
        id: id,
        name: name,
        contactName: contactName,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        address: address,
        imageFile: imageFile,
      );

      if (result['success']) {
        // No mostrar snackbar aquí, se manejará en la página
        await loadSuppliers();
        return true;
      } else {
        // No mostrar snackbar aquí, se manejará en la página si es necesario
        return false;
      }
    } catch (e) {
      // No mostrar snackbar aquí, se manejará en la página si es necesario
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Eliminar proveedor
  Future<bool> deleteSupplier(String id) async {
    _isLoading.value = true;

    try {
      final result = await _supplierProvider.deleteSupplier(id);

      if (result['success']) {
        // No mostrar snackbar aquí, se manejará en la página
        _suppliers.removeWhere((s) => s['_id'] == id);
        return true;
      } else {
        // No mostrar snackbar aquí, se manejará en la página si es necesario
        return false;
      }
    } catch (e) {
      // No mostrar snackbar aquí, se manejará en la página si es necesario
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Limpiar mensaje de error
  void clearError() {
    _errorMessage.value = '';
  }
}
