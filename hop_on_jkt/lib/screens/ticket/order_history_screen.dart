import 'package:flutter/material.dart';
import '../../services/ticket_service.dart';
import '../../widgets/ticket_card.dart';
import 'ticket_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String userId;
  const OrderHistoryScreen({super.key, required this.userId});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedTab = 'ongoing';
  late Future<List<Map<String, dynamic>>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  String get firestoreStatus {
    if (_selectedTab == 'ongoing') return 'active';
    if (_selectedTab == 'history') return 'expired';
    return 'active';
  }

  void _loadTickets() {
    final service = TicketService();
    service.markExpiredTickets(widget.userId);
    setState(() {
      _ticketsFuture = service.getUserTickets(
        widget.userId,
        status: firestoreStatus,
      );
    });
  }

  Widget _buildTabChip(
    String tabName,
    String displayLabel,
    BuildContext context,
  ) {
    return ChoiceChip(
      label: Text(
        displayLabel,
        style: TextStyle(
          color: _selectedTab == tabName
              ? const Color(0xFF3B658D)
              : const Color(0xFF248ABA),
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: _selectedTab == tabName,
      selectedColor: const Color(0xFFA4D1EE),
      backgroundColor: const Color(0xFFE7F2F8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _selectedTab == tabName
              ? const Color(0xFF3B658D)
              : const Color(0xFF248ABA),
          width: 1.5,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedTab = tabName;
            _loadTickets();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 25.0),
            child: Text(
              'MY ORDERS',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color.fromRGBO(18, 68, 109, 1),
                fontSize: 40,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Row(
              children: [
                _buildTabChip('ongoing', 'ongoing', context),
                const SizedBox(width: 10),
                _buildTabChip('history', 'history', context),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _ticketsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final tickets = snapshot.data ?? [];
                if (tickets.isEmpty) {
                  return const Center(child: Text('No tickets found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TicketCard(
                        ticket: ticket,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TicketDetailScreen(ticket: ticket),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
