import 'package:flutter/material.dart';

import '../../../resources/colors.dart';
import '../../../resources/course_creator_globals.dart';

class EvaluationCard extends StatefulWidget {
  final Unity unity;

  const EvaluationCard({super.key, required this.unity});

  @override
  State<EvaluationCard> createState() => _EvaluationCardState();
}

class _EvaluationCardState extends State<EvaluationCard> {
  bool isExpanded = false;

  void _addQuestion() {
    setState(() {
      widget.unity.questions.add(Question());
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      widget.unity.questions[index].dispose();
      widget.unity.questions.removeAt(index);
    });
  }

  InputDecoration _roundedInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
    );
  }

  ButtonStyle _roundedButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: mainPurple,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: IconButton(
              icon: Icon(
                isExpanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: Colors.white,
              ),
              onPressed: _toggleExpand,
            ),
            title: Row(
              children: const [
                Icon(Icons.list_alt_rounded, color: Colors.white),
                SizedBox(width: 20),
                Text(
                  'Evaluación',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipo de evaluación:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {
                          widget.unity.isExam = false;
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.unity.isExam
                              ? Colors.deepPurpleAccent
                              : Colors.white,
                        ),
                        child: Text(
                          'Proyecto',
                          style: TextStyle(
                            color: widget.unity.isExam
                                ? Colors.white
                                : Colors.deepPurpleAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          widget.unity.isExam = true;
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.unity.isExam
                              ? Colors.white
                              : Colors.deepPurpleAccent,
                        ),
                        child: Text(
                          'Examen',
                          style: TextStyle(
                            color: widget.unity.isExam
                                ? Colors.deepPurpleAccent
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (!widget.unity.isExam)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        maxLines: 5,
                        textAlign: TextAlign.justify,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          alignLabelWithHint: true,
                          labelText: 'Descripción del proyecto...',
                        ),
                        onChanged: (value) {
                          widget.unity.projectDescription = value;
                        },
                      ),
                    ),

                  if (widget.unity.isExam) ...[
                    for (int i = 0; i < widget.unity.questions.length; i++)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        margin: const EdgeInsets.only(bottom: 20),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: widget.unity.questions[i].questionController,
                                decoration: _roundedInputDecoration('Pregunta ${i + 1}'),
                                onChanged: (_) => widget.unity.questions[i].syncValues(),
                              ),
                              const SizedBox(height: 16),
                              ...List.generate(4, (j) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Text('${String.fromCharCode(65 + j)}) '),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: widget.unity.questions[i].optionControllers[j],
                                          decoration: _roundedInputDecoration('Opción ${j + 1}'),
                                          onChanged: (_) => widget.unity.questions[i].syncValues(),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Radio<int>(
                                        value: j,
                                        groupValue: widget.unity.questions[i]
                                            .correctAnswerIndex,
                                        onChanged: (value) {
                                          setState(() {
                                            widget.unity.questions[i]
                                                .correctAnswerIndex =
                                            value!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => _removeQuestion(i),
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Eliminar pregunta'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _addQuestion,
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar Pregunta'),
                      style: _roundedButtonStyle(Colors.white),
                    ),
                  ]
                ],
              ),
            ),
        ],
      ),
    );
  }
}
