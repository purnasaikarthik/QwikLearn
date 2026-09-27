import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class AiChatScreen extends StatefulWidget {
  final String spaceId;
  const AiChatScreen({super.key, required this.spaceId});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final List<({String text, bool fromUser})> _messages = [
    (text: "Hi! Ask me anything about this study space's material.", fromUser: false),
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add((text: text, fromUser: true));
      _messages.add((text: "That's a great question — once the AI backend is connected, I'll answer using only this study space's material.", fromUser: false));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: Text('Ask QwikLearn', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  return Align(
                    alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: m.fromUser ? AppColors.ink : AppColors.paperDim,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        m.text,
                        style: TextStyle(color: m.fromUser ? AppColors.paper : AppColors.ink, height: 1.4),
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(hintText: 'Ask about this material…'),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: AppColors.highlight,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_upward_rounded, color: AppColors.ink),
                        onPressed: _send,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
