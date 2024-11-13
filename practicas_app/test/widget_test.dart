import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practicas_app/main.dart';
import 'package:practicas_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Crear una instancia de UserProvider
    final userProvider = UserProvider();

    // Cargar datos de usuario si es necesario
    await userProvider.loadUser();

    // Construir la app y pasar userProvider como parámetro
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ],
        child: MyApp(userProvider: userProvider),
      ),
    );

    // Verificar que el contador empieza en 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tocar el icono '+' y activar un frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verificar que el contador ha incrementado.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
