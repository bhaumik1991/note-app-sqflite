import 'package:flutter/material.dart';
import 'package:flutter_todo_list/model/note.dart';
import 'package:flutter_todo_list/note_detail.dart';
import 'package:flutter_todo_list/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DataBaseHelper dataBaseHelper = DataBaseHelper();
  List<Note> noteList;
  int count = 0;
  @override
  Widget build(BuildContext context) {
    if(noteList == null){
      // ignore: deprecated_member_use
      noteList = List<Note>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          navigateToDetail(Note('', '', 2),'Add Note');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
      body: getNotwListView(),
    );
  }

  ListView getNotwListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subtitle1;

    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position){
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(this.noteList[position].priority),
                child: getPriorutyIcon(this.noteList[position].priority),
              ),
              title: Text(this.noteList[position].title, style: titleStyle,),
              subtitle: Text(this.noteList[position].date),

              trailing: GestureDetector(
                onTap: (){
                  _delete(context, this.noteList[position]);
                },
                  child: Icon(Icons.delete, color: Colors.grey,)
              ),

              onTap: (){
                navigateToDetail(this.noteList[position],'Edit Note');
              },
            ),
          );
        },
    );
  }

  Color getPriorityColor(int priority){
    switch(priority){
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }

  Icon getPriorutyIcon(int priority){
    switch(priority){
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async{
    int result = await dataBaseHelper.deleteNote(note.id);
    if(result != 0){
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String messgae){
    final snackBar = SnackBar(content: Text(messgae));
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async{
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context)=> NoteDetail(note, title)),
    );

    if(result == true){
      updateListView();
    }
  }

  void updateListView(){
    final Future<Database> dbFuture = dataBaseHelper.initializeDatabase();
    dbFuture.then((noteList) {
      Future<List<Note>> noteListFuture = dataBaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
