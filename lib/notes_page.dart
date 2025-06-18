import 'package:flutter/material.dart';
import 'package:my_notes/data/mysql_db_helper.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String,dynamic>> allNotes = [];
  MySqlDbHelper? dbHelper;
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  String errorMsg ='';
  @override
  void initState() {
    dbHelper = MySqlDbHelper.instance;
    getNotes();
    super.initState();
  }

  Future<void> getNotes()async{
    List<Map<String,dynamic>> notes = await dbHelper!.getAllNotes();
    setState(() {
     allNotes = notes;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('MyNotes'),
      ),
      body: allNotes.isEmpty?Center(child: Text('No notes yet'),):
      ListView.builder(
          itemCount: allNotes.length,
          itemBuilder: (_,index){
            return ListTile(
              leading: Text('${index+1}'),
              title: Text('${allNotes[index][MySqlDbHelper.COLUMN_TITLE]}'),
              subtitle: Text('${allNotes[index][MySqlDbHelper.COLUMN_DESCRIPTION]}'),
              trailing: SizedBox(width: 50,
                child: Row(
                  children: [
                    InkWell(
                      onTap: ()async{
                        titleController.text = allNotes[index][MySqlDbHelper.COLUMN_TITLE].toString();
                        descController.text = allNotes[index][MySqlDbHelper.COLUMN_DESCRIPTION].toString();
                        showModalBottomSheet(context: context, builder: (context)
                        {
                          return _getBottomViewSheet(
                              isUpdate: true, S_no: allNotes[index][MySqlDbHelper.COLUMN_SR_NO]);
                        });
                      },
                      child: Icon(Icons.edit),
                    ),
                    InkWell(
                      onTap: ()async{
                        bool check = await dbHelper!.deleteNotes(S_No: allNotes[index][MySqlDbHelper.COLUMN_SR_NO]);
                        check?getNotes():'';
                      },
                      child: Icon(Icons.delete),
                    ),
                  ],
                ),),
            );
          }),
      floatingActionButton: FloatingActionButton(onPressed: ()async{
        titleController.clear();
        descController.clear();
        showModalBottomSheet(context: context, builder: (context){

          return _getBottomViewSheet();

        });
      },
        child: Icon(Icons.add),
      ),
    );
  }
  Widget _getBottomViewSheet ({bool isUpdate= false, int S_no = 0}){
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      //borderSide: BorderSide(color: Colors.black)
    );
    return Container(
      padding: EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        children: [
          Text(isUpdate?'Update Notes':'Add Notes',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.onPrimaryContainer),),
          SizedBox(height: 21,),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
                focusedBorder: border,
                enabledBorder: border,
                labelText: 'Title',
                hintText: 'Enter a title here '
            ),
          ),
          SizedBox(height: 20,),
          TextField(
            controller: descController,
            maxLines: 4,
            decoration: InputDecoration(
                focusedBorder: border,
                enabledBorder: border,
                labelText: 'Description',
                hintText: 'Enter a description here '
            ),
          ),
          SizedBox(height: 20,),
          Row(
            children: [
              Expanded(child:
              ElevatedButton(onPressed: ()async{
                final mtitle = titleController.text.toString();
                final mdesc = descController.text.toString();
                if(mtitle.isNotEmpty&& mdesc.isNotEmpty){
                  bool check = isUpdate?
                  await dbHelper!.updateNotes(title: mtitle, description: mdesc, S_No: S_no)
                      :await dbHelper!.addNotes(title: mtitle, description: mdesc);
                  if(check){
                    getNotes();
                    setState(()=>errorMsg = '');
                    titleController.clear();
                    descController.clear();
                    Navigator.pop(context);
                  }else{
                    isUpdate?setState(()=>errorMsg = 'Fail to update'):setState(()=>errorMsg = 'Fail to add');
                  }

                }
                else {
                  setState(()=>errorMsg = 'Pls enter all the field');
                }


              }, style:ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  foregroundColor: Colors.white
              ),child: Text(isUpdate?'Update Note':'Add Note'))),
              SizedBox(width: 10,),
              Expanded(child:
              ElevatedButton(onPressed: (){setState(()=>errorMsg = ''); Navigator.pop(context);}, style:ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  foregroundColor: Colors.white
              ),child: Text('Cancel')))
            ],
          ),
          SizedBox(height: 10,),
          Text(errorMsg,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }


}

