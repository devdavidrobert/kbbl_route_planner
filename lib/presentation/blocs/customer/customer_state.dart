// lib/presentation/blocs/customer/customer_state.dart
abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerSuccess extends CustomerState {}

class CustomerError extends CustomerState {
  final String message;

  CustomerError(this.message);
}
