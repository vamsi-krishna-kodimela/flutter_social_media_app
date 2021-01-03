import 'package:flutter/material.dart';

class ChatsProvider with ChangeNotifier{
  List<String> _chats = [];

  void addChatRoom(String roomId){
    _chats.add(roomId);
    notifyListeners();
  }

  int getCurrentChatsCount(){
    return _chats.length;
  }

  void clearChats(){
    _chats=[];
  }


}