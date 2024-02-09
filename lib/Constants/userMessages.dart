
enum Message {
  //messages that will be displayed to user
  error,
  loading,
  noData,
  noBranches
}

class UserMessages {
  //
  static const Map<Message, String> msgs = {
    Message.error: "Something Wrong",
    Message.loading : "Loading",
    Message.noData :"No data",
    Message.noBranches :"No Branches Available"
  };

  static String getMsg(Message message) => msgs[message] ?? "";

}
