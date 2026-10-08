import 'package:flutter_test/flutter_test.dart';
import 'package:trypx/core/models/enums.dart';
import 'package:trypx/core/models/submission.dart';

void main() {
  test('unassigned reviewer id constant', () {
    expect(kUnassignedReviewerId, 'unassigned');
  });

  test('hasAtLeastOneDeepPlace reflects place depth', () {
    final deep = ApplicationSubmission(
      persona: Persona.silentExpert,
      displayName: 'A',
      social: null,
      places: const [
        PlaceClaim(name: 'Kyoto', countryCode: 'JP', depth: PlaceDepth.visited),
        PlaceClaim(name: 'Osaka', countryCode: 'JP', depth: PlaceDepth.livedThere),
      ],
      languages: const [LanguageClaim(languageCode: 'ja', level: ProficiencyLevel.native)],
      interviewStartsAtEpochMs: 0,
    );
    expect(deep.hasAtLeastOneDeepPlace, isTrue);

    final shallow = ApplicationSubmission(
      persona: Persona.publicCreator,
      displayName: 'B',
      social: null,
      places: const [
        PlaceClaim(name: 'Kyoto', countryCode: 'JP', depth: PlaceDepth.visited),
      ],
      languages: const [LanguageClaim(languageCode: 'en', level: ProficiencyLevel.fluent)],
      interviewStartsAtEpochMs: 0,
    );
    expect(shallow.hasAtLeastOneDeepPlace, isFalse);
  });

  test('null social survives a JSON round-trip (invariant 19 manual path)', () {
    final sub = ApplicationSubmission(
      persona: Persona.silentExpert,
      displayName: 'No Social',
      social: null,
      places: const [
        PlaceClaim(name: 'Pune', countryCode: 'IN', depth: PlaceDepth.frequent),
      ],
      languages: const [LanguageClaim(languageCode: 'hi', level: ProficiencyLevel.native)],
      interviewStartsAtEpochMs: 123,
    );
    final round = ApplicationSubmission.fromJson(sub.toJson());
    expect(round.social, isNull);
    expect(round.persona, Persona.silentExpert);
    expect(round.places.single.depth, PlaceDepth.frequent);
    expect(round.interviewStartsAtEpochMs, 123);
  });

  test('social link round-trips when present', () {
    const link = SocialLink(platform: SocialPlatform.instagram, handle: '@traveler');
    final round = SocialLink.fromJson(link.toJson());
    expect(round, link);
  });
}
