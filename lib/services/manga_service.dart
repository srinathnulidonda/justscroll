//services/manga_service.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MangaService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetches all manga titles with basic info
  Future<List<Map<String, dynamic>>> getMangaList() async {
    try {
      final snapshot = await _firestore.collection('manga').get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      return [];
    }
  }

  // Search manga by title
  Future<List<Map<String, dynamic>>> searchManga(String query) async {
    try {
      // Convert query to lowercase for case-insensitive search
      final lowerQuery = query.toLowerCase();

      final snapshot = await _firestore.collection('manga').get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .where(
            (manga) =>
                manga['title'].toString().toLowerCase().contains(lowerQuery) ||
                    (manga['genres'] as List<dynamic>?)?.any(
                      (genre) =>
                          genre.toString().toLowerCase().contains(lowerQuery),
                    ) ??
                false,
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get manga details
  Future<Map<String, dynamic>?> getMangaDetails(String mangaId) async {
    try {
      final doc = await _firestore.collection('manga').doc(mangaId).get();
      if (!doc.exists) return null;

      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      return null;
    }
  }

  // Get chapter images
  Future<List<String>> getChapterImages(
    String mangaId,
    String chapterId,
  ) async {
    try {
      final ListResult result =
          await _storage.ref('manga/$mangaId/chapters/$chapterId').listAll();

      // Sort images by name (assuming names are like 01.jpg, 02.jpg, etc.)
      result.items.sort(
        (a, b) => a.name.toString().compareTo(b.name.toString()),
      );

      // Get download URLs for each image
      final urls = await Future.wait(
        result.items.map((ref) => ref.getDownloadURL()),
      );

      return urls;
    } catch (e) {
      return [];
    }
  }

  // Add manga to favorites
  Future<bool> addToFavorites(String mangaId) async {
    if (_auth.currentUser == null) return false;

    try {
      final userRef = _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid);

      await userRef.update({
        'favorites': FieldValue.arrayUnion([mangaId]),
      });

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Remove manga from favorites
  Future<bool> removeFromFavorites(String mangaId) async {
    if (_auth.currentUser == null) return false;

    try {
      final userRef = _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid);

      await userRef.update({
        'favorites': FieldValue.arrayRemove([mangaId]),
      });

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Track reading progress
  Future<bool> updateReadingProgress(
    String mangaId,
    String chapterId,
    int page,
  ) async {
    if (_auth.currentUser == null) return false;

    try {
      final userRef = _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid);

      // Add to reading list if not there
      await userRef.update({
        'reading': FieldValue.arrayUnion([mangaId]),
      });

      // Update progress
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('progress')
          .doc(mangaId)
          .set({
            'chapterId': chapterId,
            'page': page,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user's reading progress for a manga
  Future<Map<String, dynamic>?> getReadingProgress(String mangaId) async {
    if (_auth.currentUser == null) return null;

    try {
      final doc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .collection('progress')
              .doc(mangaId)
              .get();

      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  // Get user's manga lists (favorites, reading, read)
  Future<Map<String, List<Map<String, dynamic>>>> getUserLists() async {
    if (_auth.currentUser == null) {
      return {'favorites': [], 'reading': [], 'read': []};
    }

    try {
      final userDoc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .get();

      if (!userDoc.exists) {
        return {'favorites': [], 'reading': [], 'read': []};
      }

      final userData = userDoc.data()!;

      // Function to fetch manga details for a list of IDs
      Future<List<Map<String, dynamic>>> fetchMangaDetails(
        List<dynamic> ids,
      ) async {
        if (ids.isEmpty) return [];

        final List<Map<String, dynamic>> result = [];
        for (final id in ids) {
          final details = await getMangaDetails(id.toString());
          if (details != null) {
            result.add(details);
          }
        }
        return result;
      }

      // Fetch details for each list
      final favorites = await fetchMangaDetails(
        List<dynamic>.from(userData['favorites'] ?? []),
      );

      final reading = await fetchMangaDetails(
        List<dynamic>.from(userData['reading'] ?? []),
      );

      final read = await fetchMangaDetails(
        List<dynamic>.from(userData['read'] ?? []),
      );

      return {'favorites': favorites, 'reading': reading, 'read': read};
    } catch (e) {
      return {'favorites': [], 'reading': [], 'read': []};
    }
  }

  // Rate manga
  Future<bool> rateManga(String mangaId, double rating) async {
    if (_auth.currentUser == null) return false;

    try {
      // Save user rating
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('ratings')
          .doc(mangaId)
          .set({'rating': rating, 'updatedAt': FieldValue.serverTimestamp()});

      // Update manga's average rating
      final ratingsSnapshot =
          await _firestore
              .collection('users')
              .where(FieldPath.documentId, isNotEqualTo: _auth.currentUser!.uid)
              .get();

      double totalRating = rating;
      int ratingCount = 1;

      for (final userDoc in ratingsSnapshot.docs) {
        final ratingDoc =
            await _firestore
                .collection('users')
                .doc(userDoc.id)
                .collection('ratings')
                .doc(mangaId)
                .get();

        if (ratingDoc.exists && ratingDoc.data()?['rating'] != null) {
          totalRating += ratingDoc.data()!['rating'];
          ratingCount++;
        }
      }

      final averageRating = totalRating / ratingCount;

      await _firestore.collection('manga').doc(mangaId).update({
        'averageRating': averageRating,
        'ratingCount': ratingCount,
      });

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get recommendations based on user history
  Future<List<Map<String, dynamic>>> getRecommendations() async {
    if (_auth.currentUser == null) {
      // Return trending manga for non-logged-in users
      return getTrendingManga();
    }

    try {
      final userLists = await getUserLists();

      // Get genres user enjoys from favorites and reading lists
      final List<String> userGenres = [];

      for (final manga in [
        ...userLists['favorites']!,
        ...userLists['reading']!,
      ]) {
        if (manga['genres'] != null) {
          for (final genre in manga['genres']) {
            if (!userGenres.contains(genre)) {
              userGenres.add(genre.toString());
            }
          }
        }
      }

      // Get manga with similar genres that user hasn't read
      if (userGenres.isNotEmpty) {
        final snapshot = await _firestore.collection('manga').get();

        final allManga =
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

        // Filter out manga already in user lists
        final readIds = [
          ...userLists['favorites']!.map((m) => m['id']),
          ...userLists['reading']!.map((m) => m['id']),
          ...userLists['read']!.map((m) => m['id']),
        ];

        final recommendations =
            allManga
                .where((manga) => !readIds.contains(manga['id']))
                .where(
                  (manga) =>
                      manga['genres'] != null &&
                      (manga['genres'] as List<dynamic>).any(
                        (genre) => userGenres.contains(genre.toString()),
                      ),
                )
                .toList();

        // Sort by number of matching genres and popularity
        recommendations.sort((a, b) {
          final aMatchingGenres =
              (a['genres'] as List<dynamic>)
                  .where((genre) => userGenres.contains(genre.toString()))
                  .length;

          final bMatchingGenres =
              (b['genres'] as List<dynamic>)
                  .where((genre) => userGenres.contains(genre.toString()))
                  .length;

          if (aMatchingGenres != bMatchingGenres) {
            return bMatchingGenres - aMatchingGenres; // Higher matching first
          }

          // If same number of matching genres, sort by rating
          final aRating = a['averageRating'] ?? 0.0;
          final bRating = b['averageRating'] ?? 0.0;

          return (bRating > aRating) ? 1 : -1;
        });

        return recommendations.take(10).toList();
      }

      // Fallback to trending if no recommendations
      return getTrendingManga();
    } catch (e) {
      return getTrendingManga();
    }
  }

  // Get trending manga
  Future<List<Map<String, dynamic>>> getTrendingManga() async {
    try {
      final snapshot =
          await _firestore
              .collection('manga')
              .orderBy('viewCount', descending: true)
              .limit(10)
              .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      return [];
    }
  }
}
