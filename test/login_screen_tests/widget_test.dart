import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:internship_management_system/login_screen/login_screen.dart';

void main() {
  group('Login Screen', () {
    testWidgets('renders heading, fields, button, and feature cards', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Login()));

      expect(find.text('internship management system'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('A system that allows you to:'), findsOneWidget);
      expect(find.text('Curated opportunities'), findsOneWidget);
      expect(find.text('Easy communication'), findsOneWidget);
      expect(find.text('Progress tracking'), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
    });

    testWidgets('shows email validation error when empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Login()));

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows email validation error for invalid format', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Login()));

      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows password validation error when empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Login()));

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@email.com',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Login()));

      final toggleButton = find.byIcon(Icons.visibility_off_outlined);
      expect(toggleButton, findsOneWidget);

      await tester.tap(toggleButton);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('passes validation with valid inputs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Login()));

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@email.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter a valid email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
    });
  });
}
