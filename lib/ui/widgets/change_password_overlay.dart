import 'package:eudkt/services/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resources/colors.dart';
import '../state_management/change_password/change_password_cubit.dart';

OverlayEntry? _passwordOverlay;

void showChangePasswordOverlay(BuildContext context) {
  _passwordOverlay?.remove();
  _passwordOverlay = null;

  final overlay = OverlayEntry(
    builder: (ctx) {
      return BlocProvider(
        create: (_) => ChangePasswordCubit(),
        child: BlocListener<ChangePasswordCubit, ChangePasswordState>(
          listener: (ctx, state) {
            if (state is Success) {
              AppSnackBar.showSuccess(state.message);
              _passwordOverlay?.remove();
              _passwordOverlay = null;
            } else if (state is Error) {
              AppSnackBar.showError(state.error);
            }
          },
          child: Material(
            color: Colors.black38,
            child: Center(
              child: _ChangePasswordForm(),
            ),
          ),
        ),
      );
    },
  );

  Overlay.of(context).insert(overlay);
  _passwordOverlay = overlay;
}

class _ChangePasswordForm extends StatefulWidget {
  const _ChangePasswordForm();

  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _confirmController = TextEditingController();
  final _newController = TextEditingController();

  @override
  void dispose() {
    _confirmController.dispose();
    _newController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ChangePasswordCubit>().state;

    return Container(
      width: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text("Cambiar Contraseña", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  _passwordOverlay?.remove();
                  _passwordOverlay = null;
                },
              )
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Nueva contraseña",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _newController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Confirmar contraseña",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
          const SizedBox(height: 20),
          state is Loading
              ? CircularProgressIndicator()
              : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              if (_confirmController.text != _newController.text) {
                AppSnackBar.showError("Las contraseñas no coinciden");
              } else {
                if (_newController.text.trim().length < 6) {
                  AppSnackBar.showError("La contraseña debe tener al menos 6 caracteres");
                  return;
                }
                context.read<ChangePasswordCubit>().changePassword(newPassword: _newController.text.trim());
              }
            },
            child: Text("Actualizar"),
          ),
        ],
      ),
    );
  }
}
