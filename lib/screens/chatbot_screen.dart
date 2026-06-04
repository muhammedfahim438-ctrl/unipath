import 'package:flutter/material.dart';
import '../theme.dart';

// ─────────────────────────────────────────
//  Screen 12 — Chatbot Support
//  Save to: lib/screens/chatbot_screen.dart
// ─────────────────────────────────────────

// Sample chat messages
class _Message {
  final String text;
  final bool isUser;
  final String time;

  const _Message({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_Message> _messages = [
    const _Message(
      text: 'Hello! 👋\nHow can I help you today?',
      isUser: false,
      time: '10:30 AM',
    ),
    const _Message(
      text: 'I feel stressed about my exams.',
      isUser: true,
      time: '10:32 AM',
    ),
    const _Message(
      text:
          "It's completely normal to feel stressed sometimes.\nWould you like some tips to manage stress?",
      isUser: false,
      time: '10:32 AM',
    ),
    const _Message(
      text: 'Yes, please.',
      isUser: true,
      time: '10:32 AM',
    ),
    const _Message(
      text:
          'Here are some tips:\n✅ Take short breaks\n✅ Stay hydrated\n✅ Practice deep breathing\n✅ Get enough sleep\n✅ Stay positive and focused',
      isUser: false,
      time: '10:32 AM',
    ),
  ];

  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(
        text: text,
        isUser: true,
        time: _currentTime(),
      ));
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Simulate bot reply after 1.5 seconds
    // In real app: Sreekuttan's Python chatbot handles this via API
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_Message(
            text:
                "Thank you for sharing that. Our counsellor can help you further. Would you like to book a session? 📅",
            isUser: false,
            time: _currentTime(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  String _currentTime() {
    final now = TimeOfDay.now();
    final h = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UniBot',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Online',
                      style: TextStyle(
                          color: AppColors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded,
                color: AppColors.primaryDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Chat Messages ──
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _TypingIndicator();
                }
                final msg = _messages[index];
                return _ChatBubble(message: msg);
              },
            ),
          ),

          // ── Message Input ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(
                        color: AppColors.primaryDark, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle:
                          TextStyle(color: AppColors.grey.withValues(alpha: 0.6)),
                      filled: true,
                      fillColor: AppColors.greyLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: AppColors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat Bubble ──
class _ChatBubble extends StatelessWidget {
  final _Message message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft:
                      Radius.circular(isUser ? 18 : 4),
                  bottomRight:
                      Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? AppColors.white : AppColors.primaryDark,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.time,
              style: const TextStyle(color: AppColors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Typing Indicator ──
class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            const SizedBox(width: 4),
            _Dot(delay: 200),
            const SizedBox(width: 4),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
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
      builder: (_, _) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.grey.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
