import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabix_cliente_app/core/providers/auth_provider.dart';
import 'package:sabix_cliente_app/core/providers/chat_provider.dart';
import 'package:sabix_cliente_app/presentation/widgets/chat/chat_bubble.dart';
import 'package:sabix_cliente_app/presentation/widgets/chat/chat_input_field.dart';
import 'package:sabix_cliente_app/presentation/widgets/loading_widget.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String orderId;
  final String title;
  final String jwtToken;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.orderId,
    required this.title,
    required this.jwtToken,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  late ChatProvider _chatProvider;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initChat();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Guardamos la referencia segura del Provider mientras el contexto está activo
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
  }

  Future<void> _initChat() async {
    if (!mounted) return;
    setState(() => _hasError = false);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.currentUser?.id?.toString() ?? '';

      // Inicializa la carga de mensajes y conecta el WebSocket
      await _chatProvider.initChatScreen(
        widget.conversationId,
        widget.jwtToken,
        currentUserId,
      );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void dispose() {
    // Usamos la referencia guardada para desconectar el socket sin consultar el BuildContext ya desmontado
    _chatProvider.leaveChatScreen();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSupportDialog(BuildContext context, ChatProvider chatProvider) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Solicitar Soporte'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Escribe la razón de tu solicitud...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isNotEmpty) {
                final success = await chatProvider.requestSupport(
                  widget.conversationId,
                  reasonController.text.trim(),
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Solicitud de soporte enviada'
                            : 'Error al solicitar soporte',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.id?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            Text(
              'Pedido #${widget.orderId}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'support') {
                _showSupportDialog(context, _chatProvider);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'support',
                child: Row(
                  children: [
                    Icon(Icons.headset_mic, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Solicitar Soporte'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading) {
            return const LoadingWidget();
          }

          if (_hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No se pudieron cargar los mensajes.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _initChat,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: chatProvider.messages.isEmpty
                    ? const Center(
                        child: Text('No hay mensajes aún. ¡Escribe uno!'),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12.0),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatProvider.messages[index];
                          return ChatBubble(message: message);
                        },
                      ),
              ),
              ChatInputField(
                onSendMessage: (content) async {
                  await chatProvider.sendTextMessage(
                    widget.conversationId,
                    content,
                    currentUserId,
                  );
                  _scrollToBottom();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}