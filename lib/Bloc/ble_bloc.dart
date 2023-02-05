import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'ble_event.dart';
part 'ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  static BleBloc get(context) => BlocProvider.of(context);
  BleBloc() : super(BleInitial()) {
    on<BleEvent>((event, emit) {
    });
  }
}
