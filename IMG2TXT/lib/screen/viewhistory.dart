import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewHistory extends StatefulWidget {
  const ViewHistory({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ViewHistoryState createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {
  late List<QueryDocumentSnapshot> data = [];
  ScrollController scroll = ScrollController();
  CollectionReference? fetchData;

  @override
  void initState() {
    super.initState();
    fetchData = FirebaseFirestore.instance.collection('History');
  }

  Future<List<String>> fetchHistoryData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('History').get();
      setState(() {
        data = snapshot.docs;
      });

      return data.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final recognizedText = data['recognizedText'];
        return recognizedText != null ? recognizedText as String : '';
      }).toList();
    } catch (e) {
      e.toString();
      return [];
    }
  }

  // Function to delete a document from Firestore
  Future<void> deleteDocument(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('History')
          .doc(documentId)
          .delete();

      // Remove the document from the local data list
      setState(() {
        data.removeWhere((doc) => doc.id == documentId);
      });
    } catch (e) {
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.blue[400],
        backgroundColor: Colors.blue[200],
        elevation: 5,
        title: const Text(
          "History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchData?.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data?.docs[index];
                    var recognizedText =
                        doc?['recognizedText'] as String? ?? '';

                    return Card(
                      color: Colors.transparent,
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.blue),
                      ),
                      child: ListTile(
                        title: Text(
                          recognizedText,
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteDocument(doc?.id ?? '');
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
