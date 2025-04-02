import 'package:biblioteca/data/providers/login_provider.dart';
import 'package:biblioteca/data/services/redefinir_senha_service.dart';
import 'package:biblioteca/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormRedefinirSenhaCodigo extends StatefulWidget {
  const FormRedefinirSenhaCodigo({super.key});

  @override
  State<FormRedefinirSenhaCodigo> createState() =>
      _FormRedefinirSenhaCodigoState();
}

class _FormRedefinirSenhaCodigoState extends State<FormRedefinirSenhaCodigo> {
  final _codigoController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool showTelaCodigo = false;
  RedefinirSenhaService service = RedefinirSenhaService();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Redefinir senha',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 42.0, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(
            height: 20.0,
          ),
          const Text(
            'Insira o código para redefinir',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _codigoController,
            decoration: const InputDecoration(
              labelText: 'Codigo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _novaSenhaController,
            decoration: const InputDecoration(
              labelText: 'Nova Senha',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                service.redefinirSenha(
                    _codigoController.text, _novaSenhaController.text);
                
        Provider.of<LoginProvider>(context, listen: false).setModo(ModoLogin.login);
              },
              style: AppTheme.btnPrimary(context),
              child: Text(
                'Redefinir',
                style: AppTheme.btnPrimaryText(context),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              // Voltar à tela de login
              Provider.of<LoginProvider>(context, listen: false).setModo(ModoLogin.login);
            },
            child: const Text('Voltar para o Login'),
          ),
        ],
      ),
    );
  }
}
