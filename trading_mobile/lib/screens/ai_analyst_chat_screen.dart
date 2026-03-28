import 'package:flutter/material.dart';

import '../theme/design_system.dart';

/// Placeholder chat — wire to your LLM / agent backend.
class AiAnalystChatScreen extends StatefulWidget {
  const AiAnalystChatScreen({super.key});

  @override
  State<AiAnalystChatScreen> createState() => _AiAnalystChatScreenState();
}

class _AiAnalystChatScreenState extends State<AiAnalystChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  final _messages = <_ChatMsg>[
    const _ChatMsg(
      isUser: false,
      text:
          'Hi — I’m your AI analyst preview. Ask about structure, risk, or how the current signal was derived.',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(isUser: true, text: t));
      _messages.add(
        const _ChatMsg(
          isUser: false,
          text:
              'Preview mode: connect your chat API to stream real answers. '
              'Try asking: “Why is RSI important here?”',
        ),
      );
      _ctrl.clear();
    });
    Future.microtask(() {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analyst'),
        actions: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attach screenshots — connect file picker in production')),
            ),
            icon: const Icon(Icons.attach_file_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return Align(
                  alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.86),
                    decoration: BoxDecoration(
                      color: m.isUser ? AppColors.primarySoft : AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(m.isUser ? 18 : 6),
                        bottomRight: Radius.circular(m.isUser ? 6 : 18),
                      ),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Text(
                      m.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Ask about the market…',
                        prefixIcon: Icon(Icons.chat_rounded),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _send,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  const _ChatMsg({required this.isUser, required this.text});

  final bool isUser;
  final String text;
}
