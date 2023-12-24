import 'dart:developer' as developer;
// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipes/models/base_model.dart';
import 'package:flutter_recipes/models/shopping_list/shopping_list_model.dart';
import 'package:flutter_recipes/models/recipe/recipe_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a new document
  Future<void> createDocument(BaseModel model, String collection) async {
    return _db.collection(collection).doc(model.id).set(model.toJson());
  }

  // Read a document
  Future<T> readDocument<T extends BaseModel>(String id, String collection,
      T Function(Map<String, dynamic>) fromJson) async {
    var doc = await _db.collection(collection).doc(id).get();
    if (doc.exists) {
      return fromJson(doc.data()!);
    }
    throw Exception('Document not found');
  }

  // Update a document
  Future<void> updateDocument(BaseModel model, String collection) async {
    print("R3.5: ${model.toJson()}");
    return _db.collection(collection).doc(model.id).update(model.toJson());
  }

  // Delete a document
  Future<void> deleteDocument(String id, String collection) async {
    return _db.collection(collection).doc(id).delete();
  }

// Delete multiple documents
  Future<void> deleteDocuments(List<String> ids, String collection) async {
    WriteBatch batch = _db.batch();

    for (var id in ids) {
      var docRef = _db.collection(collection).doc(id);
      batch.delete(docRef);
    }

    return await batch.commit();
  }

  // Check if a document exists
  Future<bool> documentExists(String id, String collection) async {
    var doc = await _db.collection(collection).doc(id).get();
    return doc.exists;
  }

  // Listen for changes to a user's recipe documents
  Stream<List<RecipeModel>> listenToUserRecipes(String userId) {
    return _db
        .collection('recipes')
        .where('metadata.ownerId', isEqualTo: userId)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        print("DOC: ${doc.data()}");
        print("RecipeModel: ${RecipeModel.fromJson(doc.data())}");
        return RecipeModel.fromJson(doc.data());
      }).toList();
    });
  }

  // Listen for changes to a user's list documents
  Stream<List<ShoppingListModel>> listenToUserLists(String userId) {
    return _db
        .collection('lists')
        .where('metadata.ownerId', isEqualTo: userId)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        developer.log("List doc ${doc.data()}", name: 'user lists');
        return ShoppingListModel.fromJson(doc.data());
      }).toList();
    });
  }
}
