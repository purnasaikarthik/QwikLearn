class StudySpace {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? subject;
  final String? coverImageUrl;
  final DateTime createdAt;

  const StudySpace({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.subject,
    this.coverImageUrl,
    required this.createdAt,
  });

  factory StudySpace.fromMap(Map<String, dynamic> map) => StudySpace(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        subject: map['subject'] as String?,
        coverImageUrl: map['cover_image_url'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
