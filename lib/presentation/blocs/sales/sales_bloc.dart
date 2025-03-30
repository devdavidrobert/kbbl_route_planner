// lib/presentation/blocs/sales/sales_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/fetch_orders_use_case.dart';
import '../../../domain/usecases/place_order.dart';
import '../../../domain/usecases/enroll_customer.dart';
import 'sales_event.dart';
import 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final FetchOrdersUseCase fetchOrdersUseCase;
  final PlaceOrder placeOrderUseCase;
  final EnrollCustomer enrollCustomerUseCase;

  SalesBloc({
    required this.fetchOrdersUseCase,
    required this.placeOrderUseCase,
    required this.enrollCustomerUseCase,
  }) : super(SalesInitial()) {
    on<FetchOrders>((event, emit) async {
      emit(SalesLoading());
      try {
        print('SalesBloc: Fetching orders for user: ${event.userId}');
        final orders = await fetchOrdersUseCase.execute(event.userId);
        print('SalesBloc: Orders fetched successfully: ${orders.length} items');
        emit(OrdersLoaded(orders: orders));
      } catch (e) {
        print('SalesBloc: Error fetching orders: $e');
        emit(SalesError(message: e.toString()));
      }
    });

    on<PlaceOrder>((event, emit) async {
      emit(SalesLoading());
      try {
        print('SalesBloc: Placing order for user: ${event.userId}');
        final orderId = await placeOrderUseCase.execute(
          userId: event.userId,
          customerId: event.customerId,
          skus: event.skus,
        );
        print('SalesBloc: Order placed successfully: $orderId');
        emit(OrderPlaced(orderId: orderId));
        // Refresh the orders after placing the order
        add(FetchOrders(event.userId));
      } catch (e) {
        print('SalesBloc: Error placing order: $e');
        emit(SalesError(message: e.toString()));
      }
    });

    on<EnrollCustomer>((event, emit) async {
      emit(SalesLoading());
      try {
        print('SalesBloc: Enrolling customer for user: ${event.userId}');
        final customerId = await enrollCustomerUseCase.execute(
          customerId: event.customerId,
          customerName: event.customerName,
          userId: event.userId,
          distributors: event.distributors,
          invoiceName: event.invoiceName,
          location: event.location,
        );
        print('SalesBloc: Customer enrolled successfully: $customerId');
        emit(CustomerEnrolled(customerId: customerId));
      } catch (e) {
        print('SalesBloc: Error enrolling customer: $e');
        emit(SalesError(message: e.toString()));
      }
    });
  }
}
