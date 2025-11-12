import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:hack_the_future_starter/features/chat/models/chat_message.dart';
import 'package:hack_the_future_starter/features/chat/services/genui_service.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({GenUiService? service}) : _service = service ?? GenUiService();

  final GenUiService _service;

  late final Catalog _catalog;
  late final GenUiManager _manager;
  late final GenUiConversation _conversation;

  GenUiHost get host => _conversation.host;

  ValueListenable<bool> get isProcessing => _conversation.isProcessing;

  final List<ChatMessageModel> _messages = [];

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  void init() {
    _catalog = _service.createCatalog();
    _manager = GenUiManager(catalog: _catalog);
    final generator = _service.createContentGenerator(catalog: _catalog);

    _conversation = GenUiConversation(
      genUiManager: _manager,
      contentGenerator: generator,
      onSurfaceAdded: (s) {
        _messages.add(ChatMessageModel(surfaceId: s.surfaceId));
        notifyListeners();
      },
      onTextResponse: (text) {
        _messages.add(ChatMessageModel(text: text));
        notifyListeners();
      },
      onError: (err) {
        _messages.add(
          ChatMessageModel(text: err.error.toString(), isError: true),
        );
        notifyListeners();
      },
    );
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    _messages.add(ChatMessageModel(text: text, isUser: true));
    notifyListeners();
    await _conversation.sendRequest(UserMessage([TextPart(text)]));
  }

  void disposeConversation() {
    _conversation.dispose();
  }
}
