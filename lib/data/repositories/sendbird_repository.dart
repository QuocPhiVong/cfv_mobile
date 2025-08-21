import 'package:cfv_mobile/data/services/sendbird_service.dart';
import 'package:cfv_mobile/data/responses/sendbird_response.dart';

abstract class ISendbirdRepository {
  Future<void> initialize();
  Future<bool> connectUser(String userId, String nickname);
  Future<List<ChatMessage>> getChatHistory(String channelUrl, {int limit});
  Future<List<ChatMessage>> loadMoreMessages(String channelUrl, {int limit});
  Future<void> sendMessage(String channelUrl, String text);
  Future<List<Conversation>> getConversations();
  Future<String> createConversation(String title, {String? initialMessage});
  Future<void> joinChannel(String channelUrl);
  Stream<ChatMessage> getMessageStream(String channelUrl);
  bool get isUserConnected;
  Future<bool> checkAndRecoverConnection();
  Future<bool> forceReconnect();
  void dispose();
  void stopPolling(String channelUrl);
}

class SendbirdRepository implements ISendbirdRepository {
  final SendbirdService _sendbirdService;

  SendbirdRepository({SendbirdService? sendbirdService})
    : _sendbirdService = sendbirdService ?? SendbirdService.instance;

  @override
  Future<void> initialize() async {
    await _sendbirdService.initialize();
  }

  @override
  Future<bool> connectUser(String userId, String nickname) async {
    return await _sendbirdService.connectUser(userId, nickname);
  }

  @override
  Future<List<ChatMessage>> getChatHistory(String channelUrl, {int limit = 20}) async {
    return await _sendbirdService.getChatHistory(channelUrl, limit: limit);
  }

  @override
  Future<List<ChatMessage>> loadMoreMessages(String channelUrl, {int limit = 20}) async {
    return await _sendbirdService.loadMoreMessages(channelUrl, limit: limit);
  }

  @override
  Future<void> sendMessage(String channelUrl, String text) async {
    await _sendbirdService.sendMessage(channelUrl, text);
  }

  @override
  Future<List<Conversation>> getConversations() async {
    return await _sendbirdService.getConversations();
  }

  @override
  Future<String> createConversation(String title, {String? initialMessage}) async {
    return await _sendbirdService.createConversation(title, initialMessage: initialMessage);
  }

  @override
  Future<void> joinChannel(String channelUrl) async {
    await _sendbirdService.joinChannel(channelUrl);
  }

  @override
  Stream<ChatMessage> getMessageStream(String channelUrl) {
    return _sendbirdService.getMessageStream(channelUrl);
  }

  @override
  bool get isUserConnected => _sendbirdService.isUserConnected;

  @override
  Future<bool> checkAndRecoverConnection() async {
    return await _sendbirdService.checkAndRecoverConnection();
  }

  @override
  Future<bool> forceReconnect() async {
    return await _sendbirdService.forceReconnect();
  }

  @override
  void dispose() {
    _sendbirdService.dispose();
  }

  @override
  void stopPolling(String channelUrl) {
    _sendbirdService.stopPolling(channelUrl);
  }
}
