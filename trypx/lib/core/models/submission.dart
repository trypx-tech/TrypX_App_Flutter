/// TrypX application-submission models. Ported from ApplicationSubmission.kt.
/// Plain immutable Dart (no codegen) with JSON (de)serialization for Firestore.
library;

import 'enums.dart';

/// Interview slots are proposed without a reviewer; a human reviewer is assigned later.
const String kUnassignedReviewerId = 'unassigned';

class SocialLink {
  const SocialLink({required this.platform, required this.handle});

  final SocialPlatform platform;
  final String handle;

  Map<String, dynamic> toJson() => {
        'platform': platform.name,
        'handle': handle,
      };

  factory SocialLink.fromJson(Map<String, dynamic> json) => SocialLink(
        platform: SocialPlatform.values.byName(json['platform'] as String),
        handle: json['handle'] as String,
      );

  @override
  bool operator ==(Object other) =>
      other is SocialLink && other.platform == platform && other.handle == handle;

  @override
  int get hashCode => Object.hash(platform, handle);
}

class PlaceClaim {
  const PlaceClaim({
    required this.name,
    required this.countryCode,
    required this.depth,
    this.yearsKnown,
    this.note,
  });

  final String name;
  final String countryCode;
  final PlaceDepth depth;
  final int? yearsKnown;
  final String? note;

  Map<String, dynamic> toJson() => {
        'name': name,
        'countryCode': countryCode,
        'depth': depth.name,
        'yearsKnown': yearsKnown,
        'note': note,
      };

  factory PlaceClaim.fromJson(Map<String, dynamic> json) => PlaceClaim(
        name: json['name'] as String,
        countryCode: json['countryCode'] as String,
        depth: PlaceDepth.values.byName(json['depth'] as String),
        yearsKnown: json['yearsKnown'] as int?,
        note: json['note'] as String?,
      );
}

class LanguageClaim {
  const LanguageClaim({required this.languageCode, required this.level});

  final String languageCode;
  final ProficiencyLevel level;

  Map<String, dynamic> toJson() => {
        'languageCode': languageCode,
        'level': level.name,
      };

  factory LanguageClaim.fromJson(Map<String, dynamic> json) => LanguageClaim(
        languageCode: json['languageCode'] as String,
        level: ProficiencyLevel.values.byName(json['level'] as String),
      );
}

/// Everything S-02…S-09 collected. social == null means the manual, no-social path
/// (invariant 19).
class ApplicationSubmission {
  const ApplicationSubmission({
    required this.persona,
    required this.displayName,
    required this.social,
    required this.places,
    required this.languages,
    required this.interviewStartsAtEpochMs,
  });

  final Persona persona;
  final String displayName;
  final SocialLink? social;
  final List<PlaceClaim> places;
  final List<LanguageClaim> languages;
  final int interviewStartsAtEpochMs;

  bool get hasAtLeastOneDeepPlace => places.any((p) => p.depth.isDeep);

  Map<String, dynamic> toJson() => {
        'persona': persona.name,
        'displayName': displayName,
        'social': social?.toJson(),
        'places': places.map((p) => p.toJson()).toList(),
        'languages': languages.map((l) => l.toJson()).toList(),
        'interviewStartsAtEpochMs': interviewStartsAtEpochMs,
      };

  factory ApplicationSubmission.fromJson(Map<String, dynamic> json) =>
      ApplicationSubmission(
        persona: Persona.values.byName(json['persona'] as String),
        displayName: json['displayName'] as String,
        social: json['social'] == null
            ? null
            : SocialLink.fromJson(json['social'] as Map<String, dynamic>),
        places: (json['places'] as List)
            .map((e) => PlaceClaim.fromJson(e as Map<String, dynamic>))
            .toList(),
        languages: (json['languages'] as List)
            .map((e) => LanguageClaim.fromJson(e as Map<String, dynamic>))
            .toList(),
        interviewStartsAtEpochMs: json['interviewStartsAtEpochMs'] as int,
      );
}
