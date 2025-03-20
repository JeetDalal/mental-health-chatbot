class MoodEntry {
  final DateTime date;
  final int moodScore; // 1-5 scale
  final String moodType; // 'happy', 'sad', 'angry', 'calm'

  MoodEntry({
    required this.date,
    required this.moodScore,
    required this.moodType,
  });
}
