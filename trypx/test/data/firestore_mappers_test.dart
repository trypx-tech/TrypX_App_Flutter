library;

import 'package:flutter_test/flutter_test.dart';
import 'package:trypx/core/models/enums.dart';
import 'package:trypx/data/firestore_mappers.dart';

void main() {
  group('firestore_mappers', () {
    test('persona maps correctly', () {
      expect(personaToWire(Persona.publicCreator), 'public_creator');
      expect(personaToWire(Persona.silentExpert), 'silent_expert');

      expect(personaFromWire('public_creator'), Persona.publicCreator);
      expect(personaFromWire('silent_expert'), Persona.silentExpert);

      expect(() => personaFromWire('unknown'), throwsArgumentError);
    });

    test('status maps correctly', () {
      expect(statusToWire(ApplicationStatus.submitted), 'submitted');
      expect(statusToWire(ApplicationStatus.approved), 'approved');
      expect(statusToWire(ApplicationStatus.rejected), 'rejected');

      expect(() => statusToWire(ApplicationStatus.draft), throwsArgumentError);

      expect(statusFromWire('submitted'), ApplicationStatus.submitted);
      expect(statusFromWire('approved'), ApplicationStatus.approved);
      expect(statusFromWire('rejected'), ApplicationStatus.rejected);

      expect(() => statusFromWire('unknown'), throwsArgumentError);
    });

    test('outcome maps correctly', () {
      expect(outcomeToWire(DecisionOutcome.approve), 'approved');
      expect(outcomeToWire(DecisionOutcome.reject), 'rejected');

      expect(() => outcomeToWire(DecisionOutcome.waitlist), throwsArgumentError);
    });
  });
}
