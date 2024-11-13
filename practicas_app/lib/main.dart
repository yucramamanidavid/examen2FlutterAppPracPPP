import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa Firebase
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart'; // Importar la pantalla de perfil
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
  await Firebase.initializeApp(); // Inicializa Firebase

  final userProvider = UserProvider();
  await userProvider.loadUser(); // Cargar el token antes de iniciar la app

  runApp(MyApp(userProvider: userProvider));
}

class MyApp extends StatelessWidget {
  final UserProvider userProvider;

  MyApp({required this.userProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => userProvider),
      ],
      child: MaterialApp(
        title: 'Prácticas Preprofesionales',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // Verifica si el usuario ya está autenticado para definir la ruta inicial
        initialRoute: userProvider.isAuthenticated ? '/' : '/login',
        routes: {
          '/': (context) => HomeScreen(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/profile': (context) => ProfileScreen(), // Ruta para la pantalla de perfil
        },
      ),
    );
  }
}
