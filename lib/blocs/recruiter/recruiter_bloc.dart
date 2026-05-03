// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../backend/recruiter/recruiter_repository.dart';
// import 'recruiter_events.dart';
// import 'recruiter_state.dart';

// class RecruiterBloc extends Bloc<RecruiterEvent, RecruiterState> {
//   final RecruiterRepository repository;

//   RecruiterBloc({required this.repository})
//       : super(RecruiterState.initial()) {

//     /// 🔹 Load recruiter
//     on<LoadRecruiter>((event, emit) async {
//       emit(state.copyWith(isLoading: true, error: null));

//       try {
//         final data = await repository.getRecruiter(event.id);

//         emit(state.copyWith(
//           isLoading: false,
//           recruiter: data,
//         ));
//       } catch (e) {
//         emit(state.copyWith(
//           isLoading: false,
//           error: e.toString(),
//         ));
//       }
//     });

//     /// 🔹 Mark viewed (no UI loading needed)
//     on<MarkViewed>((event, emit) async {
//       try {
//         await repository.markViewed(event.id);
//       } catch (_) {
//         // silently fail (tracking should not break UX)
//       }
//     });

//     /// 🔹 Generate AI content
//     on<GenerateContent>((event, emit) async {
//   emit(state.copyWith(isLoading: true, error: null));

//   try {
//     final generated = await repository.extractProfile(event.prompt);

//     emit(state.copyWith(
//       isLoading: false,
//       generatedData: generated,
//     ));
//   } catch (e) {
//     emit(state.copyWith(
//       isLoading: false,
//       error: "Failed to generate content",
//     ));
//   }
// });

//     /// 🔹 Save recruiter
//     on<SaveRecruiter>((event, emit) async {
//       emit(state.copyWith(isLoading: true, error: null));

//       try {
//         await repository.saveRecruiter(event.data);

//         emit(state.copyWith(isLoading: false));
//       } catch (e) {
//         emit(state.copyWith(
//           isLoading: false,
//           error: "Failed to save recruiter",
//         ));
//       }
//     });

//     /// 🔹 Fetch all recruiters
//     on<FetchAllRecruiters>((event, emit) async {
//       emit(state.copyWith(isLoading: true, error: null));

//       try {
//         final list = await repository.getAllRecruiters();

//         emit(state.copyWith(
//           isLoading: false,
//           recruiters: list,
//         ));
//       } catch (e) {
//         emit(state.copyWith(
//           isLoading: false,
//           error: "Failed to fetch recruiters",
//         ));
//       }
//     });
//   }
// }

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../backend/recruiter/recruiter_repository.dart';
import 'recruiter_events.dart';
import 'recruiter_state.dart';

class RecruiterBloc extends Bloc<RecruiterEvent, RecruiterState> {
  final RecruiterRepository repository;

  RecruiterBloc({required this.repository}) : super(RecruiterState.initial()) {

    /// 🔹 Load single recruiter
    on<LoadRecruiter>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final data = await repository.getRecruiter(event.id);
        emit(state.copyWith(isLoading: false, recruiter: data));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    /// 🔹 Mark viewed
    on<MarkViewed>((event, emit) async {
      try {
        await repository.markViewed(event.id);
      } catch (_) {}
    });

    /// 🔹 Generate AI content
    on<GenerateContent>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final generated = await repository.extractProfile(event.prompt);
        emit(state.copyWith(isLoading: false, generatedData: generated));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          error: "Failed to generate content",
        ));
      }
    });

    /// 🔹 Save recruiter — stores doc ID in state
    on<SaveRecruiter>((event, emit) async {
      emit(state.copyWith(isSaving: true, error: null));
      try {
        final docId = await repository.saveRecruiter(event.data);
        emit(state.copyWith(
          isSaving: false,
          savedDocId: docId,
        ));
      } catch (e) {
        emit(state.copyWith(
          isSaving: false,
          error: "Failed to save recruiter",
        ));
      }
    });

    /// 🔹 Fetch first page
    on<FetchAllRecruiters>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final result = await repository.getRecruiters();
        emit(state.copyWith(
          isLoading: false,
          recruiters: result.items,
          lastDoc: result.lastDoc,
          hasMore: result.items.length == 10,
        ));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: "Failed to fetch recruiters"));
      }
    });

    /// 🔹 Load next page (append)
    on<FetchMoreRecruiters>((event, emit) async {
      if (!state.hasMore || state.isLoading) return;
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final result = await repository.getRecruiters(startAfter: state.lastDoc);
        emit(state.copyWith(
          isLoading: false,
          recruiters: [...state.recruiters, ...result.items],
          lastDoc: result.lastDoc,
          hasMore: result.items.length == 10,
        ));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: "Failed to load more"));
      }
    });

    /// 🔹 Clear saved doc ID (after dialog closes)
    on<ClearSavedDoc>((event, emit) {
      emit(RecruiterState(
        isLoading: false,
        recruiters: state.recruiters,
        hasMore: state.hasMore,
        lastDoc: state.lastDoc,
      ));
    });
  }
}