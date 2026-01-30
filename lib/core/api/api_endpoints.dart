class ApiEndpoints {
  ApiEndpoints._();
  static const int _port = 3000;

  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  static const Duration connectionTimeout = Duration(seconds: 30);

  static const String comIPAddress = '192.168.1.11';
  static String get serverUrl => 'http://$comIPAddress:$_port/public';

  static String get mediaServerUrl => serverUrl;

  //login signup endpoints

  static const String donorLogin = '/donorusers/login';
  static const String donorRegister = '/donorusers/register';

  static const String organizationLogin = '/organizations/login';
  static const String organizationRegister = '/organizations/register';

  static String donorUploadPhoto = '/donorusers/upload-photo';
  static String organizationUploadPhoto = '/organizations/upload-photo';

  static String profilePicture(String filename) =>
      '$mediaServerUrl/profile_pictures/$filename';
}
