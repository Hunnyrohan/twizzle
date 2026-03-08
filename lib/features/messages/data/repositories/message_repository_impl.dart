import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import 'package:twizzle/features/messages/data/models/message_model.dart';
import 'package:twizzle/features/messages/domain/entities/message.dart';
import 'package:twizzle/features/messages/domain/repositories/message_repository.dart';
import 'package:twizzle/features/messages/data/datasources/remote/message_remote_source.dart';

import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteSource remoteDataSource;
  final UserProvider userProvider;

  MessageRepositoryImpl(this.remoteDataSource, this.userProvider);

  String get currentUserId => userProvider.user?.id ?? '';

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      print('MessageRepo: Fetching conversations...');
      final response = await remoteDataSource.getConversations();
      print('MessageRepo: Response received: ${response['success']}');
      
      final List<dynamic> data = response['data'] as List<dynamic>;
      print('MessageRepo: Parsing ${data.length} conversations for UserID: $currentUserId');
      
      final conversations = data.map((json) {
        try {
          return ConversationModel.fromJson(json, currentUserId);
        } catch (e) {
          print('MessageRepo: Error parsing conversation item: $e');
          print('MessageRepo: Item raw data: $json');
          rethrow;
        }
      }).toList();
      
      return Right(conversations);
    } catch (e) {
      print('MessageRepo: getConversations FAILED: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId) async {
    try {
      print('MessageRepo: Fetching messages for $conversationId...');
      final response = await remoteDataSource.getMessages(conversationId);
      
      final List<dynamic> data = response['data']['items'] as List<dynamic>;
      print('MessageRepo: Smallest message set: ${data.length} items');
      
      final messages = data.map((json) {
        try {
          return ChatMessageModel.fromJson(json);
        } catch (e) {
           print('MessageRepo: Error parsing message item: $e');
           rethrow;
        }
      }).toList();
      
      return Right(messages);
    } catch (e) {
      print('MessageRepo: getMessages FAILED: $e');
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

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId, String type) async {
    try {
      await remoteDataSource.deleteMessage(messageId, type);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
