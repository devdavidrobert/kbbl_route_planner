import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/fetch_orders_use_case.dart';
import '../../../domain/usecases/place_order.dart';
import '../../../domain/usecases/enroll_customer.dart';
import '../../../domain/usecases/fetch_sales_data_use_case.dart';
import 'sales_event.dart';
import 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final FetchOrdersUseCase fetchOrdersUseCase;
  final PlaceOrderUseCase placeOrderUseCase;
  final EnrollCustomerUseCase enrollCustomerUseCase;
  final FetchSalesDataUseCase fetchSalesDataUseCase;

  SalesBloc({
    required this.fetchOrdersUseCase,
    required this.placeOrderUseCase,
    required this.enrollCustomerUseCase,
    required this.fetchSalesDataUseCase,
  }) : super(SalesInitial()) {
    on<FetchOrders>((event, emit) async {
      emit(SalesLoading());
      try {
        final orders = await fetchOrdersUseCase(event.userId); // String userId
        emit(OrdersLoaded(orders));
      } catch (e) {
        emit(SalesError('Failed to fetch orders: $e'));
      }
    });

    on<PlaceOrderEvent>((event, emit) async {
      emit(SalesLoading());
      try {
        await placeOrderUseCase(event.order); // Order object
        emit(OrderPlaced(event.order.id));
        final orders = await fetchOrdersUseCase(event.order.userId); // String userId
        emit(OrdersLoaded(orders));
      } catch (e) {
        emit(SalesError('Failed to place order: $e'));
      }
    });

    on<EnrollCustomer>((event, emit) async {
      emit(SalesLoading());
      try {
        await enrollCustomerUseCase(event.customer); // Customer object
        emit(CustomerEnrolled(event.customer.id));
      } catch (e) {
        emit(SalesError('Failed to enroll customer: $e'));
      }
    });

    on<FetchSalesData>((event, emit) async {
      emit(SalesLoading());
      try {
        await fetchSalesDataUseCase(event.userId); // String userId
        emit(const OrdersLoaded([])); // Placeholder; adjust if fetchSalesDataUseCase returns data
      } catch (e) {
        emit(SalesError('Failed to fetch sales data: $e'));
      }
    });
  }
}