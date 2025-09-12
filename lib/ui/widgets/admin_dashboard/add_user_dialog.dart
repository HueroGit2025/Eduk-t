import 'package:eudkt/services/app_snackbar.dart';
import 'package:eudkt/services/shared_preference.dart';
import 'package:eudkt/ui/state_management/add_user/add_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddUserDialog extends StatefulWidget {
  final bool isStudent;
  const AddUserDialog({super.key, required this.isStudent});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  bool isVisible = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController semesterController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController enrollmentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddUserCubit, AddUserState>(
      listener: (context, state) {
        if (state is Error) {
          AppSnackBar.showError('Error al realizar el registro');
        }
        context.pop();
        AppSnackBar.showSuccess('Registro exitoso');
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isStudent
                    ? 'Añadir Nuevo Alumno'
                    : 'Añadir Nuevo Docente',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigoAccent,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: enrollmentController,
                decoration: InputDecoration(
                  labelText: 'Matrícula',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              if (widget.isStudent) const SizedBox(height: 15),
              if (widget.isStudent)
                DropdownButtonFormField<int>(
                  initialValue: int.tryParse(semesterController.text.isNotEmpty
                      ? semesterController.text
                      : '1'),
                  items: List.generate(
                    9,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}° semestre'),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      semesterController.text = value.toString();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Semestre',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: isVisible,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  suffixIcon: IconButton(
                    icon: Icon(
                        isVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => isVisible = !isVisible),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar',
                        style: TextStyle(color: Colors.indigoAccent)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AddUserCubit>().addUser(
                            name: nameController.text,
                            enrollment: enrollmentController.text,
                            password: passwordController.text,
                            semester: widget.isStudent
                                ? int.tryParse(semesterController.text)
                                : null,
                            isStudent: widget.isStudent,
                            career: SharedPreferencesService.career!,
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Guardar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
