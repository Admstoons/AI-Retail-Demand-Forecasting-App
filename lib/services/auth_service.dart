import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password) async {
    try {
      return await _client.auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      rethrow; // Re-throw the specific AuthException
    } catch (e) {
      throw Exception('Sign up failed: $e'); // Re-throw other exceptions as a generic Exception
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      rethrow; // Re-throw the specific AuthException
    } catch (e) {
      throw Exception('Sign in failed: $e'); // Re-throw other exceptions as a generic Exception
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Add this getter to expose the user stream
  Stream<User?> get userStream => Supabase.instance.client.auth.onAuthStateChange.map((event) => event.session?.user);
}

