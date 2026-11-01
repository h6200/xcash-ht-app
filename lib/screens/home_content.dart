import 'package:flutter/material.dart';
import '../api.dart';
import '../theme.dart';

// Koulè nivo plan (tier) — menm jan ak invest.dart
Color _tierColor(String name, double amount) {
  final n = name.toLowerCase();
  if (n.contains('vip') || n.contains('mast')) return const Color(0xFF7C3AED);
  if (n.contains('diamond') || n.contains('diaman') || amount >= 15000) return const Color(0xFF0369A1);
  if (n.contains('platinum') || n.contains('platin') || amount >= 12500) return const Color(0xFF0F766E);
  if (n.contains('gold') || n.contains('lò') || amount >= 7500) return const Color(0xFFB45309);
  if (n.contains('silver') || n.contains('ajan') || amount >= 5000) return const Color(0xFF475569);
  return const Color(0xFF059669);
}

Color _tierSoft(String name, double amount) {
  final n = name.toLowerCase();
  if (n.contains('vip') || n.contains('mast')) return const Color(0xFFF5F3FF);
  if (n.contains('diamond') || n.contains('diaman') || amount >= 15000) return const Color(0xFFF0F9FF);
  if (n.contains('platinum') || n.contains('platin') || amount >= 12500) return const Color(0xFFF0FDFA);
  if (n.contains('gold') || n.contains('lò') || amount >= 7500) return const Color(0xFFFFFBEB);
  if (n.contains('silver') || n.contains('ajan') || amount >= 5000) return const Color(0xFFF8FAFC);
  return const Color(0xFFECFDF5);
}

class HomeContent extends StatefulWidget {
  final VoidCallback onDeposit;
  final VoidCallback onInvest;
  final VoidCallback onWithdraw;

  const HomeContent({
    super.key,
    required this.onDeposit,
    required this.onInvest,
    required this.onWithdraw,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  Map<String, dynamic>? _user;
  List<dynamic> _plans = [];
  List<dynamic> _investments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final u = await Api.me();
      final p = await Api.plans();
      final inv = await Api.myInvestments();
      if (mounted) {
        setState(() {
          _user = Map<String, dynamic>.from(u);
          _plans = p;
          _investments = inv;
          _loading = false;
        });
      }
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Header rich gradyan ----
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF052E22), Color(0xFF064E3B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22052E22),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'XCASH HT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _load,
                      tooltip: 'Rafrechi',
                    ),
                  ],
                ),
              ),
              // ---- Kò paj (scrollable) ----
              Expanded(
                child: RefreshIndicator(
                  color: XcColors.emerald,
                  onRefresh: _load,
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          children: [
                            _balanceCard(),
                            const SizedBox(height: 16),
                            _quickStats(),
                            const SizedBox(height: 22),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Plan Envestisman',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: XcColors.ink,
                                  ),
                                ),
                                TextButton(
                                  onPressed: widget.onInvest,
                                  child: const Text(
                                    'Wè tout',
                                    style: TextStyle(
                                      color: Color(0xFF059669),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ..._plans.map((p) => _planCard(p)).toList(),
                            const SizedBox(height: 22),
                            const Text(
                              'Envestisman aktif',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: XcColors.ink,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (_investments.where((i) => i['status'] == 'active').isEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: XcColors.line),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.trending_up, size: 40, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Ou poko gen envestisman ki an kou.',
                                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: widget.onInvest,
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(180, 44),
                                        backgroundColor: const Color(0xFF059669),
                                      ),
                                      child: const Text('Kòmanse Envesti', style: TextStyle(fontSize: 14)),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ..._investments
                                  .where((i) => i['status'] == 'active')
                                  .map((i) => _activeInvestmentCard(i))
                                  .toList(),
                            const SizedBox(height: 24),
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

  Widget _balanceCard() {
    final bal = double.tryParse('${_user?['balance'] ?? 0}') ?? 0.0;
    final name = '${_user?['first_name'] ?? ''} ${_user?['last_name'] ?? ''}'.trim();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF052E22), Color(0xFF064E3B), Color(0xFF0B6B4C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name.isNotEmpty ? 'Bonjou, $name' : 'Kont XCASH HT',
                  style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield, color: Color(0xFFFDE68A), size: 14),
                    SizedBox(width: 4),
                    Text('Aktif', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Balans total ou',
            style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                bal.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'HTG',
                style: TextStyle(
                  color: Color(0xFFFDE68A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onDeposit,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Depo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF064E3B),
                    elevation: 0,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onWithdraw,
                  icon: const Icon(Icons.arrow_upward, size: 18),
                  label: const Text('Retrè'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0x33FFFFFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0x66FFFFFF)),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: kGoldGradient,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: widget.onInvest,
                    icon: const Icon(Icons.trending_up, size: 18),
                    label: const Text('Envesti'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: const Color(0xFF78350F),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickStats() {
    final activeCount = _investments.where((i) => i['status'] == 'active').length;
    double investedTotal = 0;
    for (var i in _investments) {
      if (i['status'] == 'active') {
        investedTotal += double.tryParse('${i['amount']}') ?? 0;
      }
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: XcColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Plan aktif', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '$activeCount plan',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: XcColors.ink),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: XcColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kòb k ap travay', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '${investedTotal.toStringAsFixed(0)} HTG',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _planCard(dynamic p) {
    final amount = double.tryParse('${p['amount']}') ?? 0;
    final payout = double.tryParse('${p['payout']}') ?? 0;
    final profit = payout - amount;
    final profitPct = amount > 0 ? ((profit / amount) * 100).toStringAsFixed(0) : '0';
    final tierC = _tierColor(p['name'] ?? '', amount);
    final tierS = _tierSoft(p['name'] ?? '', amount);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: XcColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.onInvest,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tierS,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: tierC.withOpacity(0.4)),
                ),
                child: Icon(Icons.trending_up, color: tierC, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          p['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: XcColors.ink),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: tierC,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+$profitPct%',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Envesti ${amount.toStringAsFixed(0)} HTG → Resevwa ${payout.toStringAsFixed(0)} HTG',
                      style: const TextStyle(color: Color(0xFF334155), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 3),
                    const Row(
                      children: [
                        Icon(Icons.schedule, size: 13, color: Color(0xFF64748B)),
                        SizedBox(width: 4),
                        Text(
                          'Dire: 1h45 minit (peman otomatik)',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activeInvestmentCard(dynamic i) {
    final finishStr = (i['finish_at'] ?? '').toString();
    final amount = (i['amount'] ?? 0).toString();
    final payout = (i['payout'] ?? 0).toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.hourglass_top, color: Color(0xFFD97706), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      i['plan_name'] ?? 'Envestisman',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF78350F)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'An kou (1h45m)',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Envesti: $amount HTG  →  Resevwa: $payout HTG',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fini: $finishStr',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
