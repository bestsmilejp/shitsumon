
class Config {
//  static int chattype = 0; //(0: Group chat, 1: 1vs1 chat)
  static String prefsInit = "prefsInit";
  static String prefsNewNotificationChat = "newNotificationChat";
//  static String prefsGroupId = "groupId";
  static String prefsNewNotificationBlog = "newNotificationBlog";
//  static String prefsAdminFlag = "adminflag";
  static String prefsEditingMsg = "editingMsg";
  static String prefsId = "id";
  static String prefsPushToken = "pushToken";
  static String prefsPhotoUrl = "photoUrl";
  static String prefsNickname = "nickname";
  static String prefsEmail = "email";
  static String prefsAboutMe = "aboutMe";
//  static Color primaryColor = Colors.white;
//  static Color accentColor =  Color(0xff4fc3f7);
//  static Color gradientStartColor = accentColor;
//  static Color gradientEndColor = Color(0xff6aa8fd);
//  static Color errorGradientStartColor = Color(0xffd50000);
//  static Color errorGradientEndColor = Color(0xff9b0000);
//  static Color secondaryColor = Colors.black;
//  static Color primaryTextColor = Colors.black;
//  static Color primaryTextColorLight = Colors.white;
//  static Color secondaryTextColor = Colors.black87;
//  static Color secondaryTextColorLight = Colors.white70;
//  static Color hintTextColor = Colors.black54;
//  static Color hintTextColorLight = Colors.white70;
//  static Color primaryBackgroundColor = Colors.white;
//  static Color selfMessageBackgroundColor = Color(0xff4fc3f7);
//  static Color otherMessageBackgroundColor = Colors.white;
//  static Color selfMessageColor = Colors.white;
//  static Color otherMessageColor = Color(0xff3f3f3f);
//  static Color greyColor = Colors.grey;
//  static Color chatBackgroundColor = Color(0xfffafafa)  ;
  static String getChatRoomeName(chatRoomId) {
    if(chatRoomId == "0TbNumLeDage4RsA0jpm"){
      return "お知らせ";
    }else if(chatRoomId == "IdOwu5yTjnT2Uk0gyEGl"){
      return "はじめに";
    }else if(chatRoomId == "mp9zstvYj0l4f6fWkEzK"){
      return "特典＆プレゼント";
    }else{
      return "";
    }
  }
}

class Constants{
  static const firstRun = "firstRun";
  static const sessionUid = "sessionUid";
  static const sessionUsername = 'sessionUsername';
  static const sessionName = 'sessionName';
  static const sessionProfilePictureUrl = 'sessionProfilePictureUrl';

  static const configDarkMode = 'configDarkMode';
  static const configMessagePeek = 'configMessagePeek';
  static const configMessagePaging = 'configMessagePaging';
  static const configImageCompression = 'configImageCompression';
  // static String downloadsDirPath;
  // static String cacheDirPath;
}
