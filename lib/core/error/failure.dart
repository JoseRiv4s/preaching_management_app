abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Error de red (sin conexión, timeout)
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}

/// Error del servidor (4xx, 5xx)
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

/// Error de base de datos local
class LocalDbFailure extends Failure {
  const LocalDbFailure([super.message = 'Error en base de datos local']);
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Error desconocido
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Error inesperado']);
}