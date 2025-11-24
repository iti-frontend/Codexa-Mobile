import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/profile/profile_cubit/profile_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

class ProfileCubit<T> extends Cubit<ProfileState> {
  final dynamic updateProfileUseCase;

  ProfileCubit({required this.updateProfileUseCase}) : super(ProfileInitial());

  Future<void> updateProfile(T user) async {
    print('🔄 ProfileCubit: Starting updateProfile...');
    print('📝 User type: ${user.runtimeType}');
    print('🎯 UseCase type: ${updateProfileUseCase.runtimeType}');

    emit(ProfileLoading());

    try {
      print('📡 Calling use case with user: $user');

      // Call the use case
      final Either<Failures, T> result = await updateProfileUseCase.call(user);

      // Handle the result
      result.fold(
            (failure) {
          print('❌ Profile update failed: ${failure.errorMessage}');
          emit(ProfileError(failure));
        },
            (updatedUser) {
          print('✅ Profile update successful: $updatedUser');
          // FIX: Remove named parameter, use positional argument
          emit(ProfileSuccess<T>(updatedUser));
        },
      );
    } catch (e, stackTrace) {
      print('💥 Exception in ProfileCubit: $e');
      print('📋 Stack trace: $stackTrace');
      emit(ProfileError(Failures(errorMessage: 'Unexpected error: $e')));
    }
  }
}