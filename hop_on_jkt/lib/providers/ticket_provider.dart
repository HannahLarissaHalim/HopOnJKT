import 'package:flutter/material.dart';
import '../services/ticket_service.dart';

class TicketProvider extends ChangeNotifier {
  final TicketService _ticketService = TicketService();

  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = false;
  String _status = 'active';

  List<Map<String, dynamic>> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String get status => _status;

  Future<void> fetchTickets(String userId, {String? status}) async {
    _isLoading = true;
    notifyListeners();
    _status = status ?? 'active';
    _tickets = await _ticketService.getUserTickets(userId, status: _status);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> cancelTicket(String ticketId, String userId) async {
    await _ticketService.cancelTicket(ticketId);
    await fetchTickets(userId, status: _status);
  }

  // buy ticket
  Future<void> buyTicket({
    required String userId,
    required int price,
    required Map<String, dynamic> ticketData,
  }) async {
    // panggil function di service
    await _ticketService.buyTicket(
      userId: userId,
      price: price,
      ticketData: ticketData,
    );

    // refresh daftar tiket
    await fetchTickets(userId, status: _status); 
  }

  Future<void> refreshAndMarkExpired(String userId) async {
    await _ticketService.markExpiredTickets(userId); // cek expired
    await fetchTickets(userId, status: _status);     // reload tickets
  }

}
