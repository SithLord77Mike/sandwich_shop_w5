import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/main.dart';
import 'package:sandwich_shop/views/profile_screen.dart';

void main() {
  testWidgets('Profile screen shows fields and save button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    expect(find.byKey(const Key('profile_name')), findsOneWidget);
    expect(find.byKey(const Key('profile_email')), findsOneWidget);
    expect(find.byKey(const Key('profile_favourite')), findsOneWidget);
    expect(find.byKey(const Key('profile_save_button')), findsOneWidget);
  });

  testWidgets('Saving with empty name/email shows error snackbar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    await tester.tap(find.byKey(const Key('profile_save_button')));
    await tester.pump(); // show snackbar

    expect(find.text('Please enter both name and email'), findsOneWidget);
  });

  testWidgets('Saving with valid name/email shows success snackbar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    await tester.enterText(find.byKey(const Key('profile_name')), 'Mike Test');
    await tester.enterText(
        find.byKey(const Key('profile_email')), 'mike@example.com');
    await tester.enterText(
        find.byKey(const Key('profile_favourite')), 'Veggie Delight');

    await tester.tap(find.byKey(const Key('profile_save_button')));
    await tester.pump(); // show snackbar

    expect(find.textContaining('Profile saved'), findsOneWidget);
  });

  testWidgets('Drawer opens and navigates to Profile via menu',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Open drawer via the default hamburger icon
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    // Tap the Profile ListTile inside the Drawer
    final profileTile = find.widgetWithText(ListTile, 'Profile');
    expect(profileTile, findsOneWidget);

    await tester.tap(profileTile);
    await tester.pumpAndSettle();

    // We should now be on ProfileScreen
    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
