import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/auth/auth_header.dart';
import '../../../core/config/app_colors.dart';
import '../../widgets/auth/register_form.dart';
import '../../widgets/no_internet_widget.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/connectivity_provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer2<AuthProvider, ConnectivityProvider>(
        builder: (context, auth, connectivity, _) {
          // ── Sin internet ──
          if (!connectivity.hasInternet) {
            return NoInternetWidget(
              onRetry: () => connectivity.checkInternet(),
            );
          }

          // ── Mostrar errores ──
          if (auth.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(auth.errorMessage!),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              auth.clearError();
            });
          }

          // ── Contenido principal ──
          return SingleChildScrollView(
            child: Column(
              children: [
                const AuthHeader(
                  title: 'Crear cuenta',
                  subtitle: 'Únete y empieza a pedir',
                  imageSize: 72,
                  height: 220,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: RegisterForm(
                    onRegisterSuccess: () {
                      if (context.mounted) context.go('/home');
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
