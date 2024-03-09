class ChatRoomModel{
  String? chatroomid;
  Map<String,dynamic>? participants;
  String? lastmessage;
  DateTime? createdon;
  ChatRoomModel(this.chatroomid,this.participants,this.lastmessage,this.createdon);


  ChatRoomModel.fromMap(Map<String,dynamic> map){
    chatroomid=map["chatroomid"];
    participants=map["participants"];
    lastmessage=map["lastmessage"];

    createdon=map["createdon"].toDate();
  }

  Map<String,dynamic> toMap(){
    return{
      "chatroomid": chatroomid,
      "participants": participants,
      "lastmessage": lastmessage,
      "createdon": createdon
    };
  }
}