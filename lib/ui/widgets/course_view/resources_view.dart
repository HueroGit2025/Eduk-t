import 'package:eudkt/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesView extends StatelessWidget {
  final dynamic files;
  const ResourcesView({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    if (files is List && files.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(30),
        itemCount: files.length,
        itemBuilder: (context, index) {
          final resource = files[index];
          return Card(
            color: fortyGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textColor: Colors.white,
              title: Text('Recurso ${index + 1}'),
              trailing: const Icon(Icons.download_rounded, color: Colors.white),
              onTap: () async {
                if (await canLaunchUrl(Uri.parse(resource))) {
                  await launchUrl(Uri.parse(resource), mode: LaunchMode.externalApplication);
                }
              },
            ),
          );
        },
      );
    }
    return const Center(child: Text('No hay recursos disponibles.'));  }
}
