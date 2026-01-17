class ApiEndpoints {


  ApiEndpoints._();
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  static const Duration connectionTimeout = Duration(seconds: 30);


  //login signup endpoints


  static const String donorLogin = '/donorusers/login';
  static const String donorRegister = '/donorusers/register';

  static const String organizationLogin = '/organizations/login';
  static const String organizationRegister = '/organizations/register';
}
