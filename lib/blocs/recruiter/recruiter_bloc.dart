import 'package:flutter_bloc/flutter_bloc.dart';

import '../../backend/recruiter/recruiter_repository.dart';
import 'recruiter_events.dart';
import 'recruiter_state.dart';

class RecruiterBloc extends Bloc<RecruiterEvent, RecruiterState> {
  final RecruiterRepository repository;

  RecruiterBloc({required this.repository})
      : super(RecruiterState.initial()) {

    /// 🔹 Load recruiter
    on<LoadRecruiter>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));

      try {
        final data = await repository.getRecruiter(event.id);

        emit(state.copyWith(
          isLoading: false,
          recruiter: data,
        ));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      }
    });

    /// 🔹 Mark viewed (no UI loading needed)
    on<MarkViewed>((event, emit) async {
      try {
        await repository.markViewed(event.id);
      } catch (_) {
        // silently fail (tracking should not break UX)
      }
    });

    /// 🔹 Generate AI content
    on<GenerateContent>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));

      try {
        /// TODO: Replace with Groq API
        final generated = "AI generated content for: ${event.prompt}";

        emit(state.copyWith(
          isLoading: false,
          generatedContent: generated,
        ));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          error: "Failed to generate content",
        ));
      }
    });

    /// 🔹 Save recruiter
    on<SaveRecruiter>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));

      try {
        await repository.saveRecruiter(event.data);

        emit(state.copyWith(isLoading: false));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          error: "Failed to save recruiter",
        ));
      }
    });

    /// 🔹 Fetch all recruiters
    on<FetchAllRecruiters>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));

      try {
        final list = await repository.getAllRecruiters();

        emit(state.copyWith(
          isLoading: false,
          recruiters: list,
        ));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          error: "Failed to fetch recruiters",
        ));
      }
    });
  }
}