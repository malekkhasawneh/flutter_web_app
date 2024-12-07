import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  HomeCubit() : super(HomeInitial());

  bool _en = true;

  bool get en => _en;

  void toggleLanguage() {
    emit(HomeLoading());
    _en = !_en;
    emit(HomeLoaded());
  }

  void setLanguage(bool isEnglish) {
    emit(HomeLoading());
    _en = isEnglish;
    emit(HomeLoaded());
  }
}
