import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/item.dart';
import '../../domain/usecases/get_items_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetItemsUseCase getItems;

  HomeBloc({required this.getItems}) : super(HomeInitial()) {
    on<LoadItemsEvent>(_onLoadItems);
    on<RefreshItemsEvent>(_onRefreshItems);
  }

  Future<void> _onLoadItems(LoadItemsEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    final result = await getItems();
    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (items) => emit(HomeLoaded(items: items)),
    );
  }

  Future<void> _onRefreshItems(RefreshItemsEvent event, Emitter<HomeState> emit) async {
    final result = await getItems();
    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (items) => emit(HomeLoaded(items: items)),
    );
  }
}
