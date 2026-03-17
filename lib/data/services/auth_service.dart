import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_tracker_app/data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> cadastrarUsuario({
    required UserModel2 userModel,
    required String password,
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: userModel.email,
      password: password,
    );

    UserModel2 novoUsuario = UserModel2(
      id: userCredential.user!.uid,
      nome: userModel.nome,
      email: userModel.email,
      telefone: userModel.telefone,
      vehicle: userModel.vehicle,
      xp: userModel.xp,
    );

    await _firestore
        .collection('usuarios')
        .doc(novoUsuario.id)
        .set(novoUsuario.toMap());
  }

  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
