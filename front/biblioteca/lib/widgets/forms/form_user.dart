import 'package:biblioteca/data/models/turma.dart';
import 'package:biblioteca/data/models/usuario_model.dart';
import 'package:biblioteca/data/providers/usuario_provider.dart';
import 'package:biblioteca/data/services/turmas_service.dart';
import 'package:biblioteca/utils/config.dart';
import 'package:biblioteca/utils/routes.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca/widgets/forms/campo_obrigatorio.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FormUser extends StatefulWidget {
  const FormUser({super.key, this.usuario});
  final Usuario? usuario;

  @override
  State<FormUser> createState() => _FormUserState();
}

class _FormUserState extends State<FormUser> {
  bool isModoEdicao() {
    return widget.usuario != null;
  }

  //variáveis do formulário
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _turmaController = TextEditingController();
  final TextEditingController _turnoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final DateTime _today = DateTime.now();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final List<String> usuarios = <String>[
    TipoDeUsuario.aluno,
    TipoDeUsuario.funcionario,
    TipoDeUsuario.bibliotecario
  ];

  final List<String> turnos = <String>['Manhã', 'Tarde', 'Noite', 'Integral'];

  final TurmasService _turmasService = TurmasService();
  List<Turma> turmas = [];
  bool showTurmas = false;

  Future<void> _loadTurmas(int turno) async {
    var futureTurmas = await _turmasService.fetchTurmas();
    setState(() {
      turmas = futureTurmas.where((turma) => turma.turno == turno).toList();
      _turmaController.text = turmas[0].turma.toString();

      if (!showTurmas) {
        showTurmas = true;
      }
    });
  }

