import 'package:eudkt/ui/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../resources/colors.dart';
import '../../services/shared_preference.dart';
import '../state_management/theme/theme_cubit.dart';
import 'change_password_overlay.dart';
import 'help_view.dart';

class ProfileButton extends StatefulWidget {
  final VoidCallback? onImageUpdated;
  const ProfileButton({super.key, this.onImageUpdated});

  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleMenu() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _overlayEntry = _buildOverlayEntry(context.read<ThemeCubit>().state.isDarkMode);
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _buildOverlayEntry(bool isDark) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    double screenWidth = MediaQuery.of(context).size.width;

    double menuWidth = 280;
    double positionLeft = offset.dx - menuWidth + size.width;

    if (positionLeft < 16) {
      positionLeft = 16;
    }

    if (positionLeft + menuWidth > screenWidth - 16) {
      positionLeft = screenWidth - menuWidth - 16;
    }

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlay,
        child: Stack(
          children: [
            Positioned(
              top: offset.dy + size.height + 8,
              left: positionLeft,
              child: Material(
                elevation: 8,
                color: isDark ? dark2 : light,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: menuWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _toggleMenu,
                        ),
                      ),
                      ProfileAvatar(imageUrl: SharedPreferencesService.image!,onImageUpdated: widget.onImageUpdated,),
                      const SizedBox(height: 8),
                      Text(
                        '¡Hola, ${SharedPreferencesService.name}!',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Matricula: ${SharedPreferencesService.enrollment}'),
                      const Divider(height: 24),
                      ListTile(
                        leading: const Icon(Icons.key_rounded),
                        title: const Text('Actualizar contraseña'),
                        onTap: () {
                          showChangePasswordOverlay(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.help_rounded),
                        title: const Text('Ayuda'),
                        onTap: () {
                          _toggleMenu();
                         showHelpOverlay(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Cerrar sesión'),
                        onTap: () {
                          _toggleMenu();
                          var role = SharedPreferencesService.role;
                          SharedPreferencesService.logout();
                          if (role == 'admin') {
                            context.go('/admin');
                          } else if (role == 'supervisor') {
                            context.go('/supervisor');
                          }else if(role == 'teacher'){
                            context.go('/');
                          }

                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ThemeCubit, ThemeState>(
      listenWhen: (previous, current) => previous.isDarkMode != current.isDarkMode,
      listener: (context, state) {
        if (_overlayEntry != null) {
          _removeOverlay();
          _showOverlay();
        }
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: GestureDetector(
          onTap: _toggleMenu,
          child: ProfileAvatarBasic(imageUrl: SharedPreferencesService.image!, size: 40)
        ),
      ),
    );
  }
}
