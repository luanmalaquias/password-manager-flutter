import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gerar_senha/database/credenciais_dao.dart';
import 'package:gerar_senha/model/credenciais.dart';
import 'package:gerar_senha/ui/tela_2_senhas.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _obscurePassword = true;
  final TextEditingController _senhaPrincipal = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }

  _appBar() {
    return AppBar(
      title: const Text("Gerenciador de senhas"),
    );
  }

  _body() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  autofocus: true,
                  validator: (value) => _validarSenha(value),
                  controller: _senhaPrincipal,
                  obscureText: _obscurePassword,
                  obscuringCharacter: "●",
                  decoration: InputDecoration(
                    labelText: "Senha principal",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: (){
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility)
                    )
                  )
                ),
                ElevatedButton(
                    onPressed: () => _verificarSenha(_senhaPrincipal.text),
                    child: const Text('Acessar')
                ),
              ],
          ),
        ),
      ),
    );
  }

  _validarSenha(value)  {
    if(value == null || value.isEmpty){
      return "Informe a senha";
    }
    return null;
  }

  _verificarSenha(senha) async {

    if(_formKey.currentState!.validate()){
      String? senhaBanco = await CredenciaisDAO.getSenhaPrincipal();
      if (senhaBanco == "None" && senha != "") {
        // inserir senha no banco, caso não exista
        CredenciaisDAO.insert(Credenciais(site: "Principal", senha: senha)).then((value) => _dialogSenhaCriada(senha)
        );
      } else if (senhaBanco != "None" && senha == senhaBanco) {
        // acessar a proxima tela
        _onClickIrTelaSenhas();
      } else if (senhaBanco != "None" && senha != senhaBanco) {
        // mostrar mensagem de senha inválida
        _dialogSenhaInvalida();
      }
    }
  }

  _dialogSenhaCriada(senha) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 5),
      content: Text("Essa é sua senha para acessar o aplicativo\n$senha"),
    ));
  }

  _dialogSenhaInvalida() {
    return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      duration: Duration(seconds: 5),
      content: Text("Senha não corresponde"),
    ));
  }

  _onClickIrTelaSenhas() {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => const PasswordScreen())).then((value) {
          _senhaPrincipal.clear();
    });
  }
}
