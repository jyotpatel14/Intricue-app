import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/recruiter/recruiter_bloc.dart';
import '../../blocs/recruiter/recruiter_events.dart';
import '../../blocs/recruiter/recruiter_state.dart';

class RecruiterScreen extends StatefulWidget {
  final String id;
  const RecruiterScreen({super.key, required this.id});

  @override
  State<RecruiterScreen> createState() => _RecruiterScreenState();
}

class _RecruiterScreenState extends State<RecruiterScreen> {
  @override
  void initState() {
    super.initState();

    @override
    void initState() {
      super.initState();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<RecruiterBloc>().add(LoadRecruiter(widget.id));
        context.read<RecruiterBloc>().add(MarkViewed(widget.id));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RecruiterBloc, RecruiterState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = state.recruiter;

          if (data == null) {
            return const Center(child: Text("Not found"));
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Hi ${data['name']} 👋",
                  style: const TextStyle(fontSize: 24),
                ),

                const SizedBox(height: 10),

                Text("From ${data['company']}"),

                const SizedBox(height: 20),

                const Text("This page was created just for you."),
              ],
            ),
          );
        },
      ),
    );
  }
}
