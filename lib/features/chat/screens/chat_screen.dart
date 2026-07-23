import 'package:flutter_dotenv/flutter_dotenv.dart';

import '/core/utils/exports.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat_ui;
import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';
import 'package:uuid/uuid.dart';

import '/core/providers/theme_provider.dart';
import '/core/providers/user_provider.dart';
import '/core/providers/daily_tracker_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  final bool? newChat;
  final bool imageSearch;
  const ChatPage({super.key, this.newChat, required this.imageSearch});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ValueNotifier<int> _updateState = ValueNotifier(0);
  final TextEditingController _textController = TextEditingController();

  List<types.Message> _messages = [];
  final _user = const types.User(id: 'user-1', firstName: 'User');
  final _bot = const types.User(id: 'bot-1', firstName: 'SpeciFit AI');
  GenerativeModel? _model;
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  List<types.User> _typing = [];
  bool _isListening = false;

  String get _geminiAPIKey {
    final url = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (url.isEmpty) {
      debugPrint('[Gemini] WARNING: GEMINI_API_KEY not set in .env!');
    }
    return url.trimRight().replaceAll(RegExp(r'/$'), '');
  }

  @override
  void initState() {
    super.initState();
    if (widget.newChat == true) {
      _createNewChatFile();
    } else {
      loadMessages().then((loadedMessages) {
        _messages = loadedMessages;
        _updateState.value++;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _initializeModel(WidgetRef ref) {
    if (_model != null) return;

    final user = ref.read(userProvider);
    final tracker = ref.read(dailyTrackerProvider);

    String systemInstructions =
        '''
You are SpeciFit AI, an expert health and fitness trainer. Your goal is to improve the user's fitness and help them reach their goals.
Use a friendly, encouraging, and professional tone.
Here is the user's data:
- Name: ${user?.firstname ?? 'User'}
- Gender: ${user?.gender ?? 'Unknown'}
- Age: ${user?.age ?? 'Unknown'}
- Height: ${user?.height ?? 'Unknown'} cm
- Weight: ${user?.weight ?? 'Unknown'} kg
- Fitness Goal: ${user?.goal ?? 'Unknown'}
- Activity Level: ${user?.level ?? 'Unknown'}
- Lifestyle: ${user?.lifestyle ?? 'Unknown'}
- Today's Water: ${tracker.water} L
- Today's Steps: ${tracker.steps}

When responding, ALWAYS take into account the user's metrics. Specifically, compute their TDEE (Total Daily Energy Expenditure), Maintenance Calories, and Macro splits (Protein, Carbs, Fats) internally based on their height, weight, age, gender, and activity level. 
When the user asks for meal plans (e.g. breakfast, lunch, dinner) or workout advice, give them personalized recommendations that strictly align with their specific body metrics and calculated macros. Ensure consistency in your calorie and macro recommendations throughout the chat. Provide actionable, clear, and beautifully structured advice. Keep your responses concise and fast.
''';

    final apiKey = _geminiAPIKey;
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(temperature: 0.7),
      systemInstruction: Content.system(systemInstructions),
    );
  }

  Future<void> _createNewChatFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/messages.json');

      if (await file.exists()) {
        await file.delete(); // Remove old file
      }

      // Create an empty file for new chat
      await file.writeAsString(jsonEncode([]));
      _messages = [];
      _updateState.value++;
    } catch (e) {
      debugPrint('Error creating new chat file: $e');
    }
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    _typing = [_bot];
    _updateState.value++;

    _sendToGemini();
    saveMessages(_messages);
  }

  Future<void> _sendToGemini() async {
    if (_model == null) return;
    try {
      final currentMessage = (_messages.first as types.TextMessage).text;

      String conversationContext = "Recent conversation history:\n";
      for (var msg in _messages.skip(1).take(5).toList().reversed) {
        if (msg is types.TextMessage) {
          String role = msg.author.id == _user.id ? "User" : "Trainer";
          conversationContext += "$role: ${msg.text}\n";
        }
      }

      String finalPrompt = "User's new message: $currentMessage";
      if (_messages.length > 1) {
        finalPrompt = "$conversationContext\n$finalPrompt";
      }

      final response = await _model!.generateContent([
        Content.text(finalPrompt),
      ]);

      final botMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: response.text.toString(),
      );

      _addMessage(botMessage);
      saveMessages(_messages);
    } catch (e) {
      debugPrint('Error sending to Gemini: $e');
      _typing = [];
      _updateState.value++;
    }
  }

  Future<void> _handleVoiceInput() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        _isListening = true;
        _updateState.value++;
        _speechToText.listen(
          onResult: (result) async {
            if (result.finalResult) {
              final input = result.recognizedWords;
              _isListening = false;
              _textController.text = input;
              _updateState.value++;
            }
          },
        );
      }
    } else {
      _isListening = false;
      _updateState.value++;
      _speechToText.stop();
    }
  }

  Future<void> saveMessages(List<types.Message> messages) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/messages.json');

      final messagesJson = messages.map((msg) => msg.toJson()).toList();
      await file.writeAsString(jsonEncode(messagesJson));
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }
  }

  Future<List<types.Message>> loadMessages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/messages.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> messagesJson = jsonDecode(content);

        return messagesJson
            .map((msg) => types.Message.fromJson(msg as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }

    return [];
  }

  void _addMessage(types.Message message) {
    _messages.insert(0, message);
    _typing = [];
    _updateState.value++;
  }

  Widget _buildEmptyState(bool isDark) {
    final suggestions = [
      "Can you suggest an alternative to squats for knee pain?",
      "I overate today, what should I do tomorrow?",
      "What are some effective ways to gain weight?",
      "What supplements should I take for weight loss?",
    ];

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.health_and_safety,
                size: 64,
                color: AppColors.instance.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                "How can I help you reach your goals today?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: suggestions.map((text) {
                  return InkWell(
                    onTap: () {
                      _textController.text = text;
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.instance.primary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBottomWidget(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.instance.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            InkWell(
              onTap: _handleVoiceInput,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening
                      ? Colors.red.withValues(alpha: 0.1)
                      : AppColors.instance.primary.withValues(alpha: 0.1),
                ),
                child: _isListening
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                    : Icon(
                        CupertinoIcons.mic,
                        color: _isListening
                            ? Colors.red
                            : AppColors.instance.primary,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.transparent : Colors.grey.shade300,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask SpeciFit AI...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty) {
                      _handleSendPressed(types.PartialText(text: text.trim()));
                      _textController.clear();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                if (_textController.text.trim().isNotEmpty) {
                  _handleSendPressed(
                    types.PartialText(text: _textController.text.trim()),
                  );
                  _textController.clear();
                }
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.instance.primary,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _initializeModel(ref);

    final isDark = ref.watch(themeProvider);
    return ValueListenableBuilder(
      valueListenable: _updateState,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor: isDark
              ? AppColors.instance.surfaceDark
              : AppColors.instance.surface,
          appBar: AppBar(
            title: const Text('SpeciFit AI Trainer'),
            actions: [
              if (_messages.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.add_comment_rounded),
                  tooltip: 'New Chat',
                  onPressed: _createNewChatFile,
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: chat_ui.Chat(
                    typingIndicatorOptions: chat_ui.TypingIndicatorOptions(
                      typingUsers: _typing,
                    ),
                    messages: _messages,
                    onSendPressed: _handleSendPressed,
                    showUserAvatars: true,
                    showUserNames: true,
                    user: _user,
                    emptyState: _buildEmptyState(isDark),
                    customBottomWidget: _buildCustomBottomWidget(isDark),
                    theme: isDark
                        ? chat_ui.DarkChatTheme(
                            backgroundColor: AppColors.instance.surfaceDark,
                            primaryColor: AppColors.instance.primary,
                          )
                        : chat_ui.DefaultChatTheme(
                            backgroundColor: AppColors.instance.surface,
                            primaryColor: AppColors.instance.primary,
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
