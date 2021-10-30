import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gerar_senha/database/credenciais_dao.dart';
import 'package:gerar_senha/model/credenciais.dart';
import 'package:gerar_senha/utility/util.dart';

class AddPasswordScreen extends StatefulWidget {

  final Credenciais? c;
  const AddPasswordScreen({Key? key, this.c}) : super(key: key);

  // Credenciais? c;
  // AddPasswordScreen({this.c});

  @override
  _AddPasswordScreenState createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {

  final TextEditingController _siteControler = TextEditingController();
  final TextEditingController _senhaControler = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _siteEnable = true;

  @override
  void initState() {
    super.initState();
    _siteControler.text = ((widget.c != null) ? widget.c!.site : "")!;
    _senhaControler.text = ((widget.c != null) ? widget.c!.senha : gerarSenha(10))!;
    if(widget.c != null){
      if(widget.c!.id == 1 || widget.c!.site == "Principal") {
        _siteEnable = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }

  _appBar(){
    return AppBar(
      title: Text(widget.c == null ? "Adicionar" : "Atualizar ${widget.c!.site}")
    );
  }

  _body(){

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              enabled: _siteEnable,
              controller: _siteControler,
              autofocus: widget.c == null ? true : false,
              validator: (value) => _validarCredenciais(value, "site"),
              decoration: const InputDecoration(
                  labelText: "Site/Plataforma",
                  hintText: "ex: Google")),
            TextFormField(
              controller: _senhaControler,
              autofocus: widget.c != null ? true : false,
              validator: (value) => _validarCredenciais(value, "senha"),
              decoration: const InputDecoration(
                  labelText: "Senha",
                  hintText: "ex: t&Pi9hRm1L")),
            Row(
              children: [
                Expanded(child: TextButton(
                  onPressed: (){
                    _senhaControler.text = gerarSenha(10);
                  },
                  child: Text(widget.c == null ? "Quero outra" : "Gerar outra"))),
                Expanded(child: ElevatedButton(
                  onPressed: () => _onClickSaveCredenciais(),
                  child: Text(widget.c == null ? "Quero essa" : "Atualizar"))),
              ],
            )
          ],
        ),
      ),
    );
  }

  _validarCredenciais(c, String campo){
    if(c == null || c.isEmpty){
      return "Por favor, insira este campo";
    } else if("$c".toLowerCase() == "principal" && campo == "site"){
      return "Não pode salvar com este nome";
    }
    return null;
  }

  _onClickSaveCredenciais(){
    if(_formKey.currentState!.validate()){
      if(widget.c == null){
        _siteControler.text = "${_siteControler.text[0].toUpperCase()}${_siteControler.text.substring(1)}";
        Credenciais c = Credenciais(site: _siteControler.text, senha: _senhaControler.text);
        CredenciaisDAO.insert(c).then((value) => Navigator.pop(context));
      } else {
        Credenciais c = Credenciais(id: widget.c!.id, site: _siteControler.text, senha: _senhaControler.text);
        CredenciaisDAO.update(c).then((value) => Navigator.pop(context));
      }
    }
  }
}