  Future<void> salvar(context) async {
    if (_formKey.currentState!.validate()) {
      String mensagem = "Cadastro realizado com sucesso!";
      UsuarioProvider provider =
          Provider.of<UsuarioProvider>(context, listen: false);

      if (isModoEdicao()) {
        //Editar usuário
        mensagem = 'Registro alterado com sucesso!';
        widget.usuario!.nome = _nomeController.text;
        widget.usuario!.email = _emailController.text;
        widget.usuario!.telefone =
            _telefoneController.text.isEmpty ? null : _telefoneController.text;
        widget.usuario!.dataDeNascimento = _dateController.text.isEmpty
            ? null
            : DateFormat('d/M/y').parse(_dateController.text);

        widget.usuario!.cpf =
            _cpfController.text.isEmpty ? null : _cpfController.text;

        await provider.editUsuario(widget.usuario!);
      } else {
        //Adicionar usuário
        Usuario novoUsuario = Usuario(
          login: _loginController.text,
          cpf: _cpfController.text,
          senha: _passwordController.text,
          nome: _nomeController.text,
          email: _emailController.text,
          telefone: _telefoneController.text,
          dataDeNascimento: _dateController.text.isEmpty
              ? null
              : DateFormat('d/M/y').parse(_dateController.text),
          turma: int.tryParse(_turmaController.text) ?? 0,
          permissao:
              _userTypeController.text == TipoDeUsuario.bibliotecario ? AppConfig.maxPermissoes : 0,
              
        );
        await provider.addUsuario(novoUsuario);
      }
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.usuarios, ModalRoute.withName(AppRoutes.home));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void initState() {
    if (isModoEdicao()) {
      _nomeController.text = widget.usuario!.nome;
      _emailController.text = widget.usuario!.email;

      if (widget.usuario!.cpf.toString() != 'null') {
        _cpfController.text = widget.usuario!.cpf!;
      }

      if (widget.usuario!.telefone.toString() != 'null') {
        _telefoneController.text = widget.usuario!.telefone!;
      }

      if (widget.usuario!.dataDeNascimento.toString() != 'null') {
        _dateController.text = DateFormat('d/M/y')
            .format(widget.usuario!.dataDeNascimento!)
            .toString();
      }

      if (widget.usuario!.getTipoDeUsuario == TipoDeUsuario.aluno) {
        _turnoController.text = widget.usuario!.turno.toString();
        _loadTurmas(widget.usuario!.turno!);
        _turmaController.text = widget.usuario!.turma.toString();
        showTurmas = true;
      }
    } else {
      _userTypeController.text = TipoDeUsuario.aluno;
    }

    super.initState();
  }

  @override
  void dispose() {
    _userTypeController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _dateController.dispose();
    _cpfController.dispose();
    _turmaController.dispose();
    _turnoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de navegação
        const BreadCrumb(
            breadcrumb: ['Início', 'Usuários', 'Novo Usuário'],
            icon: Icons.co_present_rounded),

        // Formulário
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30.0),
                    // Informações de Acesso
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informações de Acesso
                        getBlocoInformacoesDeAcesso(),
                      ],
                    ),
                    const SizedBox(height: 30.0),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informações Pessoais
                        getBlocoInformacoesPessoais(context),
                      ],
                    ),
                    const SizedBox(height: 30.0),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informações Acadêmicas
                        getBlocoInformacoesAcademicas(),
                      ],
                    ),
                    const SizedBox(height: 30.0),

                    // Botões
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Botão Cancelar
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Cancelar",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onInverseSurface,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),

                        // Botão Salvar
                        ElevatedButton(
                          onPressed: () {
                            salvar(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Salvar",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Expanded getBlocoInformacoesPessoais(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informações Pessoais",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),

          // Row 1: Nome + Email + CPF
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    label: CampoObrigatorio(label: "Nome"),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Preencha esse campo";
                    } else if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value)) {
                      return "O nome deve conter apenas letras";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    label: CampoObrigatorio(label: "Email"),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Preencha esse campo";
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return "Insira um email válido";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: TextFormField(
                  controller: _cpfController,
                  decoration: const InputDecoration(
                    labelText: "CPF",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        value.length != 11) {
                      return "Insira um CPF válido";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Row 2: Telefone + Data de Nascimento
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _telefoneController,
                  decoration: const InputDecoration(
                    labelText: "Telefone",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        value.length != 11) {
                      return "Insira um telefone válido";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: "Data de Nascimento",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialEntryMode: DatePickerEntryMode.input,
                      locale: const Locale('pt', 'BR'),
                      initialDate: isModoEdicao()
                          ? widget.usuario!.dataDeNascimento
                          : _today,
                      firstDate: DateTime(1900),
                      lastDate: _today,
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dateController.text =
                            DateFormat('d/M/y').format(pickedDate).toString();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getBlocoInformacoesAcademicas() {
    if (isModoEdicao() &&
            widget.usuario!.getTipoDeUsuario != TipoDeUsuario.aluno ||
        !isModoEdicao() && _userTypeController.text != TipoDeUsuario.aluno) {
      return Container();
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informações Acadêmicas",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),

          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              label: CampoObrigatorio(label: "Turno"),
              border: OutlineInputBorder(),
            ),
            value: _turnoController.text.isEmpty ? null : _turnoController.text,
            items: turnos.map((String turno) {
              return DropdownMenuItem<String>(
                value: (turnos.indexOf(turno) + 1).toString(),
                child: Text(turno),
              );
            }).toList(),
            onChanged: (String? newValue) {
              _turnoController.text = newValue!;
              _loadTurmas(int.parse(_turnoController.text));
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Selecione um turno";
              }

              return null;
            },
          ),
          const SizedBox(height: 10.0),

          // Turma
          getFieldTurmas(),
        ],
      ),
    );
  }

  Widget getFieldTurmas() {
    if (!showTurmas) {
      return Container();
    }

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        label: CampoObrigatorio(label: "Turma"),
        border: OutlineInputBorder(),
      ),
      value: _turmaController.text.isEmpty ? null : _turmaController.text,
      items: turmas.map((Turma turma) {
        return DropdownMenuItem<String>(
          value: turma.turma.toString(),
          child: Text(turma.turmaSemTurno),
        );
      }).toList(),
      onChanged: (String? newValue) {
        _turmaController.text = newValue!;
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Selecione uma turma";
        }
        return null;
      },
    );
  }

  Widget getBlocoInformacoesDeAcesso() {
    if (isModoEdicao()) {
      return Container();
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informações de Acesso",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),

          // Row 1: Tipo de Usuário + Login
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    label: CampoObrigatorio(label: "Tipo de Usuário"),
                    border: OutlineInputBorder(),
                  ),
                  value: _userTypeController.text,
                  items: usuarios.map((String userType) {
                    return DropdownMenuItem<String>(
                      value: userType,
                      child: Text(userType),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    _userTypeController.text = newValue!;
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Selecione um tipo de usuário";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: TextFormField(
                  controller: _loginController,
                  decoration: const InputDecoration(
                    label: CampoObrigatorio(label: "Login "),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Preencha esse campo";
                    } else if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(value)) {
                      return "O login não deve conter caracteres especiais, exceto '.', '_' ou '-'";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Row 2: Senha + Confirmar Senha
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    label: const CampoObrigatorio(label: "Senha"),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Preencha esse campo";
                    } else if (value.length < 8) {
                      return "A senha deve ter pelo menos 8 caracteres";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    label: const CampoObrigatorio(label: "Confirmar Senha"),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_confirmPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Preencha esse campo";
                    } else if (value != _passwordController.text) {
                      return "As senhas não são iguais";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
