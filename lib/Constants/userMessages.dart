import 'dart:ui';

enum Message {
  //messages that will be displayed to user
  error,
  loading,
  noData,
  noMatch
}

class UserMessages {
  //
  static const Map<Message, String> msgs = {
    Message.error: "Something Wrong",
    Message.loading : "Loading",
    Message.noData :"No data",
    Message.noMatch :"No Results match your search"
  };

  static String getMsg(Message message) => msgs[message] ?? "";

}
