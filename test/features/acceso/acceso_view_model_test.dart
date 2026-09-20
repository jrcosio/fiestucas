import 'package:fiestucas/features/acceso/model/error_acceso.dart';
import 'package:fiestucas/features/acceso/model/estado_acceso.dart';
import 'package:fiestucas/features/acceso/model/sesion_usuario.dart';
import 'package:fiestucas/features/acceso/view_model/acceso_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'autenticacion_repository_falso.dart';

void main() {
  late AutenticacionRepositoryFalso falso;
  late ProviderContainer contenedor;

  setUp(() {
    falso = AutenticacionRepositoryFalso();
    contenedor = ProviderContainer(
      overrides: [autenticacionRepositoryProvider.overrideWithValue(falso)],
    );
  });

  tearDown(() async {
    contenedor.dispose();
    await falso.cerrar();
  });

  AccesoViewModel vm() => contenedor.read(accesoViewModelProvider.notifier);
  EstadoAcceso estado() => contenedor.read(accesoViewModelProvider);

  group('Camino feliz', () {
    test('parte del estado inicial', () {
      expect(estado(), const EstadoAcceso.inicial());
    });

    test('entrar con Google termina en sesión', () async {
      await vm().entrarCon(ProveedorAcceso.google);

      expect(estado(), isA<AccesoAutenticado>());
      final SesionUsuario sesion = (estado() as AccesoAutenticado).sesion;
      expect(sesion.proveedor, ProveedorAcceso.google);
      expect(sesion.uid, isNotEmpty);
    });

    test('entrar con Apple termina en sesión, aunque el correo falte', () async {
      await vm().entrarCon(ProveedorAcceso.apple);

      final SesionUsuario sesion = (estado() as AccesoAutenticado).sesion;
      expect(sesion.proveedor, ProveedorAcceso.apple);
      expect(sesion.correo, isNull);
    });
  });

  group('Bloqueo durante la carga', () {
    test('una segunda pulsación no inicia otro intento', () async {
      falso.retardo = const Duration(milliseconds: 60);

      final Future<void> primera = vm().entrarCon(ProveedorAcceso.google);
      // Mientras la primera está en vuelo, el estado debe ser de carga.
      expect(estado(), const EstadoAcceso.autenticando(ProveedorAcceso.google));

      await vm().entrarCon(ProveedorAcceso.google); // se ignora
      await vm().entrarCon(ProveedorAcceso.apple); // también se ignora
      await primera;

      expect(falso.intentos, 1);
      expect(falso.proveedoresUsados, <ProveedorAcceso>[
        ProveedorAcceso.google,
      ]);
    });

    test('enCurso solo es cierto mientras se autentica', () async {
      expect(estado().enCurso, isFalse);
      falso.retardo = const Duration(milliseconds: 30);

      final Future<void> intento = vm().entrarCon(ProveedorAcceso.google);
      expect(estado().enCurso, isTrue);

      await intento;
      expect(estado().enCurso, isFalse);
    });
  });

  group('Cancelación', () {
    test('vuelve al estado inicial y no se presenta como error', () async {
      falso.errorAlEntrar = ErrorAcceso.cancelado;

      await vm().entrarCon(ProveedorAcceso.google);

      expect(estado(), const EstadoAcceso.inicial());
      expect(estado(), isNot(isA<AccesoFallido>()));
    });
  });

  group('Errores', () {
    for (final ErrorAcceso motivo in <ErrorAcceso>[
      ErrorAcceso.sinRed,
      ErrorAcceso.credencialInvalida,
      ErrorAcceso.proveedorNoDisponible,
      ErrorAcceso.appleNoDisponible,
      ErrorAcceso.sesionCaducada,
      ErrorAcceso.desconocido,
    ]) {
      test('$motivo deja la pantalla en fallido con su motivo', () async {
        falso.errorAlEntrar = motivo;

        await vm().entrarCon(ProveedorAcceso.google);

        expect(estado(), isA<AccesoFallido>());
        final AccesoFallido fallido = estado() as AccesoFallido;
        expect(fallido.motivo, motivo);
        expect(fallido.proveedor, ProveedorAcceso.google);
      });
    }

    test('tras un fallo se puede reintentar el mismo proveedor', () async {
      falso.errorAlEntrar = ErrorAcceso.sinRed;
      await vm().entrarCon(ProveedorAcceso.apple);
      expect(estado(), isA<AccesoFallido>());

      falso.errorAlEntrar = null; // vuelve la cobertura
      await vm().reintentar();

      expect(estado(), isA<AccesoAutenticado>());
      expect(falso.proveedoresUsados.last, ProveedorAcceso.apple);
    });

    test('descartar el error vuelve al estado inicial', () async {
      falso.errorAlEntrar = ErrorAcceso.desconocido;
      await vm().entrarCon(ProveedorAcceso.google);

      vm().descartarError();

      expect(estado(), const EstadoAcceso.inicial());
    });

    test('reintentar sin fallo previo no hace nada', () async {
      await vm().reintentar();

      expect(estado(), const EstadoAcceso.inicial());
      expect(falso.intentos, 0);
    });
  });

  group('Semántica de los motivos', () {
    test('solo la cancelación no cuenta como fallo', () {
      for (final ErrorAcceso motivo in ErrorAcceso.values) {
        expect(motivo.esFallo, motivo != ErrorAcceso.cancelado);
      }
    });

    test('no se ofrece reintento donde no tiene sentido', () {
      expect(ErrorAcceso.cancelado.permiteReintento, isFalse);
      expect(ErrorAcceso.appleNoDisponible.permiteReintento, isFalse);
      expect(ErrorAcceso.sinRed.permiteReintento, isTrue);
    });
  });

  group('Disponibilidad de Apple', () {
    test('se expone tal como la reporta el repositorio', () async {
      expect(await contenedor.read(appleDisponibleProvider.future), isTrue);

      final AutenticacionRepositoryFalso sinApple =
          AutenticacionRepositoryFalso(appleEstaDisponible: false);
      final ProviderContainer otro = ProviderContainer(
        overrides: [
          autenticacionRepositoryProvider.overrideWithValue(sinApple),
        ],
      );
      addTearDown(otro.dispose);
      addTearDown(sinApple.cerrar);

      expect(await otro.read(appleDisponibleProvider.future), isFalse);
    });
  });
}
