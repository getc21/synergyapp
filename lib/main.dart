import 'package:bellezapp/controllers/indexpage_controller.dart';
import 'package:bellezapp/controllers/loading_controller.dart';
import 'package:bellezapp/controllers/store_controller.dart';
import 'package:bellezapp/controllers/theme_controller.dart';
import 'package:bellezapp/controllers/cash_controller.dart';
import 'package:bellezapp/controllers/auth_controller.dart';
import 'package:bellezapp/controllers/expense_controller.dart';
import 'package:bellezapp/controllers/brand_controller.dart';
import 'package:bellezapp/pages/home_page.dart';
import 'package:bellezapp/pages/login_page.dart';
import 'package:bellezapp/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar controladores en el orden correcto
  // AuthController debe ir primero porque otros controladores lo necesitan
  Get.put(AuthController());
  Get.put(StoreController());
  Get.put(ThemeController());
  Get.put(IndexPageController());
  Get.put(LoadingController());
  Get.put(CashController());
  Get.put(ExpenseController());
  Get.lazyPut(() => BrandController());
  
  runApp(const BeautyStoreApp());
}

class BeautyStoreApp extends StatefulWidget {
  const BeautyStoreApp({super.key});

  @override
  State<BeautyStoreApp> createState() => BeautyStoreAppState();
}

class BeautyStoreAppState extends State<BeautyStoreApp> {
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SynergyApp',
        
        // Configuración de temas dinámicos
        theme: themeController.isInitialized 
          ? themeController.currentTheme.lightTheme 
          : ThemeData.light(),
        darkTheme: themeController.isInitialized 
          ? themeController.currentTheme.darkTheme 
          : ThemeData.dark(),
        themeMode: themeController.isInitialized 
          ? themeController.themeMode 
          : ThemeMode.light,
        
        home: const AuthInitializer(),
          
        locale: const Locale('es', 'ES'),
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[
          Locale('en', ''),
          Locale('es', ''),
        ],
      );
    });
  }
}

/// 🔐 Auth Initializer - Verifica si el usuario está autenticado
class AuthInitializer extends StatelessWidget {
  const AuthInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {   
      // Mostrar splash mientras carga
      if (!themeController.isInitialized || authController.isLoading) {
        return const SplashScreen();
      }

      // Si está autenticado, mostrar home
      if (authController.isLoggedIn) {
        return const HomePage();
      } else {
        return const LoginPage();
      }
    });
  }
}
