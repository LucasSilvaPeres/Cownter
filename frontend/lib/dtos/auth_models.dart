enum AuthMode {
  signup,
  login,
  forgotPass,
  checkEmail,
}

class AuthFormData {
  String name = '';
  String email = '';
  String password = '';
  String namefazenda = '';
  String contato = '';
  String numerocabecas = '';
  String enderecofazenda = '';
  String municipiofazenda = '';
  String estadofazenda = '';

  AuthMode _mode = AuthMode.login;

  bool get isLogin {
    return _mode == AuthMode.login;
  }

  bool get isSignup {
    return _mode == AuthMode.signup;
  }

  bool get isForgotPass {
    return _mode == AuthMode.forgotPass;
  }

  bool get isCheckEmail {
    return _mode == AuthMode.checkEmail;
  }

  void toggleAuthMode(AuthMode variavel) {
    _mode = variavel;
  }
}
