import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gerar_senha/database/credenciais_dao.dart';
import 'package:gerar_senha/model/credenciais.dart';
import 'package:gerar_senha/ui/tela_3_adicionar.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  CredenciaisDAO credenciaisDAO = CredenciaisDAO();
  List<Credenciais>? _credenciais;
  final TextEditingController _pesquisarControler = TextEditingController();
  final List<bool> _listPasswordVisible = [];

  var brightness = SchedulerBinding.instance!.window.platformBrightness;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(_pesquisarControler.text),
      floatingActionButton: _floatingActionButton(),
    );
  }

  _appBar() {
    return AppBar(
      title: const Text("Senhas salvas"),
      actions: [
        IconButton(onPressed: () => _dialogHelp(),
            icon: const Icon(Icons.help_outline)
        )
      ],
    );
  }

  _dialogHelp(){
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text("Dicas"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text("Clique", style: TextStyle(fontWeight: FontWeight.bold),),
                Text("Alterar senha\n"),
                Text("Clique longo", style: TextStyle(fontWeight: FontWeight.bold),),
                Text("Copiar senha\n"),
                Text("Arrastar para o lado", style: TextStyle(fontWeight: FontWeight.bold),),
                Text("Deletar senha\n"),
            ]),
            actions: <Widget>[
              ElevatedButton(
                  child: const Text("Entendi"),
                  onPressed: () {
                    Navigator.pop(context);
                  })]);});
  }

  _body(String? pesquisa) {
    return FutureBuilder<List<Credenciais>>(
      future: CredenciaisDAO.select(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            break;

          case ConnectionState.waiting:
            return Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      CircularProgressIndicator(),
                      Text("Carregando")]));

          case ConnectionState.active:
            break;

          case ConnectionState.done:
            return _listItens(snapshot, pesquisa!);
        } // switch
        return const Text("Erro desconhecido");
      }, // builder
    );
  }

  _floatingActionButton() {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        _onClickIrTelaAdicionar();
      },
    );
  }

  _listItens(snapshot, String pesquisa){
    _credenciais = snapshot.data;
    List<Credenciais> crList = [];
    if(pesquisa!=""){
      for(Credenciais c in _credenciais!){
        if(c.site!.toLowerCase().contains(pesquisa.toLowerCase())){
          crList.add(c);
          _listPasswordVisible.add(false);
        }
      }
    }else{
      crList = _credenciais!;
      for(int i=0; i<_credenciais!.length; i++){
        _listPasswordVisible.add(false);
      }
    }

    return Column(
      children: [
        _seachCard(),
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: crList.length,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            itemBuilder: (context, index) {
              Credenciais c = crList[index];
              return Dismissible(
                key:  UniqueKey(),
                child: _itemCard(c, index),
                onDismissed: (DismissDirection direction) {
                  if(index==0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      duration: Duration(seconds: 5),
                      content: Text("Não é possivel deletar a senha principal."),
                    ));
                  } else {
                    CredenciaisDAO.delete(c.id);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(seconds: 3),
                      content: Text("Deletado ${c.site}"),
                      action: SnackBarAction(
                        label: 'Desfazer',
                        onPressed: () {
                          CredenciaisDAO.insert(c);
                          setState(() {
                            _desativarVisualizacaoSenhas();
                          });
                        },
                      ),
                    ));
                  }
                  setState(() {
                    _desativarVisualizacaoSenhas();
                  });
                },
              );
            }),
      ],
    );
  }

  _itemCard(Credenciais c, int index){
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: () => _onClickIrTelaAdicionar(c: c),
        onLongPress: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 1),
            content: Text("Copiado ${c.site} ${c.senha}"),
          ));
          Clipboard.setData(ClipboardData(text: c.senha));
        },
        child: Row(
          children: [
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text("${c.site}",
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18)),
                )),
            Expanded(
                child: Text(
                    _listPasswordVisible[index] ? "${c.senha}" : "●●●●●",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18))),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 50,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: (){
                    _listPasswordVisible[index] = !_listPasswordVisible[index];
                    setState(() {});
                  },
                  icon: Icon(_listPasswordVisible[index] ? Icons.visibility : Icons.visibility_off),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  _onClickIrTelaAdicionar({Credenciais? c}){
    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        AddPasswordScreen(c: c,))
    ).then((value) => setState((){
      _desativarVisualizacaoSenhas();
    }));
  }

  _desativarVisualizacaoSenhas(){
    for(int i=0; i<_listPasswordVisible.length; i++){
      _listPasswordVisible[i] = false;
    }
  }

  _seachCard(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Card(
        elevation: 0,
        shadowColor: const Color(0x00ffffff),
        color: brightness == Brightness.dark ? Colors.white10 : const Color(0xFFECECEC),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0x00ffffff), width: 0),
            borderRadius: BorderRadius.circular(30),
          ),
        child: TextField(
          onSubmitted: (text){
            setState(() {
              _desativarVisualizacaoSenhas();
            });
          },
          controller: _pesquisarControler,
          decoration: InputDecoration(
            hintText: "Pesquisar",
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.black),
            suffixIcon: _pesquisarControler.text != "" ? _iconButtonClear() : null
          ),
        )
      ),
    );
  }

  _iconButtonClear(){
    return IconButton(
        onPressed: (){
          setState(() {
            _pesquisarControler.text = "";
            _desativarVisualizacaoSenhas();
          });
        },
        icon: const Icon(Icons.clear)
    );
  }
}
