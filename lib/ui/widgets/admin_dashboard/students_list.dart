import 'package:eudkt/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../services/app_snackbar.dart';
import '../../state_management/change_password/change_password_cubit.dart';
import '../../state_management/students_list/students_list_cubit.dart';
import '../../state_management/theme/theme_cubit.dart';
import '../profile_avatar.dart';

class StudentsList extends StatefulWidget {
  const StudentsList({super.key});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    return BlocBuilder<StudentsListCubit, List<Map<String, dynamic>>>(
      builder: (context, students) {
        final query = _searchController.text.trim();
        _filteredStudents = query.isEmpty
            ? students
            : students
            .where((s) => s['id']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? dark : light,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Listado de Alumnos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por matrícula...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: isDark ? dark2 : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                if (_filteredStudents.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              height: 100,
                              image: AssetImage('assets/empty-box.png'),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No se encontraron alumnos.',
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        return GestureDetector(
                          onTap: () =>
                              _showStudentDetails(context, student, isDark),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? dark2 : Colors.grey[50],
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ProfileAvatarBasic(
                                    imageUrl: student['image'], size: 40),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(student['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(student['id'],
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12)),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showStudentDetails(
      BuildContext context, Map<String, dynamic> student, isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? dark3 : light2,
            borderRadius: BorderRadius.circular(30),
          ),
          width: 600,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProfileAvatarBasic(imageUrl: student['image'], size: 60),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student['name'],
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text('Matrícula: ${student['id']}',
                            style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 5),
                        Text(student['career'],
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Cursos Inscritos',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo),
              ),
              const SizedBox(height: 15),

              if (student['courses'] == null ||
                  (student['courses'] as List).isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Image(
                            height: 100, image: AssetImage('assets/empty-box.png')),
                        Text(
                          'Este alumno no cuenta con cursos inscritos.',
                          style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...student['courses'].map<Widget>((courseId) {
                  final progress = student['progress'][courseId] ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? dark2 : Colors.grey[50],
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.book, color: secondaryBlue),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            student['courseNames'][courseId],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: progress.toDouble(),
                                decoration: BoxDecoration(
                                  color: secondaryBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$progress%',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: secondaryBlue),
                        ),
                      ],
                    ),
                  );
                }).toList(),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                      _showChangePasswordDialog(context, student['id'], isDark);
                    },
                    child: Text(
                      'Cambiar contraseña',
                      style: TextStyle(color: mainRed),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Cerrar',
                      style: TextStyle(color: secondaryBlue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(
      BuildContext context, String studentId, bool isDark) {
    final confirmController = TextEditingController();
    final newController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? dark3 : light2,
        title: const Text("Cambiar contraseña"),
        content: BlocProvider(
          create: (_) => ChangePasswordCubit(),
          child: BlocListener<ChangePasswordCubit, ChangePasswordState>(
            listener: (ctx, state) {
              if (state is Success) {
                AppSnackBar.showSuccess(state.message);
                context.pop();
              } else if (state is Error) {
                AppSnackBar.showError(state.error);
              }
            },
            child: SizedBox(
              width: 400,
              height: 150,
              child: Column(
                children: [
                  TextFormField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Nueva contraseña",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: newController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirmar contraseña",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text("Cancelar",style: TextStyle(color: secondaryBlue),),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryBlue,
              foregroundColor: Colors.white
            ),
            onPressed: () {
              if (confirmController.text != newController.text) {
                AppSnackBar.showError("Las contraseñas no coinciden");
              } else {
                if (newController.text.trim().length < 6) {
                  AppSnackBar.showError("La contraseña debe tener al menos 6 caracteres");
                  return;
                }
                context.read<ChangePasswordCubit>().changeStudentPassword(studentId: studentId, newPassword: newController.text.trim());
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

}

