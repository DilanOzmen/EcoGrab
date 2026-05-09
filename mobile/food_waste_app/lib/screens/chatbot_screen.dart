import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:food_waste_app/core/app_assets.dart';
import 'package:food_waste_app/core/app_colors.dart';
import 'package:food_waste_app/core/app_spacing.dart';
import 'package:food_waste_app/core/app_text_styles.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          'Merhaba! Ben EcoGrab asistanıyım. Yemek ürünleri, restoranlar ve siparişlerle ilgili sana yardımcı olabilirim.',
      isUser: false,
    ),
  ];

  bool _isLoading = false;

  static const String _baseUrl = 'http://10.0.2.2:5000';
  static const String _chatEndpoint = '$_baseUrl/api/Chat/ask';

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(text: message, isUser: true));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_chatEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final botAnswer =
            decoded['message'] ??
            decoded['answer'] ??
            decoded['response'] ??
            decoded['content'] ??
            'Cevap alındı ancak metin okunamadı.';

        setState(() {
          _messages.add(
            _ChatMessage(
              text: botAnswer.toString(),
              isUser: false,
            ),
          );
        });
      } else {
        setState(() {
          _messages.add(
            _ChatMessage(
              text: 'Şu anda cevap alınamadı. Backend API bağlantısını kontrol et.',
              isUser: false,
            ),
          );
        });
      }
    } catch (_) {
      setState(() {
        _messages.add(
          _ChatMessage(
            text:
                'Sunucuya bağlanılamadı. Backend çalışıyor mu ve base URL doğru mu kontrol et.',
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
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
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'EcoGrab Asistan',
          style: AppTextStyles.title,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                ),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return _buildTypingBubble();
                  }

                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.editorialGradient,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.asset(
              AppAssets.chatbotRobot,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akıllı Yardımcı',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.surface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ürünler ve siparişler hakkında soru sorabilirsin.',
                  style: AppTextStyles.bodySoft.copyWith(
                    color: AppColors.surface.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryGreen : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: AppTextStyles.body.copyWith(
            color: isUser ? AppColors.surface : AppColors.textDark,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'EcoGrab düşünüyor...',
          style: AppTextStyles.bodySoft,
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Mesaj yaz...',
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.editorialGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.surface,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: AppColors.surface,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({
    required this.text,
    required this.isUser,
  });
}