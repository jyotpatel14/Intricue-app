import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/recruiter/recruiter_bloc.dart';
import '../../blocs/recruiter/recruiter_events.dart';
import '../../blocs/recruiter/recruiter_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final promptCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Intricue Dashboard")),

      body: Column(
        children: [
          /// AI input
          TextField(
            controller: promptCtrl,
            decoration: const InputDecoration(
              hintText: "Enter recruiter profile...",
            ),
          ),

          ElevatedButton(
            onPressed: () {
              context.read<RecruiterBloc>().add(
                    GenerateContent(promptCtrl.text),
                  );
            },
            child: const Text("Generate"),
          ),

          /// Generated content
          BlocBuilder<RecruiterBloc, RecruiterState>(
            builder: (context, state) {
              return Text(state.generatedContent ?? "");
            },
          ),

          /// Save button
          ElevatedButton(
            onPressed: () {
              context.read<RecruiterBloc>().add(
                    SaveRecruiter({
                      "name": "Generated Name",
                      "company": "Generated Company",
                      "content": "Generated Content",
                    }),
                  );
            },
            child: const Text("Save"),
          ),

          /// Navigate to list
          ElevatedButton(
            onPressed: () {
              context.read<RecruiterBloc>().add(FetchAllRecruiters());
            },
            child: const Text("Load Recruiters"),
          ),
        ],
      ),
    );
  }
}