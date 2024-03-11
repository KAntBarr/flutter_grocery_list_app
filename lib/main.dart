import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      // home: const GroceryList(title: 'Grocery List'),
      home: BlocProvider(
        lazy: false,
        create: (_) => ListBloc(),
        child: GroceryList(
          title: 'Grocery List',
        ),
      ),
    );
  }
}

class GroceryList extends StatelessWidget {
  GroceryList({super.key, required this.title});

  final String title;

  final TextEditingController _textFieldController = TextEditingController();

  Future<void> _displayDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext contextS) {
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
                // context
                //     .read<ListBloc>()
                //     .add(AddEvent(_textFieldController.text));
                BlocProvider.of<ListBloc>(context)
                    .add(AddEvent(_textFieldController.text));
                _textFieldController.clear();
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
        title: Text(title),
      ),
      body: BlocBuilder<ListBloc, List<Item>>(
        builder: (context, items) {
          // List<Item> list = items as List<Item>;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            children: items.map((Item item) {
              return ListItem(
                item: item,
                onItemChanged: (item, newName) =>
                    context.read<ListBloc>().add(EditEvent(item, newName)),
                removeItem: (id) =>
                    context.read<ListBloc>().add(RemoveEvent(id)),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: BlocBuilder<ListBloc, List<Item>>(
        builder: (context, items) {
          return FloatingActionButton(
            onPressed: () => _displayDialog(context),
            tooltip: 'Add a Grocery Item',
            child: const Icon(Icons.add),
          );
        },
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
                if (_textFieldController.text != '') {
                  onItemChanged(item, _textFieldController.text);
                }
                _textFieldController.clear();
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
      title: Row(children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: GestureDetector(
                child: Text(
              item.name,
              style: _getTextStyle(),
            )),
          ),
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

abstract class ItemEvent {}

class AddEvent extends ItemEvent {
  final String name;

  AddEvent(this.name);
}

class EditEvent extends ItemEvent {
  final Item item;
  final String newName;

  EditEvent(this.item, this.newName);
}

class RemoveEvent extends ItemEvent {
  final String id;

  RemoveEvent(this.id);
}

class ListBloc extends Bloc<ItemEvent, List<Item>> {
  ListBloc() : super(<Item>[]) {
    _loadList();

    on<AddEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      String time = DateTime.now().millisecondsSinceEpoch.toString();
      List<String> itemIds = state.map((Item item) {
        return item.id;
      }).toList();
      itemIds.add(time);
      await prefs.setStringList('itemIds', itemIds);
      await prefs.setString(time, event.name);
      List<Item> temp = state.toList();
      temp.add(Item(
        name: event.name,
        id: time,
      ));
      emit(temp);
    });

    on<EditEvent>((event, emit) async {
      if (event.newName != '') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(event.item.id, event.newName);
        event.item.name = event.newName;
        emit(state.toList());
      }
    });

    on<RemoveEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      List<Item> items =
          state.where((element) => element.id != event.id).toList();
      items.removeWhere((element) => element.id == event.id);
      List<String> itemIds = items.map((Item item) {
        return item.id;
      }).toList();
      await prefs.setStringList('itemIds', itemIds);
      await prefs.remove(event.id);
      emit(items);
    });
  }

  Future<void> _loadList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? itemIds = prefs.getStringList('itemIds');
      final List<Item> completeItems = itemIds?.map((String id) {
            return Item(
              name: prefs.getString(id) ?? 'error',
              id: id,
            );
          }).toList() ??
          [];
      emit(
          completeItems); // Emit the initial state with data from SharedPreferences
    } catch (e) {
      // Handle errors, if any
      print('Error initializing data: $e');
    }
  }
}
