import 'package:eudkt/services/app_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../resources/colors.dart';
import '../../services/update_profile.dart';

class ProfileAvatar extends StatefulWidget {
  final String imageUrl;
  final VoidCallback? onImageUpdated;

  const ProfileAvatar({
    super.key,
    required this.imageUrl, this.onImageUpdated,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showChangeImageDialog(context),
        child: widget.imageUrl.isEmpty ?
        ClipOval(
          child:SvgPicture.asset(
            'assets/profile.svg',
            height: 80,
          )
        ):
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(widget.imageUrl),
        ),
      ),
    );
  }

  void _showChangeImageDialog(BuildContext context) {
    PlatformFile? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Cambiar Imagen'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedImage == null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(type: FileType.image);
                      if (result != null && result.files.isNotEmpty) {
                        setState(() {
                          selectedImage = result.files.first;
                        });
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("Seleccionar imagen"),
                  )
                else
                  Row(
                    children: [
                      Expanded(child: Text(selectedImage!.name, overflow: TextOverflow.ellipsis)),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => setState(() => selectedImage = null),
                      ),
                    ],
                  ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: secondaryBlue,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (selectedImage == null){
                    AppSnackBar.showError('Debes seleccionar una imagen');
                    return;
                  }
                  await updateImageProfile(selectedImage!);
                  AppSnackBar.showSuccess('Imagen actualizada');
                  widget.onImageUpdated?.call();
                  context.pop();
                },
                child: const Text('Cambiar'),
              ),
            ],
          ),
        );
      },
    ).then((file) {
      if (file != null && file is PlatformFile) {
        setState(() {
        });
      }
    });
  }
}

class ProfileAvatarBasic extends StatelessWidget{
  final String imageUrl;
  final double size;

  const ProfileAvatarBasic({
    super.key,
    required this.imageUrl,
    required this.size
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: imageUrl.isEmpty ?
      ClipOval(
          child:SvgPicture.asset(
            'assets/profile.svg',
            height: size,
          )
      ):
      CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(imageUrl),
      ),
    );
  }

}
