import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trypx/core/design_system/trypx_colors.dart';
import 'package:trypx/core/design_system/trypx_spacing.dart';
import 'package:trypx/core/design_system/widgets/trypx_primary_button.dart';
import 'package:trypx/core/design_system/widgets/trypx_card.dart';

void main() {
  group('TrypXColors', () {
    test('primaryOrange and surfaceNavy hex values', () {
      expect(TrypXColors.primaryOrange, const Color(0xFFFF5E00));
      expect(TrypXColors.surfaceNavy, const Color(0xFF0A1128));
    });
  });

  group('TrypXSpacing', () {
    test('base and screenHorizontal values', () {
      expect(TrypXSpacing.base, 16);
      expect(TrypXSpacing.screenHorizontal, 20);
    });
  });

  group('TrypXPrimaryButton', () {
    testWidgets('renders text and fires onPressed on tap', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrypXPrimaryButton(
              text: 'Continue',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('TrypXCard', () {
    testWidgets('renders its child', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrypXCard(
              child: Text('Card body'),
            ),
          ),
        ),
      );

      expect(find.text('Card body'), findsOneWidget);
    });
  });
}
