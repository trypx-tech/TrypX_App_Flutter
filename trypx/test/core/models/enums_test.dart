import 'package:flutter_test/flutter_test.dart';
import 'package:trypx/core/models/enums.dart';

void main() {
  test('location supplier cap is 50 (invariant 17)', () {
    expect(kLocationSupplierCap, 50);
  });

  test('default interview length is 30 minutes', () {
    expect(kDefaultInterviewMinutes, 30);
  });

  test('two supply personas exist (invariant 11)', () {
    expect(Persona.values.length, 2);
  });

  test('deep place depths are livedThere and frequent only', () {
    final deep = PlaceDepth.values.where((d) => d.isDeep).toSet();
    expect(deep, {PlaceDepth.livedThere, PlaceDepth.frequent});
    expect(PlaceDepth.visited.isDeep, isFalse);
  });

  test('decision outcomes match the reviewer model', () {
    expect(DecisionOutcome.values, [
      DecisionOutcome.approve,
      DecisionOutcome.waitlist,
      DecisionOutcome.reject,
      DecisionOutcome.requestMoreInfo,
    ]);
  });
}
