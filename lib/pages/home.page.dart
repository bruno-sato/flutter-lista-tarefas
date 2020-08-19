import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lista_de_tarefas/services/data-files.service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List toDoList = [];

  @override
  void initState() {
    super.initState();
    readData().then((data) =>
    {
      setState(() {
        toDoList = json.decode(data);
      })
    });
  }

  final tarefaController = TextEditingController();

  Map<String, dynamic> lastRemoved;
  int lastRemovePos;

  void addToDo() {
    Map<String, dynamic> newTodo = Map();
    newTodo["title"] = tarefaController.text;
    newTodo["ok"] = false;
    tarefaController.text = "";
    setState(() {
      toDoList.add(newTodo);
    });
    saveData(toDoList);
  }

  ordernarLista() {
    toDoList.sort((a, b) {
      if (a["ok"] && !b["ok"])
        return 1;
      else if (!a["ok"] && b["ok"])
        return -1;
      else
        return 0;
    });
    setState(() {
      saveData(toDoList);
    });
  }

  Future<Null> refresh() async {
    await Future.delayed(Duration(seconds: 1));
    ordernarLista();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista de tarefas",
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16, 1, 16, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: tarefaController,
                    decoration: InputDecoration(
                      labelText: "Nova tarefa",
                      labelStyle: TextStyle(
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text(
                    "Add",
                  ),
                  textColor: Colors.white,
                  onPressed: addToDo,
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                itemCount: toDoList.length,
                itemBuilder: buildItem,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(index.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(toDoList[index]["title"]),
        value: toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (status) {
          toDoList[index]["ok"] = status;
          ordernarLista();
        },
      ),
      onDismissed: (direction) {
        setState(() {
          lastRemovePos = index;
          lastRemoved = Map.from(toDoList[index]);
          toDoList.removeAt(index);
          saveData(toDoList);
        });
        final snack = SnackBar(
          content: Text("Tarefa ${lastRemoved["title"]} removida!"),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              setState(() {
                toDoList.insert(lastRemovePos, lastRemoved);
                ordernarLista();
              });
            },
          ),
        );
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(snack);
      },
    );
  }
}
