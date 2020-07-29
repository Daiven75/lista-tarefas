import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List _listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = Map();
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa() {
    String tarefaDigitada = _controllerTarefa.text;
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = tarefaDigitada;
    tarefa["realizada"] = false;
    setState(() {
      _listaTarefas.add(tarefa);
    });
    _controllerTarefa.text = "";

    _salvarArquivo();
  }

  _salvarArquivo() async {

    var arquivo = await _getFile();

//    Map<String, dynamic> tarefas = Map();
//    tarefas["titulo"] = "Ir ao mercado";
//    tarefas["realizada"] = false;
//    _listaTarefas.add(tarefas);

    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);

  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  Widget listaTarefa(context, index) {
    return Column(
      children: <Widget>[
        Dismissible(
          key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
          child: Row(
            children: <Widget>[
              Expanded(
                child: ListTile(
                  title: Text(_listaTarefas[index]["titulo"]),
                ),
              ),
              Checkbox(
                value: _listaTarefas[index]["realizada"],
                onChanged: (bool valorAlterado) {
                  setState(() {
                    _listaTarefas[index]["realizada"] = valorAlterado;
                  });
                  _salvarArquivo();
                },
              ),
            ],
          ),
          background: Container(
            color: Colors.red,
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(Icons.delete, color: Colors.white),
              ],
            ),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) {
            return showDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text('Deseja realmente excluir?'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text('Não'),
                    ),
                    FlatButton(
                      onPressed: () {
                        _ultimaTarefaRemovida = _listaTarefas[index];
                        _listaTarefas.removeAt(index);
                        _salvarArquivo();
                        final snackBar = SnackBar(
                          content: Text("Desfazer"),
                          duration: Duration(seconds: 4),
                          action: SnackBarAction(
                              label: "Desfazer",
                              onPressed: () {
                                setState(() {
                                  _listaTarefas.insert(index, _ultimaTarefaRemovida);
                                });
                                _salvarArquivo();
                              }
                          ),
                        );
                        _scaffoldKey.currentState.showSnackBar(snackBar);
                        Navigator.of(context).pop(true);
                      },
                      child: Text('Sim'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
  }

  @override
  Widget build(BuildContext context) {

//    _salvarArquivo();
//    print("Itens: " + _listaTarefas.toString());
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.purple,
      ),
      body: Builder(
          builder: (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                      itemCount: _listaTarefas.length,
                      itemBuilder: listaTarefa
                  ),
                ),
              ],
            ),
          ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        elevation: 20,
        onPressed: () {
          print("chegou aqui");
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title:  Text("Adicionar tarefa"),
                content: TextField(
                  controller: _controllerTarefa,
                  onChanged: (text) {

                  },
                  decoration: InputDecoration(
                      labelText: ("Tarefa")
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancelar")
                  ),
                  FlatButton(
                      onPressed: () {
                        _salvarTarefa();
                        Navigator.pop(context);
                      },
                      child: Text("Salvar")
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
