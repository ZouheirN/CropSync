enum ReturnTypes {
  success,
  error,
  fail,
}

class ApiRequests {
  static Future<ReturnTypes> checkCredentials(String username,
      String password) async {
    return ReturnTypes.success;
  }
}