import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mental_health_chatbot/constants/constants.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ChatInterface extends StatefulWidget {
  const ChatInterface({super.key});

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  // Fix: Use AudioRecorder() instead of Record() - the concrete implementation
  final recorder = AudioRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(
      ChatMessage(
        message:
            "Hi! I'm Bhava, your mental wellness companion. How are you feeling today?",
        isBot: true,
      ),
    );
  }

  Future<void> _startRecording() async {
    if (await recorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/audio.wav';
      await recorder.start(RecordConfig(), path: path);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await recorder.stop();
    setState(() {
      _isRecording = false;
    });
    if (path != null) {
      _sendAudioToRevAI(File(path));
    }
  }

  Future<void> _sendAudioToRevAI(File audioFile) async {
    final apiKey = 'YOUR_REV_AI_API_KEY'; // Replace with your Rev AI API key
    final url = 'https://api.rev.ai/speechtotext/v1/jobs';
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'multipart/form-data', // Fixed content type
    };

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath('media', audioFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);
      final jobId = data['id'];
      _checkRevAIJobStatus(jobId);
    } else {
      // Handle error
      setState(() {
        _messages.add(
          ChatMessage(
            message: "Sorry, there was an error processing your audio.",
            isBot: true,
          ),
        );
      });
    }
  }

  Future<void> _checkRevAIJobStatus(String jobId) async {
    final apiKey = 'YOUR_REV_AI_API_KEY'; // Replace with your Rev AI API key
    final url = 'https://api.rev.ai/speechtotext/v1/jobs/$jobId';
    final headers = {
      'Authorization': 'Bearer $apiKey',
    };

    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'transcribed') {
        final transcriptUrl =
            'https://api.rev.ai/speechtotext/v1/jobs/$jobId/transcript';
        _getTranscript(transcriptUrl);
      } else {
        // Retry after some time
        Future.delayed(const Duration(seconds: 5), () {
          _checkRevAIJobStatus(jobId);
        });
      }
    } else {
      // Handle error
      setState(() {
        _messages.add(
          ChatMessage(
            message:
                "Sorry, there was an error checking the status of your audio transcription.",
            isBot: true,
          ),
        );
      });
    }
  }

  Future<void> _getTranscript(String transcriptUrl) async {
    final apiKey = 'YOUR_REV_AI_API_KEY'; // Replace with your Rev AI API key
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
    };

    final response = await http.get(Uri.parse(transcriptUrl), headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final transcript =
          data['monologues'][0]['elements'].map((e) => e['value']).join(' ');
      _analyzeSentiment(transcript);
    } else {
      // Handle error
      setState(() {
        _messages.add(
          ChatMessage(
            message: "Sorry, there was an error retrieving your transcript.",
            isBot: true,
          ),
        );
      });
    }
  }

  Future<void> _analyzeSentiment(String text) async {
    // Add the user's message to the chat
    setState(() {
      _messages.add(ChatMessage(message: text, isBot: false));
    });

    // Scroll to bottom
    _scrollToBottom();

    // Simple sentiment response (replace with actual sentiment analysis)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          ChatMessage(
            message: "I heard what you said. How else can I help you today?",
            isBot: true,
          ),
        );
      });

      // Scroll to bottom again after bot response
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          message: _messageController.text,
          isBot: false,
        ),
      );
    });

    // Clear input field
    String userMessage = _messageController.text;
    _messageController.clear();

    // Scroll to bottom
    _scrollToBottom();

    // Simulate bot response (replace with actual bot logic)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          ChatMessage(
            message:
                "I understand how you feel. Would you like to talk more about it?",
            isBot: true,
          ),
        );
      });

      // Scroll to bottom again after bot response
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tileColor,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.1),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: Image.network(
                'https://cdn-icons-png.flaticon.com/512/4712/4712009.png',
                height: 24,
                width: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bhava',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index]
                    .animate()
                    .fadeIn()
                    .slideY(begin: 0.3, duration: 300.ms);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded),
                    color: const Color(0xFF2A2F4F),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: const Color(0xFF2A2F4F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    recorder.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isBot;

  const ChatMessage({
    super.key,
    required this.message,
    required this.isBot,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: Image.network(
                'https://cdn-icons-png.flaticon.com/512/4712/4712009.png',
                height: 20,
                width: 20,
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isBot
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: isBot ? Colors.white : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (!isBot)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.person,
                size: 20,
                color: Color(0xFF2A2F4F),
              ),
            ),
        ],
      ),
    );
  }
}
