import '../../routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_colors.dart';
import 'package:sabix_cliente_app/core/providers/auth_provider.dart';
import 'package:sabix_cliente_app/presentation/widgets/profile/profile_header.dart';
import 'package:sabix_cliente_app/presentation/widgets/profile/profile_section.dart';
import 'package:sabix_cliente_app/presentation/widgets/profile/profile_info_tile.dart';
import 'package:sabix_cliente_app/presentation/widgets/profile/profile_option_tile.dart';
import 'package:sabix_cliente_app/presentation/widgets/profile/profile_logout_button.dart';



class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con avatar, nombre, email y tipo de usuario
            ProfileHeader(user: user),

            const SizedBox(height: 24),

            // Sección de información (teléfono, dirección)
            if (user?.phone != null || user?.address != null)
              ProfileSection(
                title: 'Información',
                children: [
                  if (user?.phone != null)
                    ProfileInfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Teléfono',
                      value: user!.phone!,
                    ),
                  if (user?.address != null)
                    ProfileInfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'Dirección',
                      value: user!.address!,
                    ),
                ],
              ),

            // Sección de cuenta
            ProfileSection(
              title: 'Cuenta',
              children: [
                ProfileOptionTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Editar perfil',
                  onTap: () {},
                ),
                ProfileOptionTile(
                  icon: Icons.location_on_outlined,
                  label: 'Mis direcciones',
                  onTap: () {},
                ),
                ProfileOptionTile(
                  icon: Icons.payment_outlined,
                  label: 'Métodos de pago',
                  onTap: () {},
                ),
                ProfileOptionTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'Historial de pedidos',
                  onTap: () => context.goToOrders(),
                ),
              ],
            ),

            // Sección de soporte
            ProfileSection(
              title: 'Soporte',
              children: [
                ProfileOptionTile(
                  icon: Icons.settings_outlined,
                  label: 'Configuración',
                  onTap: () {},
                ),
                ProfileOptionTile(
                  icon: Icons.help_outline_rounded,
                  label: 'Ayuda y soporte',
                  onTap: () {},
                ),
              ],
            ),

            // Botón de cerrar sesión
            const ProfileLogoutButton(),
          ],
        ),
      ),
    );
  }
}
