import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/manga.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addManga(Manga manga) async {
    try {
      await _firestore.collection('manga').doc(manga.id).set(manga.toJson());
    } catch (e) {
      print('Error adding manga: $e');
    }
  }

  Future<List<Manga>> getMangaList() async {
    final snapshot = await _firestore.collection('manga').get();
    return snapshot.docs.map(Manga.fromFirestore).toList();
  }
}
