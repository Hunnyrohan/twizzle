import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import 'package:twizzle/features/messages/domain/entities/message.dart';

abstract class MessageRepository {
  Future<Either<Failure, List<Conversation>>> getConversations();
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId);
  Future<Either<Failure, ChatMessage>> sendMessage(String conversationId, String content);
  Future<Either<Failure, ChatMessage>> sendImageMessage(String conversationId, String filePath);
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, void>> markAsRead(String conversationId);
  Future<Either<Failure, Conversation>> startConversation(String userId);
  Future<Either<Failure, void>> deleteMessage(String messageId, String type);
}
