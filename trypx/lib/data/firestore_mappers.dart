library;

import '../core/models/enums.dart';

String personaToWire(Persona persona) {
  switch (persona) {
    case Persona.publicCreator:
      return 'public_creator';
    case Persona.silentExpert:
      return 'silent_expert';
  }
}

Persona personaFromWire(String wire) {
  switch (wire) {
    case 'public_creator':
      return Persona.publicCreator;
    case 'silent_expert':
      return Persona.silentExpert;
    default:
      throw ArgumentError('Unknown persona wire format: $wire');
  }
}

String statusToWire(ApplicationStatus status) {
  switch (status) {
    case ApplicationStatus.submitted:
      return 'submitted';
    case ApplicationStatus.approved:
      return 'approved';
    case ApplicationStatus.rejected:
      return 'rejected';
    default:
      throw ArgumentError('Cannot map status $status to wire');
  }
}

ApplicationStatus statusFromWire(String wire) {
  switch (wire) {
    case 'submitted':
      return ApplicationStatus.submitted;
    case 'approved':
      return ApplicationStatus.approved;
    case 'rejected':
      return ApplicationStatus.rejected;
    default:
      throw ArgumentError('Unknown status wire format: $wire');
  }
}

String outcomeToWire(DecisionOutcome outcome) {
  switch (outcome) {
    case DecisionOutcome.approve:
      return 'approved';
    case DecisionOutcome.reject:
      return 'rejected';
    default:
      throw ArgumentError('Cannot map outcome $outcome to wire');
  }
}
