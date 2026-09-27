enum StudyMaterialType { pdf, text, article, youtube, audio }

enum SummaryLength { short, medium, detailed }

enum CardDifficulty { easy, medium, difficult }

enum QuizDifficulty { easy, medium, hard }

enum QuestionType { multipleChoice, trueFalse }

enum ChatRole { user, assistant }

extension StudyMaterialTypeX on StudyMaterialType {
  String get label => switch (this) {
        StudyMaterialType.pdf => 'PDF',
        StudyMaterialType.text => 'Text',
        StudyMaterialType.article => 'Article',
        StudyMaterialType.youtube => 'YouTube',
        StudyMaterialType.audio => 'Audio',
      };
}

extension CardDifficultyX on CardDifficulty {
  String get label => switch (this) {
        CardDifficulty.easy => 'Easy',
        CardDifficulty.medium => 'Medium',
        CardDifficulty.difficult => 'Difficult',
      };
}
