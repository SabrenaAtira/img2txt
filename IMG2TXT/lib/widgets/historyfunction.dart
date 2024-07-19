import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryFunctions {
  static Future<List<String>> getHistory() async {
    List<String> history = [];

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('recognizedTexts').get();

      for (QueryDocumentSnapshot document in snapshot.docs) {
        history.add(document['text']);
      }

      return history;
    } catch (e) {
      // ignore: avoid_print
      print('Error retrieving history: $e');
      return [];
    }
  }
}
