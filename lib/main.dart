import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController tarefaController = TextEditingController();
  List minhaLista = [];
  Map<String, dynamic> _itemRemovido = Map();
  int _posicaoItemRemovido;

  @override
  void initState() {
    super.initState();

    lerDados().then((data) {
      setState(() {
        minhaLista = json.decode(data);
      });
    });
  }

  void adicionarItem() {
    setState(() {
      Map<String, dynamic> novoItem = Map();
      novoItem['titulo'] = tarefaController.text;
      tarefaController.text = '';
      novoItem['ok'] = false;
      minhaLista.add(novoItem);
      salvarDados();
    });
  }

  Future<Null> _refresh() async {
    setState(() {
      Future.delayed(Duration(seconds: 5));
      minhaLista.sort((a, b) {
        if (a['ok'] && !b['ok'])
          return 1;
        else if (!a['ok'] && b['ok'])
          return -1;
        else
          return 0;
      });
      salvarDados();
    });
  }

  Future<File> caminhoArquivo() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }

  Future<File> salvarDados() async {
    String data = json.encode(minhaLista);
    final directory = await caminhoArquivo();
    return directory.writeAsString(data);
  }

  Future<String> lerDados() async {
    try {
      final directory = await caminhoArquivo();
      return directory.readAsString();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To Do List'),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 7.0, 7.0, 4.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: tarefaController,
                    decoration: InputDecoration(
                      labelText: 'Insira uma nova tarefa',
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.cyan, width: 2.0)),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.cyan, width: 2.0)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: RaisedButton(
                    color: Colors.cyan,
                    onPressed: adicionarItem,
                    textColor: Colors.white,
                    child: Text('ADD'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                itemCount: minhaLista.length,
                itemBuilder: construirItem,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget construirItem(BuildContext context, int index) {
    return Dismissible(
      onDismissed: (d) {
        setState(() {
          _itemRemovido = Map.from(minhaLista[index]);
          _posicaoItemRemovido = index;
          minhaLista.removeAt(index);
          salvarDados();
        });
        final snack = SnackBar(
          content: Text('${_itemRemovido['titulo']}'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () {
              setState(() {
                minhaLista.insert(_posicaoItemRemovido, _itemRemovido);
                salvarDados();
              });
            },
          ),
        );
        Scaffold.of(context).showSnackBar(snack);
      },
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment(-0.9, 0.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text('${minhaLista[index]['titulo']}'),
        value: minhaLista[index]['ok'],
        secondary: CircleAvatar(
          child: Icon(minhaLista[index]['ok'] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            minhaLista[index]['ok'] = c;
            salvarDados();
          });
        },
      ),
    );
  }
}
