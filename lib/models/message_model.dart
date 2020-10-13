import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{
  final String message;
  final String senderId;
  final Timestamp postedOn;
  final int type;

  MessageModel({this.message, this.senderId, this.postedOn, this.type});
}