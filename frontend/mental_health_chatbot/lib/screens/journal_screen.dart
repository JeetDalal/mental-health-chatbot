import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mental_health_chatbot/model/journal_entry.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _journalController = TextEditingController();
  bool _isWriting = false;
  List<JournalEntry> _entries = [];
  String _selectedMood = '😊';
  final List<String> _moods = ['😊', '😔', '😡', '😌', '😴', '🤔', '😰'];
  bool _showRewardAnimation = false;

  @override
  void initState() {
    super.initState();
    // Add some dummy data
    _entries = [
      JournalEntry(
        id: '1',
        content: 'Had a great day today! Feeling positive about the future.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        mood: '😊',
        tags: ['Positive', 'Happy'],
      ),
      JournalEntry(
        id: '2',
        content: 'Feeling a bit anxious about tomorrow\'s meeting.',
        date: DateTime.now().subtract(const Duration(days: 2)),
        mood: '😰',
        tags: ['Anxious', 'Work'],
      ),
    ];
  }

  void _showReward() {
    setState(() {
      _showRewardAnimation = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showRewardAnimation = false;
      });
    });
  }

  void _addEntry() {
    if (_journalController.text.trim().isEmpty) return;

    setState(() {
      _entries.insert(
        0,
        JournalEntry(
          id: DateTime.now().toString(),
          content: _journalController.text,
          date: DateTime.now(),
          mood: _selectedMood,
          tags: ['Journal'],
        ),
      );
      _journalController.clear();
      _isWriting = false;
    });

    _showReward();
  }

  void _deleteEntry(String id) {
    setState(() {
      _entries.removeWhere((entry) => entry.id == id);
    });
  }

  void _editEntry(JournalEntry entry) {
    _journalController.text = entry.content;
    _selectedMood = entry.mood;
    setState(() {
      _isWriting = true;
    });
    _deleteEntry(entry.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2F4F),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Journal',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isWriting = true;
                        });
                      },
                      icon:
                          const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
              if (!_isWriting) _buildJournalList() else _buildJournalEditor(),
            ],
          ),
          if (_showRewardAnimation)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.stars,
                      color: Colors.amber,
                      size: 48,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '+10 Points!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A2F4F),
                      ),
                    ),
                    const Text(
                      'Thank you for journaling today!',
                      style: TextStyle(
                        color: Color(0xFF2A2F4F),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(duration: 300.ms)
                  .then()
                  .fadeOut(delay: 1500.ms),
            ),
        ],
      ),
    );
  }

  Widget _buildJournalList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          return Card(
            color: Colors.white.withOpacity(0.1),
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM d, y').format(entry.date),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            entry.mood,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white70,
                            ),
                            color: Colors.white,
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                onTap: () => _editEntry(entry),
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: () => _deleteEntry(entry.id),
                                child: const Row(
                                  children: [
                                    Icon(Icons.delete, size: 20),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2);
        },
      ),
    );
  }

  Widget _buildJournalEditor() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _moods.map((mood) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = mood),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedMood == mood
                              ? Colors.white.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          mood,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _journalController,
                maxLines: null,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Write your thoughts...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isWriting = false;
                      _journalController.clear();
                    });
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2A2F4F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Entry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
