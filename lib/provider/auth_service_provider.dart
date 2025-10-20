import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

// Provide AuthService instance
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

