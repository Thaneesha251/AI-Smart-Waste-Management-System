import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:swachhai/app.dart';
import 'package:swachhai/providers/auth_provider.dart';
import 'package:swachhai/providers/complaint_provider.dart';
import 'package:swachhai/providers/worker_provider.dart';

void main() {
  testWidgets('App title smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame with providers setup.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ComplaintProvider()),
          ChangeNotifierProvider(create: (_) => WorkerProvider()),
        ],
        child: const SwachhAIApp(),
      ),
    );

    // Verify that the app compiles and is present.
    expect(find.byType(SwachhAIApp), findsOneWidget);

    // Settle the splash navigation timer
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
