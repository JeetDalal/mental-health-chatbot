class JournalEntry {
  String id;
  String content;
  DateTime date;
  String mood;
  List<String> tags;

  JournalEntry({
    required this.id,
    required this.content,
    required this.date,
    required this.mood,
    required this.tags,
  });
}
