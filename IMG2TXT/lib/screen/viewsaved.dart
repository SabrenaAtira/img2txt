import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:translatify/screen/viewhistory.dart';

class ViewSaved extends StatefulWidget {
  const ViewSaved({super.key});

  @override
  State<ViewSaved> createState() => _ViewSavedState();
}

class _ViewSavedState extends State<ViewSaved> {
  bool flag = false;
  late List<QueryDocumentSnapshot> data = [];
  int minLimit = 4;
  ScrollController scroll = ScrollController();
  TextEditingController editingController = TextEditingController();
  int first = -1;
  String? deviceId = "";

  // Increment the limit for displaying history
  void dilMangeMore() {
    setState(() {
      minLimit += 3;
    });
  }

  CollectionReference? fetchData;

  @override
  void initState() {
    super.initState();
    // initializeData();
    fetchData = FirebaseFirestore.instance.collection('Saved');
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.blue[400],
        backgroundColor: Colors.blue[200],
        elevation: 5,
        title: const Text(
          "Collection",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        actions: [
          // Add IconButton for navigating to ViewHistory
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to ViewHistory screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewHistory()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
          stream: fetchData?.snapshots(),
          builder: (context, fetchData) {
            var data = fetchData.data?.docs ?? [];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ListView.builder(
                  controller: scroll,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var data = fetchData.data?.docs ?? [];

                    return Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 1.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                            color: Colors.transparent,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 13, horizontal: 13),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display extracted text in the container
                                Text(
                                  data[index]['Saved'],
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: data[index]['Saved']));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content:
                                              Text('Text copied to clipboard'),
                                          duration: Duration(seconds: 2),
                                        ));
                                      },
                                    ),
                                    IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      // Set the initial text for editing
                                      editingController.text =
                                          data[index]['Saved'];

                                      // Show a dialog for text editing
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Edit Text'),
                                            content: TextField(
                                              controller: editingController,
                                              decoration: const InputDecoration(
                                                hintText: 'Enter text',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  // Update the text in Firestore
                                                  await FirebaseFirestore.instance
                                                      .collection('Saved')
                                                      .doc(data[index].id)
                                                      .update({
                                                    'Saved':
                                                        editingController.text,
                                                  });

                                                  // Close the dialog
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Save'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                    IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('Saved')
                                              .doc(data[index].id)
                                              .delete();

                                          // Remove the document from the local data list
                                          setState(() {
                                            data.removeAt(index);
                                          });
                                        }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          }),
    );
  }
}
