import 'package:flutter/material.dart';

class JournalEntry {
  final String id;
  final String content;
  final DateTime date;
  final String mood;
  final List<String> tags;

  JournalEntry({
    required this.id,
    required this.content,
    required this.date,
    required this.mood,
    required this.tags,
  });
}

class JournalProvider extends ChangeNotifier {
  final List<JournalEntry> _entries = [];
  DateTime? _lastEntryDate;

  List<JournalEntry> get entries => List.unmodifiable(_entries);
  DateTime? get lastEntryDate => _lastEntryDate;

  void addEntry(String content, String mood, List<String> tags) {
    final entry = JournalEntry(
      id: DateTime.now().toString(),
      content: content,
      date: DateTime.now(),
      mood: mood,
      tags: tags,
    );

    _entries.insert(0, entry);
    _lastEntryDate = entry.date;
    notifyListeners();
  }

  void deleteEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    _lastEntryDate = _entries.isNotEmpty ? _entries.first.date : null;
    notifyListeners();
  }

  void editEntry(String id, String content, String mood, List<String> tags) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      _entries[index] = JournalEntry(
        id: id,
        content: content,
        date: _entries[index].date,
        mood: mood,
        tags: tags,
      );
      notifyListeners();
    }
  }

  List<JournalEntry> getEntriesByDate(DateTime date) {
    return _entries
        .where((entry) =>
            entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day)
        .toList();
  }

  Map<String, int> getMoodStats() {
    final moodCounts = <String, int>{};
    for (var entry in _entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }
    return moodCounts;
  }
}
