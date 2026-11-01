import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api.dart';
import '../theme.dart';

class WithdrawScreen extends StatefulWidget {
  final VoidCallback onBack;
  const WithdrawScreen({super.key, required this.onBack});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _phone = TextEditingController();
  final _amount = TextEditingController();
  String _provider = 'moncash';
  bool _submitting = false;
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _phone.addListener(_autoDetectProvider);
  }

  @override
  void dispose() {
    _phone.removeListener(_autoDetectProvider);
    _phone.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _autoDetectProvider() {
    final raw = _phone.text.replaceAll(RegExp(r'\D'), '');
    String digits = raw;
    if (digits.startsWith('509') && digits.length >= 5) {
      digits = digits.substring(3);
    }
    if (digits.startsWith('55') ||
        digits.startsWith('40') ||
        digits.startsWith('41') ||
        digits.startsWith('42') ||
        digits.startsWith('43') ||
        digits.startsWith('35')) {
      if (_provider != 'natcash') setState(() => _provider = 'natcash');
    } else if (digits.startsWith('44') ||
        digits.startsWith('46') ||
        digits.startsWith('47') ||
        digits.startsWith('48') ||
        digits.startsWith('49') ||
        digits.startsWith('34') ||
        digits.startsWith('36') ||
        digits.startsWith('37') ||
        digits.startsWith('38')) {
      if (_provider != 'moncash') setState(() => _provider = 'moncash');
    }
  }

  Future<void> _loadBalance() async {
    try {
      final u = await Api.me();
      if (mounted) {
        setState(() => _balance = (u['balance'] ?? 0).toDouble());
      }
    } catch (_) {}
  }

  Future<void> _withdraw() async {
    final phone = _phone.text.trim().replaceAll(RegExp(r'\D'), '');
    final amount = int.tryParse(_amount.text.trim()) ?? 0;
    if (phone.length < 8) {
      _err('Antre nimewo MonCash oswa NatCash valab (omwen 8 chif)');
      return;
    }
    if (amount < 150) {
      _err('Retrait minimòm se 150 HTG');
      return;
    }
    if (amount > _balance) {
      _err('Balans ensufizan. Ou gen ${_balance.toStringAsFixed(2)} HTG.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final r = await Api.withdrawCreate(amount, phone, provider: _provider);
      if (!mounted) return;
      final newBal = r['balance']?.toString() ?? '';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Retrait reyisi! $amount HTG voye sou $phone via ${_provider.toUpperCase()}. Nouvo balans: $newBal HTG.',
        ),
        backgroundColor: const Color(0xFF059669),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ));
      _phone.clear();
      _amount.clear();
      _loadBalance();
      widget.onBack();
    } catch (e) {
      _err(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _err(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
    ));
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF052E22), Color(0xFF064E3B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.35)),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF064E3B).withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDE68A).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.account_balance_wallet, color: Color(0xFFFDE68A), size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Balans disponib pou retire',
                                    style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_balance.toStringAsFixed(2)} HTG',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: XcColors.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '1. Chwazi bous peman an',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: XcColors.ink),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _providerPill('moncash', 'MonCash', const Color(0xFFDC2626)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _providerPill('natcash', 'NatCash', const Color(0xFF2563EB)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: XcColors.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '2. Nimewo pou resevwa kòb la',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: XcColors.ink),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Nimewo MonCash / NatCash',
                                prefixIcon: const Icon(Icons.phone_iphone, color: Color(0xFF059669)),
                                prefixText: '+509 ',
                                hintText: 'egz. 34123456 oswa 40123456',
                                suffixIcon: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _provider.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _provider == 'natcash' ? const Color(0xFF2563EB) : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: XcColors.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '3. Kantite kòb ou vle retire',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: XcColors.ink),
                                ),
                                TextButton(
                                  onPressed: _balance >= 150
                                      ? () => setState(() => _amount.text = _balance.toInt().toString())
                                      : null,
                                  child: const Text('Tout balans lan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _amount,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                labelText: 'Kantite (HTG)',
                                prefixIcon: Icon(Icons.payments_outlined, color: Color(0xFF059669)),
                                hintText: '150',
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Row(
                              children: [
                                Icon(Icons.info_outline, size: 14, color: Color(0xFF64748B)),
                                SizedBox(width: 6),
                                Text(
                                  'Retrait minimòm se 150 HTG (0% frè).',
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitting ? null : _withdraw,
                        child: _submitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Retire kòb kounye a', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Color(0xFF64748B)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Kòb la ap transfere sou bous ou (MonCash oswa NatCash) otomatikman.',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: widget.onBack,
          ),
          const SizedBox(width: 4),
          const Text(
            'Fè Retrait',
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

  Widget _providerPill(String id, String label, Color color) {
    final selected = _provider == id;
    return InkWell(
      onTap: () => setState(() => _provider = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                color: selected ? const Color(0xFF064E3B) : const Color(0xFF0F172A),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
