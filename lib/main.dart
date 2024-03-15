import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      debugShowCheckedModeBanner: false, // get rid of the debug banner
      home: BlocProvider( // provide the overall bloc
        lazy: false, // create bloc now
        create: (_) => ListBloc(),
        child: GroceryList(
          title: 'Grocery List', // title of the app
        ),
      ),
    );
  }
}

class GroceryList extends StatelessWidget {
  GroceryList({super.key, required this.title});

  final String title;

  // text controller for the popup dialog to add items
  final TextEditingController _textFieldController = TextEditingController();

  // like a promise, it will return a widget of a dialog
  Future<void> _displayDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // tapping outside the dialog won't do anything
      builder: (BuildContext contextS) { // renamed to allow the outer context to have domain
        return AlertDialog(
          title: const Text('Add a item'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Type your item'),
            autofocus: true, // the text field is selected
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                _textFieldController.clear(); // clear text field in dialog
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
                Navigator.of(context).pop(); // close dialog
                BlocProvider.of<ListBloc>(context) // trigger the event in the bloc
                    .add(AddEvent(_textFieldController.text)); // with the text field content
                _textFieldController.clear(); // clear text field in dialog
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
    return Scaffold( // the first layer/component/widget of the app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      // the body widget will react to changes 
      // in the state because of the BlocBuilder
      // the state being a list of items
      body: BlocBuilder<ListBloc, List<Item>>(
        builder: (context, items) { // provide the context/bloc and the state which is items
          return ListView( // the widget that will hold the list items
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            children: items.map((Item item) { // map each item into a ListItem widget
              return ListItem(
                item: item,
                // attach a callback function(s) 
                // to the ListItem that will
                // trigger an event in the bloc
                onItemChanged: (item, newName) =>
                    context.read<ListBloc>().add(EditEvent(item, newName)),
                removeItem: (id) =>
                    context.read<ListBloc>().add(RemoveEvent(id)),
              );
            }).toList(), // turn into a list of ListItems
          );
        },
      ),
      // the FOB also uses BlocBuilder
      // to provide a context to the
      // dialog in order to trigger events
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

// basic item class
class Item {
  Item({required this.name, required this.id});
  // Item({required this.name, required this.completed});
  String name;
  // bool completed;
  String id;
}

// a class to view/react with the Item in a list on the screen
class ListItem extends StatelessWidget {
  ListItem({
    required this.item,
    required this.onItemChanged,
    required this.removeItem,
  }) : super(key: ObjectKey(item));

  final Item item;

  // wrapper function that triggers a bloc event
  final void Function(Item item, String newName) onItemChanged;

  // wrapper function that triggers a bloc event
  final void Function(String id) removeItem;

  // a text controller to control
  // when a user clicks on an item
  // to edit and save it
  final TextEditingController _textFieldController = TextEditingController();

  // this function will return a
  // text style but can return null
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
                // if the text field is not empty, then edit item
                if (_textFieldController.text != '') {
                  // use the wrapper function attached to the object
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
                child: Text( // text widget that displays our item name
              item.name,
              style: _getTextStyle(),
            )),
          ),
        ),
        IconButton( // delete button
          iconSize: 30,
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          alignment: Alignment.centerRight,
          onPressed: () {
            removeItem(item.id); // wrapper function to delete item
          },
        ),
      ]),
    );
  }
}

// set up for using events
// the base event type
abstract class ItemEvent {}

// add event to create an item
class AddEvent extends ItemEvent {
  final String name;

  AddEvent(this.name);
}

// edit event to edit an item's name
class EditEvent extends ItemEvent {
  final Item item;
  final String newName;

  EditEvent(this.item, this.newName);
}

// remove event to delete an item
class RemoveEvent extends ItemEvent {
  final String id;

  RemoveEvent(this.id);
}

// custom bloc class
class ListBloc extends Bloc<ItemEvent, List<Item>> {
  ListBloc() : super(<Item>[]) {
    _loadList(); // initialize list state on creation

    on<AddEvent>((event, emit) async {
      try {
        final prefs = await SharedPreferences.getInstance(); // get link to storage
        String time = DateTime.now().millisecondsSinceEpoch.toString(); // get time for id
        List<String> itemIds = state.map((Item item) { // get current list of item ids
          return item.id;
        }).toList();
        // add time to list of item ids
        itemIds.add(time);
        await prefs.setStringList('itemIds', itemIds); // set this new list in storage
        // using the time/id, save
        // the given name to storage
        await prefs.setString(time, event.name); 
        List<Item> temp = state.toList(); // get a copy of the state(list of items)
        temp.add(Item( // add a new item
          name: event.name,
          id: time,
        ));
        emit(temp); // have the bloc builders react to the state change
      } catch (error) {
        print('Error adding data: $error');
      }
    });

    on<EditEvent>((event, emit) async {
      try {
        // if the given new name is not empty
        // then save the edit to storage 
        if (event.newName != '') {
          final prefs = await SharedPreferences.getInstance(); // get link to stored data
          // set the new name to storage using the id as a key
          await prefs.setString(event.item.id, event.newName);
          event.item.name = event.newName;
          emit(state.toList()); // emit so bloc builders can update
        }
      } catch (error) {
        print('Error editing data: $error');
      }
    });

    on<RemoveEvent>((event, emit) async {
      try {
        final prefs = await SharedPreferences.getInstance(); // get link to stored data
        List<Item> items = // filter the list to not include the item with the given id
            state.where((element) => element.id != event.id).toList();
        List<String> itemIds = items.map((Item item) { // get list of item ids
          return item.id;
        }).toList();
        await prefs.setStringList('itemIds', itemIds); // save the new list to storage
        await prefs.remove(event.id); // remove the old item from storage with the given id
        emit(items); // set the state to the new list of items
      } catch (error) {
        print('Error removing data: $error');
      }
    });
  }

  // initialize the state list
  Future<void> _loadList() async {
    try {
      final prefs = await SharedPreferences.getInstance(); // get link to stored data
      final List<String>? itemIds = prefs.getStringList('itemIds'); // get item IDs
      // map through the IDs to build a list of Item widgets
      final List<Item> completeItems = itemIds?.map((String id) {
            return Item(
              name: prefs.getString(id) ?? 'error',
              id: id,
            );
          }).toList() ??
          [];
      emit(
          completeItems); // Emit the initial state with data from storage
    } catch (error) {
      // Handle errors, if any
      print('Error initializing data: $error');
    }
  }
}
