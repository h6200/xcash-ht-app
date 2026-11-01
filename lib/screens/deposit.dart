import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api.dart';
import '../theme.dart';

class DepositScreen extends StatefulWidget {
  final VoidCallback onBack;
  const DepositScreen({super.key, required this.onBack});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _amount = TextEditingController();
  String _provider = 'moncash';
  bool _submitting = false;

  final List<int> _quickAmounts = [1000, 2000, 3000, 5000, 10000];

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {}
  }

  Future<void> _deposit() async {
    final amount = int.tryParse(_amount.text.trim()) ?? 0;
    if (amount < 10) {
      _err('Antre yon montan valab (omwen 10 HTG)');
      return;
    }
    setState(() => _submitting = true);
    try {
      final r = await Api.depositCreate(amount, _provider);
      final url = r['paymentUrl']?.toString() ?? '';
      if (!mounted) return;
      if (url.isNotEmpty) {
        _openUrl(url);
        _showPaymentDialog(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Depo kreye. Balans ou ap monte otomatikman.'),
          backgroundColor: Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ));
        widget.onBack();
      }
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

  void _showPaymentDialog(String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.payment, color: Color(0xFF059669)),
            SizedBox(width: 10),
            Text('Paj Peman Ouvri'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paj peman an ap ouvri nan navigatè w pou w ka valide tranzaksyon an.',
              style: TextStyle(fontSize: 14, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _openUrl(url),
              icon: const Icon(Icons.open_in_browser, size: 20),
              label: const Text('Ouvri paj peman an kounye a'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Lyen peman an kopye!'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ));
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Kopye lyen peman an'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Depi peman an valide sou MonCash oswa NatCash, balans ou ap kredite otomatikman.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onBack();
            },
            child: const Text('Fini / Tounen sou akèy', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: XcColors.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '1. Antre kantite kòb pou depoze',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: XcColors.ink),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _amount,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                labelText: 'Kantite (HTG)',
                                prefixIcon: Icon(Icons.payments_outlined, color: Color(0xFF059669)),
                                hintText: '1000',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _quickAmounts.map((q) => ActionChip(
                                label: Text('$q HTG', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                backgroundColor: const Color(0xFFECFDF5),
                                side: const BorderSide(color: Color(0xFFA7F3D0)),
                                labelStyle: const TextStyle(color: Color(0xFF065F46)),
                                onPressed: () => setState(() => _amount.text = q.toString()),
                              )).toList(),
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
                              '2. Chwazi bous peman an',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: XcColors.ink),
                            ),
                            const SizedBox(height: 12),
                            _providerOption('moncash', 'MonCash (Digicel)', Icons.phone_android, const Color(0xFFDC2626)),
                            const SizedBox(height: 10),
                            _providerOption('natcash', 'NatCash (Natcom)', Icons.phone_iphone, const Color(0xFF2563EB)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitting ? null : _deposit,
                        child: _submitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Ale sou paj peman an', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                                'Peman atravè MonCash oswa NatCash. Balans ou kredite otomatikman depi peman an konfime.',
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
            'Fè Depo',
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

  Widget _providerOption(String id, String label, IconData icon, Color brandColor) {
    final selected = _provider == id;
    return InkWell(
      onTap: () => setState(() => _provider = id),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: brandColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: brandColor, size: 22),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? const Color(0xFF064E3B) : const Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle, color: Color(0xFF059669))
            else
              const Icon(Icons.radio_button_unchecked, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
