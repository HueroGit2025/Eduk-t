import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';

import '../../state_management/theme/theme_cubit.dart';

class TheoryView extends StatelessWidget {
  final dynamic contentJson;

  const TheoryView({super.key, required this.contentJson});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.sizeOf(context).height;
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;
    final bool isMobile = MediaQuery.sizeOf(context).width < 750;

    try {
      List<Map<String, dynamic>> delta;

      if (contentJson is String) {
        final decoded = jsonDecode(contentJson);
        delta = List<Map<String, dynamic>>.from(decoded);
      } else {
        delta = List<Map<String, dynamic>>.from(contentJson);
      }

      final doc = Document.fromJson(delta);

      return Stack(
        children: [
          SvgPicture.asset(
            isMobile
                ? isDark
                ? 'assets/notebook_dark.svg'
                : 'assets/notebook.svg'
                : isDark
                ? 'assets/notebook_large_dark.svg'
                : 'assets/notebook_large.svg',
            fit: BoxFit.fitHeight,
          ),

          Center(
            child: Container(
              height: height * 0.7,
              width: isMobile ? 450 : 650,
              padding: const EdgeInsets.only(left: 100, right: 60),
              child: QuillEditor(
                scrollController: ScrollController(),
                focusNode: FocusNode(),
                controller: QuillController(
                  readOnly: true,
                  document: doc,
                  selection: const TextSelection.collapsed(offset: 0),
                ),
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return Center(
        child: Text('Error al cargar contenido teórico: $e'),
      );
    }
  }
}
