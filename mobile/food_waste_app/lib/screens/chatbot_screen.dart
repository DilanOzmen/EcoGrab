import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:food_waste_app/core/app_assets.dart';
import 'package:food_waste_app/core/app_colors.dart';
import 'package:food_waste_app/core/app_spacing.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'package:food_waste_app/core/app_text_styles.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final AnimationController _animationController;
  late final Animation<double> _robotFloat;

  bool _isLoading = false;

  static const String _baseUrl = 'http://10.0.2.2:5141';
  static const String _chatEndpoint = '$_baseUrl/api/Chat/ask';

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          'Merhaba! Ben EcoGrab asistanıyım. Yakındaki ürünler, restoranlar ve siparişlerin hakkında yardımcı olabilirim.',
      isUser: false,
    ),
  ];

 @override
void initState() {
  super.initState();

  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  _robotFloat = Tween<double>(
    begin: -4,
    end: 4,
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ),
  );
}

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
        body: jsonEncode({
          'userMessage': message,
          'latitude': AppState.latitude,
          'longitude': AppState.longitude,
          'radiusKm': 5,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final answer =
            decoded['aiResponse'] ??
            decoded['AiResponse'] ??
            decoded['message'] ??
            decoded['response'] ??
            'Cevap alındı ama metin okunamadı.';

        setState(() {
          _messages.add(
            _ChatMessage(
              text: answer.toString(),
              isUser: false,
            ),
          );
        });
      } else {
        setState(() {
          _messages.add(
            _ChatMessage(
              text:
                  'Şu anda cevap alınamadı. Backend API bağlantısını kontrol et.',
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
                'Sunucuya bağlanılamadı. Backend açık mı ve port 5141 doğru mu kontrol et.',
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
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
            Expanded(child: _buildMessageList()),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _robotFloat,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _robotFloat.value),
                child: child,
              );
            },
            child: Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Lottie.asset(
                AppAssets.chatbotRobotLottie,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akıllı Yardımcı',
                  style: AppTextStyles.title.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Konumuna göre ürün ve restoran önerileri sorabilirsin.',
                  style: AppTextStyles.bodySoft.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == _messages.length) {
          return _buildTypingBubble();
        }

        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        constraints: const BoxConstraints(maxWidth: 285),
        decoration: BoxDecoration(
          gradient: isUser ? AppColors.editorialGradient : null,
          color: isUser ? null : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(isUser ? 22 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 22),
          ),
          border: isUser ? null : Border.all(color: AppColors.surfaceContainer),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: AppTextStyles.body.copyWith(
            color: isUser ? Colors.white : AppColors.textDark,
            height: 1.45,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.surfaceContainer),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child:Lottie.asset(
  AppAssets.chatbotRobotLottie,
  fit: BoxFit.contain,
),
            ),
            const SizedBox(width: 8),
            Text(
              'EcoGrab düşünüyor...',
              style: AppTextStyles.bodySoft,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Mesaj yaz...',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(
                    color: AppColors.surfaceContainer,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(
                    color: AppColors.surfaceContainer,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.editorialGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.20),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(15),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
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