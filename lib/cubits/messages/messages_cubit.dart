import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_chat/models/message.dart';
import 'package:supabase_chat/utils/constants.dart';
import 'package:supabase_chat/utils/messages_provider.dart';

part 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit({required MessagesProvider messagesProvider})
      : _messagesProvider = messagesProvider,
        super(MessagesInitial());

  final MessagesProvider _messagesProvider;

  StreamSubscription<List<Message>>? _messagesSubscription;
  List<Message> _messages = [];

  late final String _roomId;
  late final String _userId;

  void setMessagesListener(String roomId) {
    _roomId = roomId;

    _userId = supabase.auth.user()!.id;

    _messagesSubscription =
        _messagesProvider.subscribe(roomId).listen((messages) {
      _messages = messages;
      if (_messages.isEmpty) {
        emit(MessagesEmpty());
      } else {
        emit(MessagesLoaded(_messages));
      }
    });
  }

  Future<void> sendMessage(String text) async {
    /// Add message to present to the user right away
    final message = Message(
      id: '',
      roomId: _roomId,
      userId: _userId,
      content: text,
      createdAt: DateTime.now(),
      isMine: true,
    );
    _messages.insert(0, message);
    emit(MessagesLoaded(_messages));
    final result =
        await supabase.from('messages').insert(message.toMap()).execute();
    final error = result.error;
    if (error != null) {
      emit(MessagesError('Error submitting message.'));
      _messages.removeLast();
      emit(MessagesLoaded(_messages));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
