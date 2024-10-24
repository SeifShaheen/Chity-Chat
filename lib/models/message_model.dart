class MessageModel {
  final String body;
  final String id;
  final String sender;
  MessageModel({required this.sender, required this.id, required this.body});
  factory MessageModel.fromJson(Map<String, dynamic> jsonData) {
    return MessageModel(
        body: jsonData['message'],
        id: jsonData['id'],
        sender: jsonData['sender']);
  }
}
