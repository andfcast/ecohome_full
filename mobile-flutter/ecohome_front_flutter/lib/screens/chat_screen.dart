import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class ChatScreen extends StatefulWidget {
  final String currentUserEmail;
  final VoidCallback onLogout;

  const ChatScreen({
    super.key,
    required this.currentUserEmail,
    required this.onLogout,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late socket_io.Socket _socket;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isConnected = false;
  String? _jwtToken;

  final String _apiUrl = 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final prefs = await SharedPreferences.getInstance();
    _jwtToken = prefs.getString('jwt_token');

    if (_jwtToken == null) return;

    // 1. Cargar historial de mensajes por HTTP
    await _fetchHistory();

    // 2. Conectar por Socket.IO
    _connectSocket();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/messages/history'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List historyData = [];

        if (data is List) {
          historyData = data;
        } else if (data['status'] == 'success' || data['data'] != null) {
          historyData = data['data'] ?? [];
        }

        setState(() {
          _messages = List<Map<String, dynamic>>.from(historyData);
        });

        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error al cargar historial: $e');
    }
  }

  void _connectSocket() {
    _socket = socket_io.io(
      'http://localhost:3000',
      socket_io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': _jwtToken})
          .setExtraHeaders({'Authorization': 'Bearer $_jwtToken'})
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      debugPrint('Conectado a Socket.IO');
      if (mounted) setState(() => _isConnected = true);
    });

    // Escuchar el evento idéntico al de React
    _socket.on('receive-message', (data) {
      if (mounted) {
        setState(() {
          _messages.add(Map<String, dynamic>.from(data));
        });
        _scrollToBottom();
      }
    });

    _socket.onDisconnect((_) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    });
  }

  void _handleSendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Emitir con la misma estructura y nombre de evento que en React
    _socket.emit('new-message', {'content': text});
    _messageController.clear();
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

  @override
  void dispose() {
    _socket.off('connect');
    _socket.off('disconnect');
    _socket.off('receiveMessage');
    
    _socket.disconnect();
    _socket.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: const Text(
          'EcoHome Store - Chat Corporativo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          Chip(
            avatar: const Icon(Icons.account_circle, color: Colors.white, size: 18),
            label: Text(
              widget.currentUserEmail,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
            backgroundColor: Colors.white.withValues(alpha: 0.2),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de estado del canal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            width: double.infinity,
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Canal General (Ventas • Logística • Soporte)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Lista de Mensajes (Historial + Real-time)
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final senderEmail = msg['user_email'] ?? msg['user'] ?? 'Usuario';
                final isMe = senderEmail == widget.currentUserEmail;
                final textContent = msg['text'] ?? msg['content'] ?? '';

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              senderEmail,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.teal[100] : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: Radius.circular(isMe ? 12 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 12),
                            ),
                            border: Border.all(
                              color: isMe ? Colors.teal[200]! : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            textContent,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Formulario de envío
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje para el equipo...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (_) => _handleSendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _handleSendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Enviar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}