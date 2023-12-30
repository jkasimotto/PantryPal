import 'dart:developer' as developer;
// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipes/models/base_model.dart';
import 'package:flutter_recipes/models/ingredient/ingredient_model.dart';
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

  // Get a stream of a document
  Stream<DocumentSnapshot> getDocumentStream(String collection, String id) {
    return _db.collection(collection).doc(id).snapshots();
  }

  /// Listens to a user's recipe documents in Firestore.
  ///
  /// This function fetches each recipe document for a specific user and hydrates
  /// the icon path for each ingredient from the related ingredient documents.
  /// If an ingredient document does not exist or does not have an icon path,
  /// a default icon path is used.
  Stream<List<RecipeModel>> listenToUserRecipes(String userId) {
    // Listen to the user's recipe documents in Firestore
    return _db
        .collection('recipes')
        .where('meta.ownerId', isEqualTo: userId)
        .snapshots()
        .asyncMap((querySnapshot) async {
      // For each recipe document, fetch the ingredient documents and hydrate the icon path
      return await Future.wait(querySnapshot.docs.map((doc) async {
        var recipeData = doc.data();
        var recipe = RecipeModel.fromJson(recipeData);
        List<IngredientWithQuantity> updatedIngredients = [];

        for (var ingredientWithQuantity in recipe.ingredients) {
          var ingredientId = ingredientWithQuantity.meta.ingredientId;
          // Fetch the ingredient document using the ingredient ID
          var ingredientDoc =
              await _db.collection('ingredients').doc(ingredientId).get();
          String iconPath =
              'assets/images/icons/food/default.png'; // Default icon path

          if (ingredientDoc.exists) {
            iconPath = ingredientDoc.data()?['iconPath'] ?? iconPath;
          }

          // Update the ingredient with the new iconPath
          var updatedIngredient =
              ingredientWithQuantity.copyWith(iconPath: iconPath);
          updatedIngredients.add(updatedIngredient);
        }

        // Create a new recipe with the updated ingredients
        var updatedRecipeData = Map<String, dynamic>.from(recipeData);
        updatedRecipeData['ingredients'] =
            updatedIngredients.map((i) => i.toJson()).toList();
        return RecipeModel.fromJson(updatedRecipeData);
      }).toList());
    });
  }

  // Listen for changes to a user's list documents
  Stream<List<ShoppingList>> listenToUserLists(String userId) {
    return _db
        .collection('lists')
        .where('meta.ownerId', isEqualTo: userId)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        developer.log("List doc ${doc.data()}", name: 'user lists');
        return ShoppingList.fromJson(doc.data());
      }).toList();
    });
  }

  Stream<RecipeModel> listenToRecipe(String recipeId) {
    return _db
        .collection('recipes')
        .doc(recipeId)
        .snapshots()
        .asyncMap((docSnapshot) async {
      var recipeData = docSnapshot.data();
      var recipe = RecipeModel.fromJson(recipeData!);
      List<IngredientWithQuantity> updatedIngredients = [];

      for (var ingredientWithQuantity in recipe.ingredients) {
        var ingredientId = ingredientWithQuantity.meta.ingredientId;
        // Fetch the ingredient document using the ingredient ID
        var ingredientDoc =
            await _db.collection('ingredients').doc(ingredientId).get();
        String iconPath =
            'assets/images/icons/food/default.png'; // Default icon path

        if (ingredientDoc.exists) {
          iconPath = ingredientDoc.data()?['iconPath'] ?? iconPath;
        }

        // Update the ingredient with the new iconPath
        var updatedIngredient =
            ingredientWithQuantity.copyWith(iconPath: iconPath);
        updatedIngredients.add(updatedIngredient);
      }

      // Create a new recipe with the updated ingredients
      var updatedRecipeData = Map<String, dynamic>.from(recipeData);
      updatedRecipeData['ingredients'] =
          updatedIngredients.map((i) => i.toJson()).toList();
      return RecipeModel.fromJson(updatedRecipeData);
    });
  }
}
