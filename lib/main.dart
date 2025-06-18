import 'package:flutter/material.dart';
import 'package:my_notes/data/db_helper.dart';
import 'package:my_notes/notes_page.dart';
import 'package:my_notes/phpAdmindb.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbHelper;
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  String errorMsg = '';
  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper.getInstance;
    getNotes();
  }

  Future<void> getNotes() async {
    allNotes = await dbHelper!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('MyNotes'),
      ),
      body: allNotes.isEmpty
          ? Center(
              child: Text('No notes yet'),
            )
          : ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text('${allNotes[index][DBHelper.COLUMN_TITLE]}'),
                  subtitle:
                      Text('${allNotes[index][DBHelper.COLUMN_DESCRIPTION]}'),
                  trailing: SizedBox(
                    width: 50,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            titleController.text =
                                allNotes[index][DBHelper.COLUMN_TITLE];
                            descController.text =
                                allNotes[index][DBHelper.COLUMN_DESCRIPTION];
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return _getBottomViewSheet(
                                      isUpdate: true,
                                      S_no: allNotes[index]
                                          [DBHelper.COLUMN_SR_NO]);
                                });
                          },
                          child: Icon(Icons.edit),
                        ),
                        InkWell(
                          onTap: () async {
                            bool check = await dbHelper!.deleteNotes(
                                S_No: allNotes[index][DBHelper.COLUMN_SR_NO]);
                            check ? getNotes() : '';
                          },
                          child: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          titleController.clear();
          descController.clear();
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return _getBottomViewSheet();
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _getBottomViewSheet({bool isUpdate = false, int S_no = 0}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      //borderSide: BorderSide(color: Colors.black)
    );
    return Container(
      padding: EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            isUpdate ? 'Update Notes' : 'Add Notes',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          SizedBox(
            height: 21,
          ),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
                focusedBorder: border,
                enabledBorder: border,
                labelText: 'Title',
                hintText: 'Enter a title here '),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            controller: descController,
            maxLines: 4,
            decoration: InputDecoration(
                focusedBorder: border,
                enabledBorder: border,
                labelText: 'Description',
                hintText: 'Enter a description here '),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                      onPressed: () async {
                        final mtitle = titleController.text.toString();
                        final mdesc = descController.text.toString();
                        if (mtitle.isNotEmpty && mdesc.isNotEmpty) {
                          bool check = isUpdate
                              ? await dbHelper!.updateNotes(
                                  title: mtitle, description: mdesc, S_No: S_no)
                              : await dbHelper!
                                  .addNotes(title: mtitle, description: mdesc);
                          if (check) {
                            getNotes();
                            setState(() => errorMsg = '');
                            titleController.clear();
                            descController.clear();
                            Navigator.pop(context);
                          } else {
                            isUpdate
                                ? setState(() => errorMsg = 'Fail to update')
                                : setState(() => errorMsg = 'Fail to add');
                          }
                        } else {
                          setState(() => errorMsg = 'Pls enter all the field');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          foregroundColor: Colors.white),
                      child: Text(isUpdate ? 'Update Note' : 'Add Note'))),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() => errorMsg = '');
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          foregroundColor: Colors.white),
                      child: Text('Cancel')))
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            errorMsg,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
