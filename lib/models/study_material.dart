import '../core/constants/enums.dart';

class StudyMaterial {
  final String id;
  final String studySpaceId;
  final String title;
  final StudyMaterialType materialType;
  final String? content;
  final String? fileUrl;
  final String? sourceUrl;
  final DateTime createdAt;

  const StudyMaterial({
    required this.id,
    required this.studySpaceId,
    required this.title,
    required this.materialType,
    this.content,
    this.fileUrl,
    this.sourceUrl,
    required this.createdAt,
  });

  factory StudyMaterial.fromMap(Map<String, dynamic> map) => StudyMaterial(
        id: map['id'] as String,
        studySpaceId: map['study_space_id'] as String,
        title: map['title'] as String,
        materialType: StudyMaterialType.values.firstWhere(
          (t) => t.name == (map['material_type'] as String? ?? 'text'),
          orElse: () => StudyMaterialType.text,
        ),
        content: map['content'] as String?,
        fileUrl: map['file_url'] as String?,
        sourceUrl: map['source_url'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
