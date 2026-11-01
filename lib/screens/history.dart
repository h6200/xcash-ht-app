import 'package:flutter/material.dart';
import '../api.dart';
import '../theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final t = await Api.myTransactions();
      if (mounted) setState(() { _transactions = t; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kPageGradient),
        child: SafeArea(
          child: Column(
            children: [
              _appBar(),
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF059669),
                  onRefresh: _load,
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
                      : _transactions.isEmpty
                          ? const Center(
                              child: Text(
                                'Poko gen tranzaksyon anrejistre.',
                                style: TextStyle(color: Color(0xFF64748B)),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _transactions.length,
                              itemBuilder: (ctx, i) => _row(_transactions[i]),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF052E22), Color(0xFF064E3B)],
        ),
        boxShadow: [
          BoxShadow(color: Color(0x22052E22), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.receipt_long, color: Colors.white),
          SizedBox(width: 10),
          Text(
            'Istwa Tranzaksyon',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(dynamic t) {
    final type = t['type']?.toString() ?? '';
    final amount = (t['amount'] ?? 0).toDouble();
    final note = t['note']?.toString() ?? '';
    final date = t['created_at']?.toString() ?? '';

    IconData icon;
    Color color;
    String sign;
    String label;

    switch (type) {
      case 'deposit':
        icon = Icons.arrow_downward;
        color = const Color(0xFF059669);
        sign = '+';
        label = 'Depo';
        break;
      case 'withdrawal':
        icon = Icons.arrow_upward;
        color = const Color(0xFFDC2626);
        sign = '-';
        label = 'Retrait';
        break;
      case 'investment_payout':
        icon = Icons.celebration;
        color = const Color(0xFF059669);
        sign = '+';
        label = 'Peman Plan (1h45m)';
        break;
      case 'investment_deduct':
        icon = Icons.trending_up;
        color = const Color(0xFFD97706);
        sign = '-';
        label = 'Achte Plan';
        break;
      case 'gift':
        icon = Icons.card_giftcard;
        color = const Color(0xFF7C3AED);
        sign = '+';
        label = 'Kado';
        break;
      case 'withdrawal_refund':
        icon = Icons.replay;
        color = const Color(0xFF2563EB);
        sign = '+';
        label = 'Ranbousman';
        break;
      default:
        icon = Icons.swap_horiz;
        color = const Color(0xFF64748B);
        sign = '';
        label = type;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(note.isEmpty ? date : note, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          Text(
            '$sign${amount.abs().toStringAsFixed(2)} HTG',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
