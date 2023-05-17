import 'dart:core';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateInput = TextEditingController();

  List<Map<String, dynamic>> _items = [];

  final _todoBox = Hive.box('todo_box');

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    final data = _todoBox.keys.map((key) {
      final item = _todoBox.get(key);
      return {
        'key': key,
        'title': item['title'],
        'description': item['description'],
        'date': item['date']
      };
    }).toList();
    setState(() {
      _items = data.reversed.toList();
      print(_items.length);
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _todoBox.add(newItem);
    _refreshItems();
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _todoBox.put(itemKey, item);
    _refreshItems();
  }

  Future<void> _deleteItem(int itemKey) async {
    await _todoBox.delete(itemKey);
    _refreshItems();

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An task has been deleted')));
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _titleController.text = existingItem['title'];
      _descriptionController.text = existingItem['description'];
      _dateInput.text = existingItem['date'];
    }

    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 30,
                left: 15,
                right: 15),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  TextField(
                    controller: _dateInput,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        labelText: "Enter Date" //label text of field
                        ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        print(pickedDate);
                        String formattedDate =
                            DateFormat.yMMMEd().format(pickedDate);
                        // print(formattedDate);
                        setState(
                          () {
                            _dateInput.text = formattedDate;
                          },
                        );
                      }
                    },
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (itemKey == null) {
                          _createItem({
                            'title': _titleController.text,
                            'description': _descriptionController.text,
                            'date': _dateInput.text
                          });
                        }
                        if (itemKey != null) {
                          _updateItem(itemKey, {
                            'title': _titleController.text.trim(),
                            'description': _descriptionController.text.trim(),
                            'date': _dateInput.text.trim(),
                          });
                        }
                        _titleController.text = '';
                        _descriptionController.text = '';
                        _dateInput.text = '';
                        Navigator.of(context).pop();
                      },
                      child: const Text('Create New'))
                ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            backgroundColor: Colors.pink,
            title: const Text('To Do List',
                style: TextStyle(
                    color: Colors.white, fontSize: 40, fontFamily: 'Pattaya')),
            toolbarHeight: 120,
          )),
      body: Stack(children: [
        Center(
          child: Image.asset('assets/images/todo.png'),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (_, index) {
              final currentItem = _items[index];
              return Card(
                color: Colors.white60,
                margin: EdgeInsets.all(10),
                elevation: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        currentItem['title'].toString(),
                      ),
                      subtitle: Text(
                        currentItem['description'].toString(),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showForm(
                              context,
                              currentItem['key'],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteItem(
                              currentItem['key'],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15, bottom: 10),
                      child: Text(
                        currentItem['date'].toString(),
                        style: TextStyle(color: Colors.pink),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
