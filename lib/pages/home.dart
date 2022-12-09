import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _todoList = [];
  Map<String, dynamic> _lastRemoved = <String, dynamic>{};
  int _lastRemovedPos = 0;

  @override
  void initState() {
    super.initState();
    _readFile().then((value) {
      setState(() {
        _todoList = json.decode(value!);
      });
    });
  }

  TextEditingController _itemController = TextEditingController();
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveFile() async {
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String?> _readFile() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      print(e);
      return null;
    }
  }

  void _addItemToList() {
    var item = {"title": _itemController.text, "ok": false};
    setState(() {
      _todoList.add(item);
      _itemController.text = '';
      _saveFile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de tarefas'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                  ),
                ),
                ElevatedButton(
                  onPressed: _addItemToList,
                  child: Row(
                    children: const [
                      Icon(Icons.add),
                      Text('ADD'),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: _todoList.length,
              itemBuilder: buildItem,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(_, index) {
    return Dismissible(
      key: Key(index.toString()),
      background: Container(
        padding: EdgeInsets.only(left: 10),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.delete),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_todoList[index]["title"]),
        value: _todoList[index]["ok"],
        secondary: CircleAvatar(
          child: _todoList[index]['ok'] ? Icon(Icons.check) : Icon(Icons.error),
        ),
        onChanged: (checked) {
          setState(() {
            _todoList[index]['ok'] = checked;
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastRemovedPos = index;
          _todoList.removeAt(index);
          _saveFile();
        });

        final snack = SnackBar(
          content: Text('Tarefa "${_lastRemoved["title"]}" removida'),
          action: SnackBarAction(
            label: 'desfazer',
            onPressed: () {
              setState(() {
                _todoList.insert(_lastRemovedPos, _lastRemoved);
                _saveFile();
              });
            },
          ),
          duration: Duration(seconds: 5),
        );
        ScaffoldMessenger.of(context).showSnackBar(snack);
      },
    );
  }
}
