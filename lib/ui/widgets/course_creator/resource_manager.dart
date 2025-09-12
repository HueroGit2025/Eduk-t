import 'package:eudkt/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ResourceManager extends StatefulWidget {
  final List<PlatformFile> resources;

  const ResourceManager({super.key, required this.resources});

  @override
  State<ResourceManager> createState() => _ResourceManagerState();
}

class _ResourceManagerState extends State<ResourceManager> {
  Future<void> _addResource() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        widget.resources.addAll(result.files);
      });
    }
  }

  void _removeResource(int index) {
    setState(() {
      widget.resources.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.resources.isEmpty)
          const Text(
            "No hay recursos agregados",
            style: TextStyle(color: Colors.white),
          ),
        for (int i = 0; i < widget.resources.length; i++)
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: fortyGreen,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Recurso: ${widget.resources[i].name}',
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () => _removeResource(i),

                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: fortyGreen,
            foregroundColor: light
          ),
          onPressed: _addResource,
          icon: const Icon(Icons.upload_file),
          label: const Text("Agregar Recursos"),
        ),
      ],
    );
  }
}
