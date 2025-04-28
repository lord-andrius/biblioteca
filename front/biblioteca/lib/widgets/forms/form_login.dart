import 'package:biblioteca/data/models/login_model.dart';
import 'package:biblioteca/data/providers/auth_provider.dart';
import 'package:biblioteca/data/providers/login_provider.dart';
import 'package:biblioteca/data/services/auth_service.dart';
import 'package:biblioteca/utils/assets.dart';
import 'package:biblioteca/utils/routes.dart';
import 'package:biblioteca/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormLogin extends StatefulWidget {
  AuthService? authService;
  FormLogin({
    super.key,
    authService
  });

  @override
  State<FormLogin> createState() => _FormLoginState();
}

class _FormLoginState extends State<FormLogin> {
  //Variáveis do Formulário
  final _formLoginKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _visiblePassword = false;

  //Variáveis de requisição
  late AuthService _authService;
  Login? _login;

  //Provider
  late AuthProvider _authProvider = AuthProvider();

  void tooglePassword() {
    setState(() {
      _visiblePassword = !_visiblePassword;
    });
  }

  String? isNotNull(campo) {
    if (campo == null || campo.isEmpty) {
      return 'Preencha esse campo';
    }
    return null;
  }

  void showError(error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.8),
      ),
    );
  }

  void _autenticar(login, senha) async {
    try {
      final futureLogin = await _authService.doLogin(login, senha);

      setState(() {
        _login = futureLogin;

        if (_login!.aceito) {
          _authProvider.login(_login!.idSessao, login);
          Future.delayed(
            const Duration(milliseconds: 200),
            () => Navigator.pushReplacementNamed(context, AppRoutes.home),
          );
        } else {
          showError('Usuário e/ou senha incorretos.');
        }
      });
    } catch (e) {
      print("$e");
      showError('Não foi possível conectar ao banco de dados no momento. Por favor, tente novamente mais tarde');
    }
  }

  @override
  void initState() {
    _authService = AuthService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    return Form(
      key: _formLoginKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset(
                AppAssets.logo,
                scale: 2.5,
              ),
              Container(
                width: 2,
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Image.asset(
                AppAssets.logoEscola,
                scale: 2.5,
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Text('Entre com o seu usuário e senha'),
          const SizedBox(
            height: 30,
          ),
          TextFormField(
            controller: _userController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Usuário',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (user) => isNotNull(user),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Senha',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: () {
                  tooglePassword();
                },
                icon: Icon(
                    _visiblePassword ? Icons.visibility_off : Icons.visibility),
              ),
            ),
            obscureText: !_visiblePassword,
            validator: (pass) => isNotNull(pass),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formLoginKey.currentState!.validate()) {
                  _autenticar(_userController.text, _passwordController.text);
                }
              },
              style: AppTheme.btnPrimary(context),
              child: Text(
                'Entrar',
                style: AppTheme.btnPrimaryText(context),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Provider.of<LoginProvider>(context, listen: false)
                  .setModo(ModoLogin.redefinirSenha);
            },
            child: Text(
              'Esqueceu sua senha?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
