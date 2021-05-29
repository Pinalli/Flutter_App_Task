import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/item.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello',
      theme: ThemeData(
        primaryColor: Colors.lightBlue,
      ),
      home: HomePage(),
    );
  }
}

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  // ignore: deprecated_member_use
  var itens = new List<Item>();

  HomePage() {
    itens = []; //comentario = ctrl + k + c
    // itens.add(Item(title: "Banana", done: false));
    // itens.add(Item(title: "Nutella", done: true));
    // itens.add(Item(title: "Limão", done: false));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController();

  void add() {
    if (newTaskCtrl.text.isEmpty) return;

    setState(() {
      widget.itens.add(Item(
        title: newTaskCtrl.text,
        done: false,
      ));
      // newTaskCtrl.text = "";
      newTaskCtrl.clear();
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.itens.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefes = await SharedPreferences.getInstance();
    var data = prefes.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.itens = result;
      });
    }
  }

  save() async {
    var prefes = await SharedPreferences.getInstance();
    await prefes.setString('data', jsonEncode(widget.itens));
  }

  _HomePageState() {
    load();
  }
  @override
  Widget build(BuildContext context) {
    //newTakCtrl.value =
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskCtrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
          ),
          decoration: InputDecoration(
            labelText: "New task",
            labelStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.itens.length,
        itemBuilder: (BuildContext cntx, int index) {
          final item = widget.itens[index];

          return Dismissible(
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value;
                  save();
                });
              },
            ),
            key: Key(item.title),
            background: Container(
              color: Colors.red.withOpacity(0.2),
            ),
            onDismissed: (direction) {
              //   if(direction == DismissDirection.endToStart)
              //  print(direction);
              remove(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
