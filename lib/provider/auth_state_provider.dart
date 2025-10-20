import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retail_demand/provider/auth_service_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).userStream;
});
