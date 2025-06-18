import 'package:flutter/material.dart';
import 'package:my_notes/data/api_service.dart';

class Phpadmindb extends StatefulWidget {
  @override
  _PhpadmindbState createState() => _PhpadmindbState();
}

class _PhpadmindbState extends State<Phpadmindb> {
  late Future<List<dynamic>> notes;

  @override
  void initState() {
    super.initState();
    notes = ApiService.fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notes")),
      body: FutureBuilder<List<dynamic>>(
        future: notes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No Notes Found"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var note = snapshot.data![index];
              return ListTile(
                title: Text(note["Title"]),
                subtitle: Text(note["Description"]),
              );
            },
          );
        },
      ),
    );
  }
}
