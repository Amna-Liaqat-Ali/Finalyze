import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

const _kSystemPrompt = '''
You are Finalyze Assistant — an expert on:
1. Fish freshness detection: how to identify fresh, moderate, or spoiled fish by smell, colour, eyes, gills, texture, and AI confidence scores.
2. Fish species found in Pakistan: Surmai (King Mackerel), Rahu, Rohu, Pomfret (Paplet), Pallo (Hilsa), Singhara, Tilapia, Trout, Red Snapper, Mushka, Catla, and others found in Pakistani rivers, coasts, and markets.
3. Pakistani fish recipes: traditional and modern cooking methods — fried, grilled, curry, biryani, karahi, sajji, steam-roast, and regional specialties.

Rules:
- Keep answers concise and helpful (2–5 sentences max unless a recipe or list is needed).
- Use a friendly, knowledgeable tone.
- If the user asks something outside these topics (e.g. politics, coding, math), politely say you can only help with fish-related questions.
- When listing steps or ingredients, use a clean numbered or bulleted format.
''';

class AiChatSheet extends StatefulWidget {
  const AiChatSheet({super.key});

  @override
  State<AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<AiChatSheet> {
  static const _blue = Color(0xFF1A5694);
  static const _ocean = Color(0xFF0891B2);
  static const _teal = Color(0xFF2CB88E);

  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Msg> _messages = [];
  bool _loading = false;

  // Conversation history for multi-turn chat
  final List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _messages.add(_Msg(
      text: "Hi! I'm your Finalyze fish assistant.\nAsk me anything about fish freshness, Pakistani species, or recipes!",
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add(_Msg(text: text, isUser: true));
      _loading = true;
      _ctrl.clear();
    });
    _scrollToBottom();

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

      _history.add({'role': 'user', 'content': text});

      final body = jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {'role': 'system', 'content': _kSystemPrompt},
          ..._history,
        ],
        'max_tokens': 512,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: body,
      ).timeout(const Duration(seconds: 30));

      debugPrint('Groq status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final reply = json['choices']?[0]?['message']?['content']
            ?? 'Sorry, I could not generate a response.';
        _history.add({'role': 'assistant', 'content': reply});
        if (mounted) setState(() => _messages.add(_Msg(text: reply, isUser: false)));
      } else {
        debugPrint('Groq error body: ${response.body}');
        _history.removeLast();
        final errJson = jsonDecode(response.body);
        final errMsg = errJson['error']?['message'] ?? 'Unknown error';
        if (mounted) setState(() => _messages.add(_Msg(
              text: 'Error ${response.statusCode}: $errMsg',
              isUser: false,
              isError: true,
            )));
      }
    } catch (e) {
      debugPrint('Groq exception: $e');
      if (_history.isNotEmpty) _history.removeLast();
      if (mounted) setState(() => _messages.add(_Msg(
            text: 'Connection error. Please check your internet and try again.',
            isUser: false,
            isError: true,
          )));
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(child: _buildMessages()),
          if (_loading) _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2E5C), _blue, _ocean],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.set_meal_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Finalyze Assistant",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text("Fish · Freshness · Recipes",
                    style: GoogleFonts.poppins(
                        color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _teal,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text("Online",
              style:
                  GoogleFonts.poppins(color: _teal, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildBubble(_messages[i]),
    );
  }

  Widget _buildBubble(_Msg msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_blue, _ocean],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.set_meal_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? _blue
                    : msg.isError
                        ? Colors.red.shade50
                        : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: msg.isError
                    ? Border.all(color: Colors.red.shade200)
                    : null,
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isUser
                      ? Colors.white
                      : msg.isError
                          ? Colors.red.shade700
                          : const Color(0xFF1A2236),
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 16, 4),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_blue, _ocean]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.set_meal_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => _BouncingDot(delay: Duration(milliseconds: i * 150)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -3)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _ctrl,
                onSubmitted: (_) => _send(),
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Ask about fish, freshness, recipes...",
                  hintStyle: GoogleFonts.poppins(
                      color: Colors.blueGrey.shade300, fontSize: 12),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                ),
                maxLines: 4,
                minLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_blue, _ocean, _teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(13),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;
  final bool isError;
  _Msg({required this.text, required this.isUser, this.isError = false});
}

// Animated typing dots
class _BouncingDot extends StatefulWidget {
  final Duration delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 7,
        height: 7,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Color.lerp(Colors.blueGrey.shade200,
              const Color(0xFF0891B2), _anim.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
