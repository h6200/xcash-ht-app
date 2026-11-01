import 'package:flutter/material.dart';
import '../api.dart';
import '../theme.dart';

// Code koulè pou chak nivo plan (tier) — pi pwofesyonèl ak diferansye
class _TierStyle {
  final Color primary;
  final Color soft;
  final Color border;
  final Color text;
  const _TierStyle(this.primary, this.soft, this.border, this.text);
}

_TierStyle _styleFor(String name, double amount) {
  final n = name.toLowerCase();
  if (n.contains('vip') || n.contains('mast')) {
    return const _TierStyle(
      Color(0xFF6D28D9), Color(0xFFF5F3FF), Color(0xFFC4B5FD), Color(0xFF5B21B6),
    );
  }
  if (n.contains('diamond') || n.contains('diaman') || amount >= 15000) {
    return const _TierStyle(
      Color(0xFF0EA5E9), Color(0xFFF0F9FF), Color(0xFFBAE6FD), Color(0xFF0369A1),
    );
  }
  if (n.contains('platinum') || n.contains('platin') || amount >= 12500) {
    return const _TierStyle(
      Color(0xFF0F766E), Color(0xFFF0FDFA), Color(0xFF99F6E4), Color(0xFF115E59),
    );
  }
  if (n.contains('gold') || n.contains('lò') || amount >= 7500) {
    return const _TierStyle(
      Color(0xFFD97706), Color(0xFFFFFBEB), Color(0xFFFDE68A), Color(0xFF92400E),
    );
  }
  if (n.contains('silver') || n.contains('ajan') || amount >= 5000) {
    return const _TierStyle(
      Color(0xFF64748B), Color(0xFFF8FAFC), Color(0xFFCBD5E1), Color(0xFF475569),
    );
  }
  if (n.contains('gold') == false) {
    // Nivo baz (Starter) — vèt emerald
    return const _TierStyle(
      Color(0xFF059669), Color(0xFFECFDF5), Color(0xFFA7F3D0), Color(0xFF065F46),
    );
  }
  return const _TierStyle(
    Color(0xFF059669), Color(0xFFECFDF5), Color(0xFFA7F3D0), Color(0xFF065F46),
  );
}

class InvestScreen extends StatefulWidget {
  final VoidCallback onBack;
  const InvestScreen({super.key, required this.onBack});

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen> {
  List<dynamic> _plans = [];
  dynamic _selected;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await Api.plans();
      if (mounted) {
        setState(() {
          _plans = p;
          if (p.isNotEmpty) _selected = p.first;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _invest() async {
    if (_selected == null) return;
    setState(() => _submitting = true);
    try {
      final r = await Api.invest(_selected['id'].toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Envestisman reyisi! Ou pral resevwa ${r['investment']?['payout'] ?? _selected['payout']} HTG apre 1h45 minit.',
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ));
      widget.onBack();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selAmount = double.tryParse('${_selected?['amount'] ?? ''}') ?? 0;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kPageGradient),
        child: SafeArea(
          child: Column(
            children: [
              _appBar(),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF052E22), Color(0xFF064E3B), Color(0xFF0B6B4C)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.35)),
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFF064E3B).withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.timer, color: Color(0xFFFDE68A), size: 30),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dire tout plan: 1h45 minit',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Kòb ou dedui kounye a, peman total (kapital + benefis) tounen otomatikman apre 1h45.',
                                          style: TextStyle(fontSize: 12, color: Color(0xFFD1FAE5)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Chwazi yon plan envestisman',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: XcColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Konpare retounen yo epi chwazi nivo ki mache ak ou.',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            ..._plans.map((p) => _planOption(p)).toList(),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _selected == null
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF059669).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitting ? null : _invest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: const Color(0xFF9CA3AF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.rocket_launch, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Envesti ${selAmount.toStringAsFixed(0)} HTG kounye a',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
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
            'Envesti kòb ou',
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

  Widget _planOption(dynamic p) {
    final selected = _selected?['id'] == p['id'];
    final amount = double.tryParse('${p['amount']}') ?? 0;
    final payout = double.tryParse('${p['payout']}') ?? 0;
    final profit = payout - amount;
    final profitPct = amount > 0 ? ((profit / amount) * 100).toStringAsFixed(1) : '0';
    final tier = _styleFor(p['name'] ?? '', amount);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: selected
            ? LinearGradient(
                colors: [tier.soft, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: selected ? null : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? tier.primary : const Color(0xFFE2E8F0),
          width: selected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: selected ? tier.primary.withOpacity(0.18) : const Color(0x08000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => setState(() => _selected = p),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Badge sikilè ak ikòn
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: tier.soft,
                  shape: BoxShape.circle,
                  border: Border.all(color: tier.border, width: 2),
                ),
                child: Icon(
                  selected ? Icons.check_circle : Icons.trending_up,
                  color: tier.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p['name'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: tier.text,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: tier.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+$profitPct%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          amount.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: tier.primary,
                          ),
                        ),
                        const Text(
                          ' HTG  →  ',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        ),
                        Text(
                          payout.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF059669),
                          ),
                        ),
                        const Text(
                          ' HTG',
                          style: TextStyle(color: Color(0xFF059669), fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 13, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          '1h45 minit  •  Benefis ${profit.toStringAsFixed(0)} HTG',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
