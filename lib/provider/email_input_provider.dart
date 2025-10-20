import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final emailInputControllerProvider =
    StateNotifierProvider<EmailInputController, EmailInputState>(
      (ref) => EmailInputController(),
    );

class EmailInputState {
  final String email;
  final bool isLoading;

  EmailInputState({this.email = '', this.isLoading = false});

  EmailInputState copyWith({String? email, bool? isLoading}) {
    return EmailInputState(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class EmailInputController extends StateNotifier<EmailInputState> {
  EmailInputController() : super(EmailInputState());

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  Future<String?> sendMagicLink() async {
    state = state.copyWith(isLoading: true);
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: state.email,
        emailRedirectTo: 'retaildemand://login-callback',
      );
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
