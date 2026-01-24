# Trippified Security Rules

## MANDATORY - All Code Must Follow These Rules

### 1. Authentication & Authorization

**OAuth Only - No Custom Password Storage**
- Use Supabase Auth with Google, Apple, Facebook providers
- Never store passwords or implement custom auth
- Always validate JWT tokens on protected routes

**Session Management**
```dart
// REQUIRED: Check auth state before any protected operation
final user = supabase.auth.currentUser;
if (user == null) {
  throw UnauthorizedException('User not authenticated');
}
```

**Authorization Checks**
- Every data operation must verify user owns the resource
- Use Row Level Security (RLS) in Supabase
- Never trust client-side auth state for sensitive operations

```dart
// REQUIRED: Always filter by user_id
final trips = await supabase
    .from('trips')
    .select()
    .eq('owner_id', user.id); // Never skip this
```

### 2. Input Validation

**Validate ALL User Input**
- Use Supabase's parameterized queries (automatic)
- Validate input types before sending to API
- Sanitize text inputs for display

```dart
// REQUIRED: Validate before any database operation
void validateTripInput(TripInput input) {
  if (input.name.isEmpty || input.name.length > 100) {
    throw ValidationException('Invalid trip name');
  }
  if (input.countries.isEmpty) {
    throw ValidationException('At least one country required');
  }
}
```

**File Upload Validation**
- Validate file types (only images, PDFs for documents)
- Enforce file size limits (max 10MB)
- Scan filenames for path traversal

```dart
const allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
const maxFileSize = 10 * 1024 * 1024; // 10MB

bool isValidFile(File file) {
  final extension = file.path.split('.').last.toLowerCase();
  return allowedExtensions.contains(extension) &&
         file.lengthSync() <= maxFileSize;
}
```

### 3. Secrets Management

**NEVER Hardcode Secrets**
```dart
// FORBIDDEN - Never do this
const supabaseUrl = 'https://xxx.supabase.co';
const supabaseKey = 'eyJ...'; // NEVER

// REQUIRED - Use environment variables
final supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
final supabaseKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
```

**API Keys in .env**
- Supabase URL and anon key
- Google Places API key
- Amadeus API credentials
- AI Vision API keys

**Git Ignore**
```
# REQUIRED in .gitignore
.env
.env.local
*.env
```

### 4. Data Protection

**Sensitive Data Handling**
- Travel documents: encrypted at rest (Supabase Storage)
- User preferences: no PII in analytics
- Booking data: mask card numbers, show last 4 only

**Logging Rules**
```dart
// FORBIDDEN - Never log sensitive data
logger.info('User logged in: $email, password: $password'); // NEVER

// REQUIRED - Safe logging
logger.info('User logged in: userId=$userId');
```

**Error Messages**
```dart
// FORBIDDEN - Don't expose internals
throw Exception('SQL Error: $sqlError'); // NEVER

// REQUIRED - Generic user-facing errors
throw UserException('Unable to load trips. Please try again.');
```

### 5. Network Security

**HTTPS Only**
- All API calls must use HTTPS
- No HTTP fallback

**API Rate Limiting**
- Implement client-side rate limiting for auth attempts
- Max 5 login attempts per minute
- Exponential backoff on failures

```dart
class RateLimiter {
  int _attempts = 0;
  DateTime? _lastAttempt;

  bool canAttempt() {
    final now = DateTime.now();
    if (_lastAttempt != null &&
        now.difference(_lastAttempt!).inMinutes < 1) {
      return _attempts < 5;
    }
    _attempts = 0;
    return true;
  }
}
```

### 6. OWASP Top 10 Checklist

Before any PR, verify:

- [ ] **Injection**: Using parameterized queries only
- [ ] **Broken Auth**: JWT validation on all protected routes
- [ ] **Sensitive Data**: No PII in logs, encrypted at rest
- [ ] **XXE**: N/A (no XML parsing)
- [ ] **Broken Access Control**: RLS enabled, user_id checks
- [ ] **Misconfig**: No debug mode in production
- [ ] **XSS**: Sanitize all displayed text
- [ ] **Insecure Deserialization**: Validate all JSON schemas
- [ ] **Vulnerable Components**: No outdated packages
- [ ] **Insufficient Logging**: Log auth events (not data)

### 7. Document Security (Travel Documents Feature)

**Storage**
- Use Supabase Storage with private buckets
- Generate signed URLs with short expiration (5 min)
- Never expose direct storage URLs

```dart
// REQUIRED: Use signed URLs
final signedUrl = await supabase.storage
    .from('documents')
    .createSignedUrl(path, 300); // 5 min expiry
```

**Biometric Lock**
- Implement optional biometric/PIN for document access
- Use flutter_secure_storage for sensitive local data

### 8. Third-Party API Security

**Google Places API**
- Use API key restrictions (iOS/Android app only)
- Monitor usage for anomalies

**Amadeus API**
- Store credentials in environment
- Use OAuth2 flow, not direct credentials in requests

**AI Vision APIs**
- Don't send user location data unnecessarily
- Anonymize requests where possible
