import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  factory AuthUser.fromFirebase(User user) {
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode => uid.hashCode ^ email.hashCode ^ displayName.hashCode ^ photoUrl.hashCode;

  @override
  String toString() => 'AuthUser(uid: $uid, email: $email, displayName: $displayName)';
}

abstract class AuthService {
  AuthUser? get currentUser;
  Stream<AuthUser?> get authStateChanges;
  bool get isFirebaseAvailable;

  Future<AuthUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthUser?> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth? auth;

  FirebaseAuthService({this.auth});

  static bool _hasFirebaseInitialized = false;

  static void markFirebaseInitialized() {
    _hasFirebaseInitialized = true;
  }

  FirebaseAuth get _instance {
    final a = auth;
    if (a != null) return a;
    return FirebaseAuth.instance;
  }

  @override
  bool get isFirebaseAvailable {
    try {
      if (auth != null) return true;
      return _hasFirebaseInitialized || Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  AuthUser? get currentUser {
    if (!isFirebaseAvailable) return null;
    try {
      final user = _instance.currentUser;
      return user != null ? AuthUser.fromFirebase(user) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    if (!isFirebaseAvailable) {
      return const Stream.empty();
    }
    try {
      return _instance.authStateChanges().map((user) {
        return user != null ? AuthUser.fromFirebase(user) : null;
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  @override
  Future<AuthUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!isFirebaseAvailable) {
      throw const AuthException(
        'Firebase ainda não foi inicializado. Forneça o arquivo google-services.json.',
      );
    }

    try {
      final cred = await _instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      return user != null ? AuthUser.fromFirebase(user) : null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw AuthException('Falha ao autenticar: $e');
    }
  }

  @override
  Future<AuthUser?> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!isFirebaseAvailable) {
      throw const AuthException(
        'Firebase ainda não foi inicializado. Forneça o arquivo google-services.json.',
      );
    }

    try {
      final cred = await _instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        await user.reload();
        final updated = _instance.currentUser;
        return updated != null ? AuthUser.fromFirebase(updated) : AuthUser.fromFirebase(user);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw AuthException('Falha ao cadastrar usuário: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (!isFirebaseAvailable) {
      throw const AuthException(
        'Firebase ainda não foi inicializado. Forneça o arquivo google-services.json.',
      );
    }

    try {
      await _instance.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw AuthException('Falha ao enviar e-mail de recuperação: $e');
    }
  }

  @override
  Future<void> signOut() async {
    if (!isFirebaseAvailable) return;
    try {
      await _instance.signOut();
    } catch (_) {}
  }

  static String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Nenhum usuário encontrado com este e-mail.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado em outra conta.';
      case 'invalid-email':
        return 'O endereço de e-mail informado é inválido.';
      case 'weak-password':
        return 'A senha é muito fraca. Escolha uma senha com no mínimo 6 caracteres.';
      case 'user-disabled':
        return 'Esta conta foi desativada pelo administrador.';
      case 'too-many-requests':
        return 'Muitas tentativas consecutivas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Falha de conexão com a internet. Verifique sua rede.';
      default:
        return e.message ?? 'Ocorreu um erro na autenticação com o Firebase.';
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
