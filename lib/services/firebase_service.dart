// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_app/models/manga.dart';
import 'package:manga_app/models/chapter.dart';
import 'package:manga_app/models/user_profile.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Authentication methods (unchanged)
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found with this email';
        case 'wrong-password':
          throw 'Incorrect password';
        case 'invalid-email':
          throw 'Invalid email format';
        case 'user-disabled':
          throw 'This account has been disabled';
        default:
          throw 'Login failed: ${e.message}';
      }
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'This email is already registered';
        case 'invalid-email':
          throw 'Invalid email format';
        case 'weak-password':
          throw 'Password is too weak';
        default:
          throw 'Sign up failed: ${e.message}';
      }
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Sign out failed: $e';
    }
  }

  // User profile methods (unchanged)
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .set(profile.toMap());
    } catch (e) {
      throw 'Failed to create user profile: $e';
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user profile: $e';
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .update(profile.toMap());
    } catch (e) {
      throw 'Failed to update user profile: $e';
    }
  }

  // Manga methods
  Future<List<Manga>> getAllManga() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('mangas').get();
      return snapshot.docs
          .map(
            (doc) => Manga.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw 'Failed to fetch manga list: $e';
    }
  }

  Future<List<Manga>> getMangaByGenre(String genre) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('mangas')
              .where('genres', arrayContains: genre)
              .get();
      return snapshot.docs
          .map(
            (doc) => Manga.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw 'Failed to fetch manga by genre: $e';
    }
  }

  Future<Manga?> getMangaById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('mangas').doc(id).get();
      if (doc.exists) {
        return Manga.fromMap(doc.data() as Map<String, dynamic>, id);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch manga: $e';
    }
  }

  Future<DocumentReference> addManga(Manga manga) async {
    try {
      return await _firestore.collection('mangas').add(manga.toMap());
    } catch (e) {
      throw 'Failed to add manga: $e';
    }
  }

  Future<void> deleteManga(String mangaId) async {
    try {
      await _firestore.collection('mangas').doc(mangaId).delete();
      // Optionally delete associated chapters
      await deleteChaptersByMangaId(mangaId);
    } catch (e) {
      throw 'Failed to delete manga: $e';
    }
  }

  // Chapter methods
  Future<List<Chapter>> getChaptersByMangaId(String mangaId) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('chapters')
              .where('mangaId', isEqualTo: mangaId)
              .orderBy('number', descending: true)
              .get();
      return snapshot.docs
          .map(
            (doc) =>
                Chapter.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw 'Failed to fetch chapters: $e';
    }
  }

  Future<Chapter?> getChapterById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('chapters').doc(id).get();
      if (doc.exists) {
        return Chapter.fromMap(doc.data() as Map<String, dynamic>, id);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch chapter: $e';
    }
  }

  Future<void> addChapter(Chapter chapter) async {
    try {
      await _firestore.collection('chapters').add(chapter.toMap());
    } catch (e) {
      throw 'Failed to add chapter: $e';
    }
  }

  Future<void> deleteChaptersByMangaId(String mangaId) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('chapters')
              .where('mangaId', isEqualTo: mangaId)
              .get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw 'Failed to delete chapters: $e';
    }
  }

  // Favorites methods (unchanged)
  Future<void> toggleFavorite(String uid, String mangaId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      UserProfile userProfile = UserProfile.fromMap(
        userDoc.data() as Map<String, dynamic>,
        uid,
      );

      List<String> updatedFavorites = List.from(userProfile.favorites);
      if (updatedFavorites.contains(mangaId)) {
        updatedFavorites.remove(mangaId);
      } else {
        updatedFavorites.add(mangaId);
      }

      await _firestore.collection('users').doc(uid).update({
        'favorites': updatedFavorites,
      });
    } catch (e) {
      throw 'Failed to update favorites: $e';
    }
  }

  Future<void> updateLastReadChapter(
    String uid,
    String mangaId,
    int chapterNumber,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastReadChapter.$mangaId': chapterNumber,
      });
    } catch (e) {
      throw 'Failed to update reading progress: $e';
    }
  }
}
