import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import 'package:twizzle/features/messages/data/models/message_model.dart';
import 'package:twizzle/features/messages/domain/entities/message.dart';
import 'package:twizzle/features/messages/domain/repositories/message_repository.dart';
import 'package:twizzle/features/messages/data/datasources/remote/message_remote_source.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteSource remoteDataSource;
  final String currentUserId; // Needed to identify the other participant

  MessageRepositoryImpl(this.remoteDataSource, this.currentUserId);

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final response = await remoteDataSource.getConversations();
      final List<dynamic> data = response['data'] as List<dynamic>;
      final conversations = data.map((json) => ConversationModel.fromJson(json, currentUserId)).toList();
      return Right(conversations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId) async {
    try {
      final response = await remoteDataSource.getMessages(conversationId);
      final List<dynamic> data = response['data']['items'] as List<dynamic>;
      final messages = data.map((json) => ChatMessageModel.fromJson(json)).toList();
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(String conversationId, String content) async {
    try {
      final response = await remoteDataSource.sendMessage(conversationId, content);
      return Right(ChatMessageModel.fromJson(response['data']));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendImageMessage(String conversationId, String filePath) async {
    try {
      final response = await remoteDataSource.sendImageMessage(conversationId, filePath);
      return Right(ChatMessageModel.fromJson(response['data']));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final response = await remoteDataSource.getUnreadCount();
      return Right(response['data']['unreadCount'] as int);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String conversationId) async {
    try {
      await remoteDataSource.markAsRead(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation>> startConversation(String userId) async {
    try {
      final response = await remoteDataSource.startConversation(userId);
      final conversation = ConversationModel.fromJson(response['data'], currentUserId);
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
