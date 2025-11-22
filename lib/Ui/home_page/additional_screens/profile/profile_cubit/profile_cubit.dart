import 'package:codexa_mobile/Ui/home_page/additional_screens/profile/profile_cubit/profile_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Domain/usecases/profile/update_profile_usecase.dart';

class ProfileCubit<T> extends Cubit<ProfileState> {
  final UpdateProfileUseCase<T> updateProfileUseCase;

  ProfileCubit({required this.updateProfileUseCase}) : super(ProfileInitial());

  Future<void> updateProfile(T user) async {
    emit(ProfileLoading());
    final result = await updateProfileUseCase(user);
    result.fold(
      (failure) => emit(ProfileError(failure)),
      (updatedUser) => emit(ProfileSuccess<T>(updatedUser)),
    );
  }
}
