import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../model/error_acceso.dart';
import '../model/sesion_usuario.dart';
import 'autenticacion_repository.dart';

/// Implementación de producción: el único punto del proyecto que habla con
/// Firebase Authentication y con los plugins de proveedor.
///
/// Los plugins solo sirven para obtener una credencial; la sesión —su emisión,
/// renovación y persistencia— la gestiona Firebase.
class FirebaseAutenticacionRepository implements AutenticacionRepository {
  FirebaseAutenticacionRepository({
    FirebaseAuth? auth,
    GoogleSignIn? google,
    this.clientId,
    this.serverClientId,
    this.appleServiceId,
    this.appleRedirectUri,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _google = google ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  /// Identificador de cliente de Google para esta plataforma, tomado del
  /// `GoogleService-Info.plist` en iOS. Puede ser nulo.
  final String? clientId;

  /// Identificador de cliente **de tipo web**, solo necesario si el proyecto no
  /// usa `google-services.json`. En este proyecto sí lo usa, y el plugin de
  /// Gradle expone ese cliente al SDK nativo, así que aquí va nulo.
  final String? serverClientId;

  /// Service ID de Apple Developer. **Solo lo usa Android**, donde el acceso con
  /// Apple va por un flujo web. En iOS el sistema lo resuelve con la capacidad
  /// *Sign in with Apple* del propio target.
  final String? appleServiceId;

  /// Dirección de retorno del flujo web de Apple: el manejador de
  /// autenticación del proyecto Firebase.
  final Uri? appleRedirectUri;

  /// Opciones del flujo web de Apple, o `null` si falta configuración.
  WebAuthenticationOptions? get _opcionesWebApple {
    final String? id = appleServiceId;
    final Uri? destino = appleRedirectUri;
    if (id == null || id.isEmpty || destino == null) {
      return null;
    }
    return WebAuthenticationOptions(clientId: id, redirectUri: destino);
  }

  /// En Android, sin Service ID no hay flujo de Apple posible.
  bool get _appleNecesitaConfiguracionQueFalta =>
      defaultTargetPlatform == TargetPlatform.android &&
      _opcionesWebApple == null;

  bool _googleListo = false;

  @override
  Stream<SesionUsuario?> get sesion =>
      _auth.authStateChanges().map(_desdeUsuario);

  @override
  SesionUsuario? get sesionActual => _desdeUsuario(_auth.currentUser);

  @override
  Future<SesionUsuario> entrarCon(ProveedorAcceso proveedor) async {
    return switch (proveedor) {
      ProveedorAcceso.google => _entrarConGoogle(),
      ProveedorAcceso.apple => _entrarConApple(),
    };
  }

  @override
  Future<bool> appleDisponible() async {
    if (_appleNecesitaConfiguracionQueFalta) {
      return false;
    }
    try {
      return await SignInWithApple.isAvailable();
    } on Object {
      // Ante la duda, no ofrecemos algo que puede no funcionar.
      return false;
    }
  }

  @override
  Future<void> salir() async {
    try {
      await _google.signOut();
    } on Object catch (e) {
      // Cerrar sesión en el proveedor es un extra: si falla, seguimos.
      debugPrint('No se pudo cerrar sesión en Google: $e');
    }
    await _auth.signOut();
  }

  // --- Google ---------------------------------------------------------------

  Future<SesionUsuario> _entrarConGoogle() async {
    try {
      await _inicializarGoogle();

      if (!_google.supportsAuthenticate()) {
        throw const AccesoException(
          ErrorAcceso.proveedorNoDisponible,
          detalle: 'La plataforma no permite iniciar el flujo desde la app',
        );
      }

      final GoogleSignInAccount cuenta = await _google.authenticate();
      final String? idToken = cuenta.authentication.idToken;

      if (idToken == null) {
        throw const AccesoException(
          ErrorAcceso.credencialInvalida,
          detalle: 'Google no devolvió idToken',
        );
      }

      final UserCredential credencial = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      return _exigirSesion(credencial, ProveedorAcceso.google);
    } on AccesoException {
      rethrow;
    } on GoogleSignInException catch (e) {
      throw AccesoException(_desdeGoogle(e.code), detalle: e.description);
    } on FirebaseAuthException catch (e) {
      throw AccesoException(_desdeFirebase(e.code), detalle: e.message);
    } on Object catch (e) {
      throw AccesoException(ErrorAcceso.desconocido, detalle: e.toString());
    }
  }

  Future<void> _inicializarGoogle() async {
    if (_googleListo) {
      return;
    }
    await _google.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );
    _googleListo = true;
  }

  // --- Apple ----------------------------------------------------------------

  Future<SesionUsuario> _entrarConApple() async {
    if (!await appleDisponible()) {
      throw const AccesoException(
        ErrorAcceso.appleNoDisponible,
        detalle: 'SignInWithApple.isAvailable() devolvió false',
      );
    }

    try {
      // Firebase exige un nonce: a Apple le enviamos su SHA-256 y a Firebase
      // el valor en claro, para que pueda comprobar que el token es nuestro.
      final String nonce = _nonce();
      final AuthorizationCredentialAppleID apple =
          await SignInWithApple.getAppleIDCredential(
            scopes: const <AppleIDAuthorizationScopes>[
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            nonce: _sha256(nonce),
            // Obligatorio en Android, ignorado en iOS.
            webAuthenticationOptions: _opcionesWebApple,
          );

      final String? idToken = apple.identityToken;
      if (idToken == null) {
        throw const AccesoException(
          ErrorAcceso.credencialInvalida,
          detalle: 'Apple no devolvió identityToken',
        );
      }

      final OAuthCredential credencial = OAuthProvider(
        'apple.com',
      ).credential(idToken: idToken, rawNonce: nonce);

      final UserCredential resultado = await _auth.signInWithCredential(
        credencial,
      );
      return _exigirSesion(
        resultado,
        ProveedorAcceso.apple,
        nombreDeRespaldo: _nombreDe(apple),
      );
    } on AccesoException {
      rethrow;
    } on SignInWithAppleAuthorizationException catch (e) {
      throw AccesoException(_desdeApple(e.code), detalle: e.message);
    } on SignInWithAppleException catch (e) {
      throw AccesoException(
        ErrorAcceso.proveedorNoDisponible,
        detalle: e.toString(),
      );
    } on FirebaseAuthException catch (e) {
      throw AccesoException(_desdeFirebase(e.code), detalle: e.message);
    } on Object catch (e) {
      throw AccesoException(ErrorAcceso.desconocido, detalle: e.toString());
    }
  }

  /// Apple solo entrega el nombre en el primer acceso; después llega vacío.
  String? _nombreDe(AuthorizationCredentialAppleID apple) {
    final String nombre = <String?>[
      apple.givenName,
      apple.familyName,
    ].whereType<String>().join(' ').trim();
    return nombre.isEmpty ? null : nombre;
  }

  // --- Traducción de errores ------------------------------------------------

  ErrorAcceso _desdeGoogle(GoogleSignInExceptionCode code) => switch (code) {
    GoogleSignInExceptionCode.canceled => ErrorAcceso.cancelado,
    GoogleSignInExceptionCode.interrupted => ErrorAcceso.sinRed,
    GoogleSignInExceptionCode.providerConfigurationError ||
    GoogleSignInExceptionCode.uiUnavailable => ErrorAcceso.proveedorNoDisponible,
    GoogleSignInExceptionCode.clientConfigurationError ||
    GoogleSignInExceptionCode.userMismatch ||
    GoogleSignInExceptionCode.unknownError => ErrorAcceso.desconocido,
  };

  ErrorAcceso _desdeApple(AuthorizationErrorCode code) => switch (code) {
    AuthorizationErrorCode.canceled => ErrorAcceso.cancelado,
    AuthorizationErrorCode.notHandled ||
    AuthorizationErrorCode.invalidResponse => ErrorAcceso.proveedorNoDisponible,
    AuthorizationErrorCode.failed => ErrorAcceso.sinRed,
    _ => ErrorAcceso.desconocido,
  };

  ErrorAcceso _desdeFirebase(String code) => switch (code) {
    'network-request-failed' => ErrorAcceso.sinRed,
    'invalid-credential' ||
    'account-exists-with-different-credential' ||
    'invalid-verification-code' => ErrorAcceso.credencialInvalida,
    'user-token-expired' ||
    'user-disabled' ||
    'user-not-found' => ErrorAcceso.sesionCaducada,
    'operation-not-allowed' => ErrorAcceso.proveedorNoDisponible,
    _ => ErrorAcceso.desconocido,
  };

  // --- Utilidades -----------------------------------------------------------

  SesionUsuario _exigirSesion(
    UserCredential credencial,
    ProveedorAcceso proveedor, {
    String? nombreDeRespaldo,
  }) {
    final User? usuario = credencial.user;
    if (usuario == null) {
      throw const AccesoException(
        ErrorAcceso.desconocido,
        detalle: 'El canje de credencial no devolvió usuario',
      );
    }
    return SesionUsuario(
      uid: usuario.uid,
      proveedor: proveedor,
      nombreVisible: usuario.displayName ?? nombreDeRespaldo,
      correo: usuario.email,
    );
  }

  SesionUsuario? _desdeUsuario(User? usuario) {
    if (usuario == null) {
      return null;
    }
    return SesionUsuario(
      uid: usuario.uid,
      proveedor: _proveedorDe(usuario),
      nombreVisible: usuario.displayName,
      correo: usuario.email,
    );
  }

  ProveedorAcceso _proveedorDe(User usuario) {
    final bool apple = usuario.providerData.any(
      (UserInfo i) => i.providerId == 'apple.com',
    );
    return apple ? ProveedorAcceso.apple : ProveedorAcceso.google;
  }

  static String _nonce([int longitud = 32]) {
    const String alfabeto =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final Random azar = Random.secure();
    return List<String>.generate(
      longitud,
      (_) => alfabeto[azar.nextInt(alfabeto.length)],
    ).join();
  }

  static String _sha256(String valor) =>
      sha256.convert(utf8.encode(valor)).toString();
}
