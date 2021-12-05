import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_chat/pages/login_page.dart';

class AuthRequiredState<T extends StatefulWidget>
    extends SupabaseAuthRequiredState<T> {
  @override
  void onUnauthenticated() {
    if (mounted) {
      /// Users will be sent back to the LoginPage if they sign out.
      Navigator.of(context)
          .pushAndRemoveUntil(LoginPage.route(), (route) => false);
    }
  }
}
