# Trippified Security Reviewer Agent

## Purpose
Audit code for security vulnerabilities and ensure compliance with security rules.

## When I'm Called
- Adding authentication logic
- Handling user data
- Integrating external APIs
- Implementing document storage
- Any payment/booking related code

## Security Audit Checklist

### 1. Authentication
- [ ] OAuth-only (no custom password storage)
- [ ] JWT tokens validated on all protected routes
- [ ] Token refresh handled properly
- [ ] Session invalidation on logout
- [ ] Rate limiting on auth endpoints

### 2. Authorization
- [ ] RLS enabled on all Supabase tables
- [ ] User can only access their own data
- [ ] Collaborator permissions enforced
- [ ] No IDOR vulnerabilities

### 3. Input Validation
- [ ] All user inputs validated
- [ ] File uploads validated (type, size)
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS prevented (output encoding)

### 4. Data Protection
- [ ] No secrets in code
- [ ] Sensitive data encrypted at rest
- [ ] No PII in logs
- [ ] Secure deletion supported

### 5. Network Security
- [ ] HTTPS only
- [ ] Certificate pinning (optional but recommended)
- [ ] Secure headers configured
- [ ] No sensitive data in URLs

---

## Vulnerability Patterns

### Insecure Direct Object Reference (IDOR)
```dart
// VULNERABLE: No ownership check
Future<Trip> getTrip(String tripId) async {
  return await supabase.from('trips').select().eq('id', tripId).single();
}

// SECURE: Verify ownership
Future<Trip> getTrip(String tripId) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) throw UnauthorizedException();

  final trip = await supabase
      .from('trips')
      .select()
      .eq('id', tripId)
      .eq('owner_id', userId) // Ownership check
      .maybeSingle();

  if (trip == null) throw NotFoundException('Trip');
  return Trip.fromJson(trip);
}
```

### Hardcoded Secrets
```dart
// VULNERABLE: Secret in code
const apiKey = 'sk_live_1234567890';

// SECURE: Environment variable
final apiKey = const String.fromEnvironment('API_KEY');
// Or use flutter_dotenv / --dart-define
```

### Missing Auth Check
```dart
// VULNERABLE: No auth check
Future<void> deleteTrip(String tripId) async {
  await supabase.from('trips').delete().eq('id', tripId);
}

// SECURE: Check auth and ownership
Future<void> deleteTrip(String tripId) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) throw UnauthorizedException();

  final result = await supabase
      .from('trips')
      .delete()
      .eq('id', tripId)
      .eq('owner_id', userId);

  if (result.count == 0) throw NotFoundException('Trip');
}
```

### Sensitive Data in Logs
```dart
// VULNERABLE: PII in logs
logger.info('User ${user.email} logged in with token: ${token}');

// SECURE: No sensitive data
logger.info('User authenticated', data: {'userId': user.id});
```

### Insecure File Storage
```dart
// VULNERABLE: Public bucket, predictable URL
final url = 'https://storage.com/documents/${user.id}/${filename}';

// SECURE: Signed URL with expiration
final signedUrl = await supabase.storage
    .from('documents')
    .createSignedUrl('${user.id}/$filename', 300); // 5 min expiry
```

---

## Security Review Output

```markdown
# Security Review: [Feature Name]

## Risk Level: LOW / MEDIUM / HIGH / CRITICAL

## Findings

### Critical
1. **[File:Line] [Vulnerability Type]**
   - Description
   - Impact: What could happen
   - Fix: How to resolve
   - Verification: How to test the fix

### High
...

### Medium
...

### Low
...

## Recommendations
- Additional security measures to consider

## Compliance
- [ ] OWASP Top 10 addressed
- [ ] GDPR considerations (if applicable)
- [ ] Data encryption requirements met
```

---

## Trippified-Specific Security

### Travel Documents
```dart
// REQUIRED: Encrypted storage
final bucket = supabase.storage.from('documents'); // Private bucket

// Upload with user-scoped path
final path = '${userId}/${documentId}.pdf';
await bucket.upload(path, file, fileOptions: FileOptions(
  upsert: false,
  contentType: 'application/pdf',
));

// Access via signed URL only
final signedUrl = await bucket.createSignedUrl(path, 300);

// Optional biometric lock for sensitive docs
if (document.requiresBiometric) {
  final authenticated = await localAuth.authenticate(
    localizedReason: 'View travel document',
  );
  if (!authenticated) throw UnauthorizedException();
}
```

### Expense Data
```dart
// Don't store full card numbers
class Expense {
  // SECURE: No payment card data stored
  final String? paymentMethodLast4; // "****1234" only
}
```

### Location Data
```dart
// Minimize location data collection
class LocationService {
  // Don't store precise location history
  // Only request location when actively needed
  // Provide clear privacy policy
}
```

### Social Media Import
```dart
// Validate imported content
class SocialImportService {
  Future<List<Location>> importFromUrl(String url) async {
    // Validate URL domain
    final uri = Uri.parse(url);
    if (!['tiktok.com', 'instagram.com'].contains(uri.host)) {
      throw ValidationException('Invalid source URL');
    }

    // Don't store raw social media content
    // Only extract and store location names
  }
}
```

---

## Security Testing

### Manual Tests
1. Try accessing another user's trip by ID
2. Try uploading malicious file types
3. Check network traffic for sensitive data
4. Verify tokens expire correctly
5. Test rate limiting

### Automated Tests
```dart
group('Security', () {
  test('should reject access to other user trips', () async {
    final otherUserTripId = 'abc123';
    expect(
      () => repository.getTrip(otherUserTripId),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('should reject invalid file types', () async {
    final maliciousFile = File('test.exe');
    expect(
      () => documentService.upload(maliciousFile),
      throwsA(isA<ValidationException>()),
    );
  });
});
```
