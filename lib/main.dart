import 'package:flutter/material.dart';

void main() {
  runApp(const GroceryApp());
}

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const GroceryList(title: 'Grocery List'),
    );
  }
}

class GroceryList extends StatefulWidget {
  const GroceryList({super.key, required this.title});

  final String title;

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<Item> _items = <Item>[];
  final TextEditingController _textFieldController = TextEditingController();

  void _addItem(String name) {
    setState(() {
      _items.add(Item(
        name: name,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      ));
      // _items.add(Item(name: name, completed: false));
    });
    _textFieldController.clear();
  }

  void _handleItemChange(Item item, String newName) {
    setState(() {
      item.name = newName;
    });
  }

  void _deleteItem(String id) {
    setState(() {
      _items.removeWhere((element) => element.id == id);
    });
  }

  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a item'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Type your item'),
            autofocus: true,
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _addItem(_textFieldController.text);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      // body: const Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[],
      //   ),
      // ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: _items.map((Item item) {
          return ListItem(
            item: item,
            onItemChanged: _handleItemChange,
            removeItem: _deleteItem,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayDialog,
        tooltip: 'Add a Grocery Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Item {
  Item({required this.name, required this.id});
  // Item({required this.name, required this.completed});
  String name;
  // bool completed;
  String id;
}

class ListItem extends StatelessWidget {
  ListItem({
    required this.item,
    required this.onItemChanged,
    required this.removeItem,
  }) : super(key: ObjectKey(item));

  final Item item;

  final void Function(Item item, String newName) onItemChanged;

  final void Function(String id) removeItem;

  final TextEditingController _textFieldController = TextEditingController();

  TextStyle? _getTextStyle() {
    // TextStyle? _getTextStyle(bool checked) {
    // if (!checked) return null;

    return const TextStyle(
      color: Colors.black54,
      // decoration: TextDecoration.lineThrough,
    );
  }

  Future<void> _displayDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Item : ${item.name}'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'New Name'),
            autofocus: true,
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onItemChanged(item, _textFieldController.text);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _displayDialog(context),
      // leading: Checkbox(
      //   checkColor: Colors.greenAccent,
      //   activeColor: Colors.red,
      //   value: item.completed,
      //   onChanged: (value) {},
      // ),
      title: Row(children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 30.0),
            // child: Text(item.name, style: _getTextStyle(),),
            child: GestureDetector(
                // onTap: () => _displayDialog(context),
                child: Text(
              item.name,
              style: _getTextStyle(),
            )),
          ),
          // child: Text(item.name, style: _getTextStyle()),
          // child: Text(item.name, style: _getTextStyle(item.completed)),
        ),
        IconButton(
          iconSize: 30,
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          alignment: Alignment.centerRight,
          onPressed: () {
            removeItem(item.id);
          },
        ),
      ]),
    );
  }
}
