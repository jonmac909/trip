/// Base exception for all Trippified errors
class TrippifiedException implements Exception {
  const TrippifiedException(this.message, {this.code, this.originalError});

  final String message;
  final String? code;
  final dynamic originalError;

  @override
  String toString() => 'TrippifiedException: $message (code: $code)';
}

/// Thrown when user is not authenticated
class UnauthorizedException extends TrippifiedException {
  const UnauthorizedException([super.message = 'Not authenticated'])
    : super(code: 'UNAUTHORIZED');
}

/// Thrown when user doesn't have permission to access a resource
class ForbiddenException extends TrippifiedException {
  const ForbiddenException([super.message = 'Access denied'])
    : super(code: 'FORBIDDEN');
}

/// Thrown when a requested resource is not found
class NotFoundException extends TrippifiedException {
  const NotFoundException([super.message = 'Resource not found'])
      : super(code: 'NOT_FOUND');
}

/// Thrown when input validation fails
class ValidationException extends TrippifiedException {
  const ValidationException(super.message, {this.fieldErrors})
    : super(code: 'VALIDATION_ERROR');

  final Map<String, String>? fieldErrors;
}

/// Thrown when a network request fails
class NetworkException extends TrippifiedException {
  const NetworkException([super.message = 'Network error'])
    : super(code: 'NETWORK_ERROR');
}

/// Thrown when the device is offline
class OfflineException extends TrippifiedException {
  const OfflineException([super.message = 'No internet connection'])
    : super(code: 'OFFLINE');
}

/// Thrown when a server error occurs
class ServerException extends TrippifiedException {
  const ServerException([super.message = 'Server error'])
    : super(code: 'SERVER_ERROR');
}

/// Thrown when a timeout occurs
class TimeoutException extends TrippifiedException {
  const TimeoutException([super.message = 'Request timed out'])
    : super(code: 'TIMEOUT');
}

/// Thrown when user exceeds free tier limits
class LimitExceededException extends TrippifiedException {
  const LimitExceededException(super.message, {required this.limitType})
    : super(code: 'LIMIT_EXCEEDED');

  final String limitType;
}

/// Thrown when there's a conflict (e.g., duplicate entry)
class ConflictException extends TrippifiedException {
  const ConflictException([super.message = 'Conflict'])
    : super(code: 'CONFLICT');
}

/// Thrown when a feature requires premium subscription
class PremiumRequiredException extends TrippifiedException {
  const PremiumRequiredException([
    super.message = 'This feature requires Trippified Pro',
  ]) : super(code: 'PREMIUM_REQUIRED');
}

/// Thrown when a database operation fails
class DatabaseException extends TrippifiedException {
  const DatabaseException([super.message = 'Database error'])
      : super(code: 'DATABASE_ERROR');
}

/// Thrown when an external service call fails
class ExternalServiceException extends TrippifiedException {
  const ExternalServiceException([super.message = 'External service error'])
      : super(code: 'EXTERNAL_SERVICE_ERROR');
}

/// Thrown when AI generation fails
class AiGenerationException extends TrippifiedException {
  const AiGenerationException([super.message = 'AI generation failed'])
      : super(code: 'AI_GENERATION_ERROR');
}

/// Base exception for authentication errors
class AppAuthException extends TrippifiedException {
  const AppAuthException(super.message, {super.code = 'AUTH_ERROR'});
}

/// Thrown when OAuth provider authentication fails
class OAuthException extends AppAuthException {
  OAuthException(String provider, [String? details])
      : super(
          '$provider authentication failed${details != null ? ': $details' : ''}',
          code: 'OAUTH_ERROR',
        );
}

/// Thrown when user cancels authentication
class AuthCancelledException extends AppAuthException {
  const AuthCancelledException()
      : super('Authentication cancelled', code: 'AUTH_CANCELLED');
}
