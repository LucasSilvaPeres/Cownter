import 'package:flutter/material.dart';

import '../dtos/auth_models.dart';
import 'recover_pass.dart';
import '../utils/appRoutes.dart';

class AuthForm extends StatefulWidget {
  final void Function(AuthFormData) onSubmit;

  const AuthForm({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _formData = AuthFormData();

  void _submit() {
    final _isValid = _formKey.currentState?.validate() ?? false;
    if (!_isValid) return;

    widget.onSubmit(_formData);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Theme.of(context).errorColor,
    ));
  }

  void onRecovered() {
    setState(() {
      _formData.toggleAuthMode(AuthMode.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          gradient: LinearGradient(colors: [
            Color.fromARGB(227, 255, 255, 255),
            Color.fromARGB(189, 205, 205, 205),
          ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 600,
            child: Column(children: [
              _formData.isLogin || _formData.isSignup
                  ? Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        if (_formData.isSignup)
                          Column(
                            children: [
                              const Text(
                                "Cadastre seus Dados!",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.normal),
                                key: const ValueKey('name'),
                                initialValue: _formData.name,
                                validator: (value) {
                                  final name = value ?? '';
                                  if (name.trim().length <= 5) {
                                    return 'Nome  Invalido';
                                  }
                                  return null;
                                },
                                onChanged: ((value) => _formData.name = value),
                                decoration: const InputDecoration(
                                    labelText: 'Nome',
                                    labelStyle:
                                        TextStyle(color: Colors.black54)),
                              ),
                              TextFormField(
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.normal),
                                key: const ValueKey('namefazenda'),
                                initialValue: _formData.namefazenda,
                                validator: (value) {
                                  final name = value ?? '';
                                  if (name.trim().length <= 5) {
                                    return 'Nome da Fazenda  Invalido';
                                  }
                                  return null;
                                },
                                onChanged: ((value) =>
                                    _formData.namefazenda = value),
                                decoration: const InputDecoration(
                                    labelText: 'Nome da Fazenda',
                                    labelStyle:
                                        TextStyle(color: Colors.black54)),
                              ),
                              TextFormField(
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.normal),
                                key: const ValueKey('contato'),
                                initialValue: _formData.contato,
                                validator: (value) {
                                  final name = value ?? '';
                                  if (name.trim().length <= 10) {
                                    return 'Telefone  Invalido';
                                  }
                                  return null;
                                },
                                onChanged: ((value) =>
                                    _formData.contato = value),
                                decoration: const InputDecoration(
                                    labelText: 'Telefone de contato (com ddd)',
                                    labelStyle:
                                        TextStyle(color: Colors.black54)),
                              ),
                              TextFormField(
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.normal),
                                key: const ValueKey('numerocabecas'),
                                initialValue: _formData.numerocabecas,
                                validator: (value) {
                                  final name = value ?? '';
                                  if (name.trim() == "") {
                                    return 'Insira o número aproximado de cabeças';
                                  }
                                  return null;
                                },
                                onChanged: ((value) =>
                                    _formData.numerocabecas = value),
                                decoration: const InputDecoration(
                                    labelText: 'Número de cabeças (aproximado)',
                                    labelStyle:
                                        TextStyle(color: Colors.black54)),
                              ),
                              TextFormField(
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.normal),
                                key: const ValueKey('enderecofazenda'),
                                initialValue: _formData.enderecofazenda,
                                validator: (value) {
                                  final name = value ?? '';
                                  if (name.trim().length <= 5) {
                                    return 'Endereço  Inválido';
                                  }
                                  return null;
                                },
                                onChanged: ((value) =>
                                    _formData.enderecofazenda = value),
                                decoration: const InputDecoration(
                                    labelText: 'Endereço da Fazenda',
                                    labelStyle:
                                        TextStyle(color: Colors.black54)),
                              ),
                              TextFormField(
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.normal),
                                key: const ValueKey('municipiofazenda'),
                                initialValue: _formData.municipiofazenda,
                                validator: (value) {
                                  final name = value ?? '';
                                  if (name.trim().length <= 5) {
                                    return 'Nome da Fazenda  Invalido';
                                  }
                                  return null;
                                },
                                onChanged: ((value) =>
                                    _formData.municipiofazenda = value),
                                decoration: const InputDecoration(
                                    labelText: 'Município da Fazenda',
                                    labelStyle:
                                        TextStyle(color: Colors.black54)),
                              ),
                              TextFormField(
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.normal),
                                key: const ValueKey('estadofazenda'),
                                initialValue: _formData.estadofazenda,
                                validator: (value) {
                                  final name = value ?? '';
                                  if (name.trim().length <= 1) {
                                    return 'Estado Invalido';
                                  }
                                  return null;
                                },
                                onChanged: ((value) =>
                                    _formData.estadofazenda = value),
                                decoration: const InputDecoration(
                                    labelText: 'Estado da Fazenda',
                                    labelStyle:
                                        TextStyle(color: Colors.black54)),
                              ),
                            ],
                          ),
                        TextFormField(
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                            fontWeight: FontWeight.normal,
                          ),
                          key: const ValueKey('e-mail'),
                          initialValue: _formData.email,
                          onChanged: ((value) => _formData.email = value),
                          validator: (value) {
                            final email = value ?? '';
                            if (email.trim().length <= 5 &&
                                !email.contains('@')) {
                              return 'E-mail Invalido';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'E-mail',
                              labelStyle: TextStyle(color: Colors.black54)),
                        ),
                        TextFormField(
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                              fontWeight: FontWeight.normal),
                          key: const ValueKey('password'),
                          initialValue: _formData.password,
                          onChanged: ((value) => _formData.password = value),
                          validator: (value) {
                            final pass = value ?? '';
                            if (pass.trim().length <= 6) {
                              return 'Senha não permitida';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Senha',
                              labelStyle: TextStyle(color: Colors.black54)),
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        ElevatedButton(
                          onPressed: _submit,
                          child: _formData.isLogin
                              ? const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    fontSize: 24,
                                  ),
                                )
                              : const Text(
                                  'Enviar Contato',
                                  style: TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                        ),
                        !_formData.isSignup
                            ? TextButton(
                                onPressed: () {
                                  setState(() {
                                    _formData
                                        .toggleAuthMode(AuthMode.forgotPass);
                                  });
                                  //Navigator.of(context).pushNamed(AppRoutes.EsqueceuSenha);
                                },
                                child: const Text("Esqueceu a senha?"),
                              )
                            : Container(),
                      ],
                    )
                  : Container(),
              _formData.isForgotPass
                  ? ResetPasswordScreen(onRecovered: onRecovered)
                  : Container(),

//-------------------------------- rodapé do login

              _formData.isLogin
                  ? TextButton(
                      onPressed: () {
                        setState(() {
                          _formData.toggleAuthMode(AuthMode.signup);
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Column(
                          children: const [
                            Text(
                              'Quer conhecer o Cownter?',
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                            Text(
                              'Cadastre aqui seus dados para entrarmos em contato!',
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ))
                  : Container(),
              _formData.isSignup
                  ? TextButton(
                      onPressed: () {
                        setState(() {
                          _formData.toggleAuthMode(AuthMode.login);
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Text(
                          'Já é cadastrado? Entre com e-mail e senha',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ))
                  : Container(),
              _formData.isForgotPass
                  ? TextButton(
                      onPressed: () {
                        setState(() {
                          _formData.toggleAuthMode(AuthMode.login);
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Text(
                          'Já é cadastrado? Entre com e-mail e senha',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ))
                  : Container()
            ]),
          ),
        ),
      ),
    );
  }
}
