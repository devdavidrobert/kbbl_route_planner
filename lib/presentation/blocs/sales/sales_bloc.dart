// lib/presentation/blocs/sales/sales_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import '../../../domain/usecases/fetch_orders_use_case.dart';
import '../../../domain/usecases/fetch_sales_data_use_case.dart';
import '../../../domain/usecases/place_order.dart';
import '../../../domain/usecases/enroll_customer.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/customer.dart';
import 'sales_event.dart';
import 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final FetchOrdersUseCase fetchOrdersUseCase;
  final PlaceOrderUseCase placeOrderUseCase;
  final EnrollCustomerUseCase enrollCustomerUseCase;
  final FetchSalesDataUseCase fetchSalesDataUseCase;
  final _logger = Logger('SalesBloc');
  List<Order>? _cachedOrders;
  String? _lastFetchedUserId;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  SalesBloc({
    required this.fetchOrdersUseCase,
    required this.placeOrderUseCase,
    required this.enrollCustomerUseCase,
    required this.fetchSalesDataUseCase,
  }) : super(const SalesInitial()) {
    on<FetchOrders>((event, emit) async {
      try {
        _logger.info('Fetching orders for user: ${event.userId}');
        emit(SalesLoading());

        final orders = await fetchOrdersUseCase.execute(event.userId);
        _logger.info('Successfully fetched ${orders.length} orders');
        emit(OrdersLoaded(orders: orders));
      } catch (e, stackTrace) {
        _logger.severe('Failed to fetch orders: $e\n$stackTrace');
        emit(SalesError(
            message: 'Unable to load orders. Please try again later.'));
      }
    });

    on<PlaceOrder>((event, emit) async {
      try {
        _logger.info('Placing order for customer: ${event.customerId}');
        emit(SalesLoading());
        final order = Order(
          id: DateTime.now().toIso8601String(),
          customerId: event.customerId,
          userId: event.userId,
          skus: event.skus,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await placeOrderUseCase.execute(order);
        _logger.info('Successfully placed order: ${order.id}');
        emit(OrderPlaced(orderId: order.id));
        add(FetchOrders(event.userId));
      } catch (e, stackTrace) {
        _logger.severe('Failed to place order: $e\n$stackTrace');
        emit(SalesError(message: 'Failed to place order: ${e.toString()}'));
      }
    });

    on<PlaceOrderEvent>((event, emit) async {
      try {
        _logger.info('Placing order for customer: ${event.order.customerId}');
        emit(SalesLoading());
        await placeOrderUseCase.execute(event.order);
        _logger.info('Successfully placed order: ${event.order.id}');

        // Invalidate cache
        _invalidateCache();

        // Fetch updated orders
        final orders = await fetchOrdersUseCase.execute(event.order.userId);
        _cachedOrders = orders;
        _lastFetchedUserId = event.order.userId;
        _lastFetchTime = DateTime.now();

        emit(OrderPlaced(orderId: event.order.id));
        emit(OrdersLoaded(orders: orders));
      } catch (e, stackTrace) {
        _logger.severe('Failed to place order: $e\n$stackTrace');
        emit(SalesError(message: 'Failed to place order: ${e.toString()}'));
      }
    });

    on<EnrollCustomer>((event, emit) async {
      try {
        _logger.info('Enrolling customer: ${event.customerName}');
        emit(SalesLoading());
        final customer = Customer(
          id: event.customerId,
          name: event.customerName,
          userId: event.userId,
          distributors: event.distributors,
          location: event.location,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await enrollCustomerUseCase.execute(customer);
        _logger.info('Successfully enrolled customer: ${customer.id}');

        // Invalidate cache
        _invalidateCache();

        emit(CustomerEnrolled(customerId: customer.id));
      } catch (e, stackTrace) {
        _logger.severe('Failed to enroll customer: $e\n$stackTrace');
        emit(SalesError(message: 'Failed to enroll customer: ${e.toString()}'));
      }
    });

    on<FetchSalesData>((event, emit) async {
      try {
        _logger.info('Fetching sales data for user: ${event.userId}');
        emit(SalesLoading());

        final customers =
            await fetchSalesDataUseCase.getCustomersWithSales(event.userId);
        final routePlans =
            await fetchSalesDataUseCase.getRoutePlans(event.userId);

        _logger.info(
            'Successfully fetched ${customers.length} customers and ${routePlans.length} route plans');
        emit(SalesDataLoaded(
          customers: customers,
          routePlans: routePlans,
          performance: null,
        ));
      } catch (e, stackTrace) {
        _logger.severe('Failed to fetch sales data: $e\n$stackTrace');
        emit(SalesError(message: 'Failed to load sales data: ${e.toString()}'));
      }
    });

    on<AddCustomerEvent>((event, emit) async {
      try {
        _logger.info('Adding customer: ${event.customer.name}');
        emit(SalesLoading());
        await enrollCustomerUseCase.execute(event.customer);
        _logger.info('Successfully added customer: ${event.customer.id}');
        emit(CustomerEnrolled(customerId: event.customer.id));
        add(FetchOrders(event.customer.userId));
      } catch (e, stackTrace) {
        _logger.severe('Failed to add customer: $e\n$stackTrace');
        emit(SalesError(message: 'Failed to add customer: ${e.toString()}'));
      }
    });
  }

  bool _canUseCachedOrders(String userId) {
    if (_cachedOrders == null || _lastFetchedUserId != userId) {
      return false;
    }

    final now = DateTime.now();
    return _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < _cacheDuration;
  }

  void _invalidateCache() {
    _cachedOrders = null;
    _lastFetchedUserId = null;
    _lastFetchTime = null;
  }
}
