import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yalla_ride_app/main.dart';

void main() {
  testWidgets('Yalla Ride app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const YallaRideApp());

    // Verify that the app starts properly
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

