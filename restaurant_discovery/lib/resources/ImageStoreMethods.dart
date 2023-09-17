import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post.dart';

class ImageStoreMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('Posts');

  Future<String> imageToStorage(Uint8List file) async {
    String id = const Uuid().v1();
    Reference ref = _storage.ref().child('posts').child(id);

    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadPost(String restaurantKey, Uint8List file) async {
    String res = 'Some Error Occurred';
    try {
      String photoUrl = await imageToStorage(file);
      Map<String, dynamic> posts = {
        'restaurantKey': restaurantKey,
        'postUrl': photoUrl,
      };

      dbRef.push().set(posts);
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
