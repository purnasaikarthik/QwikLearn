class KeyConcept {
  final String id;
  final String studySpaceId;
  final String name;
  final String definition;
  final String? simpleExplanation;
  final List<String> relatedTopics;

  const KeyConcept({
    required this.id,
    required this.studySpaceId,
    required this.name,
    required this.definition,
    this.simpleExplanation,
    this.relatedTopics = const [],
  });

  factory KeyConcept.fromMap(Map<String, dynamic> map) => KeyConcept(
        id: map['id'] as String,
        studySpaceId: map['study_space_id'] as String,
        name: map['name'] as String,
        definition: map['definition'] as String,
        simpleExplanation: map['simple_explanation'] as String?,
        relatedTopics: (map['related_topics'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );
}
