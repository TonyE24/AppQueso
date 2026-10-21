import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_queso/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Carga la aplicación Venta de Lácteos correctamente', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const DairySalesApp());
    await tester.pump(const Duration(seconds: 1));

    // Verify main components are present
    expect(find.text('Quesitos Kenia'), findsOneWidget);
    expect(find.text('CLIENTES'), findsOneWidget);
    expect(find.text('VENDEDORES'), findsOneWidget);
    expect(find.text('Queso Pequeño'), findsOneWidget);
  });
}
