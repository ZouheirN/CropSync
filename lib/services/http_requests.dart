enum ReturnTypes {
  success,
  error,
  fail,
}

// TODO checkCredentials
Future<ReturnTypes> checkCredentials(String username, String password) async {
  return ReturnTypes.success;
}