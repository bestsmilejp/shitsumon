class ChatRoom {
  String? id;
  String? name;
  String? latestMsgTimestamp;

  ChatRoom({this.id, this.name, this.latestMsgTimestamp});
}

class ChatModel {
  String? id;
  String? idFrom;
  String? timestamp;
  String? content;
  int? type;
  List<dynamic>? likes = [];

  ChatModel(
      {this.id,
      this.idFrom,
      this.timestamp,
      this.content,
      this.type,
      this.likes});
}

class ChatReport {
  String? idFrom;
  String? id;

  ChatReport({this.idFrom, this.id});
}

class BlockModel {
  String? id;
  String? idFrom;

  BlockModel({this.id, this.idFrom});
}
