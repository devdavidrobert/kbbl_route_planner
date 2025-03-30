// lib/presentation/blocs/customer/customer_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/enroll_customer.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final EnrollCustomerUseCase enrollCustomer;

  CustomerBloc(this.enrollCustomer) : super(CustomerInitial()) {
    on<AddCustomer>((event, emit) async {
      emit(CustomerLoading());
      try {
        await enrollCustomer(event.customer);
        emit(CustomerSuccess());
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    });
  }
}
