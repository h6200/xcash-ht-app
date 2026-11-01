import 'package:flutter/material.dart';
import '../api.dart';
import '../theme.dart';
import 'auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final u = await Api.me();
      if (mounted) {
        setState(() {
          _user = Map<String, dynamic>.from(u);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isAdmin {
    if (_user == null) return false;
    if (_user!['is_admin'] == true) return true;
    final phone = (_user!['phone'] ?? '').toString().replaceAll(RegExp(r'\D'), '');
    return phone.endsWith('55394345') || phone.endsWith('50955394345');
  }

  Future<void> _logout() async {
    await Api.clearToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = _user?['phone']?.toString() ?? '';
    final name = '${_user?['first_name'] ?? ''} ${_user?['last_name'] ?? ''}'.trim();
    final balance = double.tryParse('${_user?['balance'] ?? 0}') ?? 0.0;

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
                    : RefreshIndicator(
                        color: const Color(0xFF059669),
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _headerCard(name, phone),
                            const SizedBox(height: 16),
                            _infoCard('Balans ou', '${balance.toStringAsFixed(2)} HTG', Icons.account_balance_wallet, const Color(0xFF059669)),
                            _infoCard('Estati kont', 'Aktif & Verifye', Icons.verified_user, const Color(0xFF2563EB)),
                            _infoCard('Vèsyon App', 'v1.0.7', Icons.info_outline, const Color(0xFF64748B)),
                            if (_isAdmin) ..._adminSection(),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              onPressed: _logout,
                              icon: const Icon(Icons.logout, color: Colors.red),
                              label: const Text('Dekonekte', style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.red.shade200),
                                minimumSize: const Size.fromHeight(48),
                              ),
                            ),
                            const SizedBox(height: 20),
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

  Widget _headerCard(String name, String phone) {
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
          BoxShadow(color: const Color(0xFF064E3B).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: kGoldGradient,
              shape: BoxShape.circle,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF064E3B),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name.isNotEmpty ? name : 'Itilizatè XCASH',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            phone.startsWith('509') ? '+$phone' : phone,
            style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 14),
          ),
          if (_isAdmin) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Text(
                'ADMINISTRATÈ',
                style: TextStyle(
                  color: Color(0xFF92400E),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _adminSection() {
    return [
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Icon(Icons.admin_panel_settings, color: Color(0xFF065F46), size: 24),
                SizedBox(width: 10),
                Text(
                  'Panèl Administrasyon',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF065F46),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Aksè pwoteje pou jesyon itilizatè, balans, depo ak retrè.',
              style: TextStyle(fontSize: 12, color: Color(0xFF047857)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminPanel()),
                );
              },
              icon: const Icon(Icons.dashboard_customize, size: 18),
              label: const Text('Ouvri Panèl Admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF065F46),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ],
        ),
      ),
    ];
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
          Icon(Icons.person, color: Colors.white),
          SizedBox(width: 10),
          Text(
            'Pwofil Mwen',
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

  Widget _infoCard(String label, String value, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  final _pin = TextEditingController();
  bool _unlocked = false;
  bool _loading = false;
  Map<String, dynamic>? _dashboard;
  List<dynamic> _users = [];
  List<dynamic> _withdrawals = [];
  List<dynamic> _deposits = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final pin = _pin.text.trim();
    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Antre PIN sekrè admin ou a (4 chif)'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final d = await Api.adminDashboard(pin);
      final u = await Api.adminUsers(pin);
      final w = await Api.adminWithdrawals(pin);
      final dep = await Api.adminDeposits(pin);
      if (mounted) {
        setState(() {
          _unlocked = true;
          _dashboard = d;
          _users = u;
          _withdrawals = w;
          _deposits = dep;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('PIN enkòrèk oswa erè: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _refreshAll() async {
    final pin = _pin.text.trim();
    try {
      final d = await Api.adminDashboard(pin);
      final u = await Api.adminUsers(pin);
      final w = await Api.adminWithdrawals(pin);
      final dep = await Api.adminDeposits(pin);
      if (mounted) {
        setState(() {
          _dashboard = d;
          _users = u;
          _withdrawals = w;
          _deposits = dep;
        });
      }
    } catch (_) {}
  }

  void _showAdjustBalanceDialog(dynamic u) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String action = 'add'; // add | deduct | set

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Jere Balans: ${u['first_name']} ${u['last_name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Nimewo: ${u['phone']}'),
                Text(
                  'Balans aktyèl: ${u['balance']} HTG',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                ),
                const SizedBox(height: 16),
                const Text('Aksyon:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('+ Ajoute'),
                      selected: action == 'add',
                      onSelected: (v) => setDlgState(() => action = 'add'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('- Retire'),
                      selected: action == 'deduct',
                      onSelected: (v) => setDlgState(() => action = 'deduct'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('= Fikse'),
                      selected: action == 'set',
                      onSelected: (v) => setDlgState(() => action = 'set'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Montan (HTG)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nòt (opsyonèl)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Anile'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text.trim()) ?? 0;
                if (amt <= 0 && action != 'set') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Antre yon montan pozitif')),
                  );
                  return;
                }
                Navigator.of(ctx).pop();
                try {
                  await Api.adminAdjustBalance(
                    _pin.text.trim(),
                    u['id'].toString(),
                    amt,
                    action,
                    noteCtrl.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Balans modifye avèk siksè!'),
                      backgroundColor: Color(0xFF059669),
                    ),
                  );
                  _refreshAll();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erè: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Konfime'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Panèl Administratè'),
        bottom: _unlocked
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: const Color(0xFFF59E0B),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard, size: 20), text: 'Akèy'),
                  Tab(icon: Icon(Icons.people, size: 20), text: 'Itilizatè'),
                  Tab(icon: Icon(Icons.arrow_upward, size: 20), text: 'Retrè'),
                  Tab(icon: Icon(Icons.arrow_downward, size: 20), text: 'Depo'),
                ],
              )
            : null,
      ),
      body: !_unlocked ? _buildPinGate() : _buildTabs(),
    );
  }

  Widget _buildPinGate() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock, color: Color(0xFF065F46), size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Otantifikasyon Admin',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Antre kòd PIN sekrè 4 chif pou jwenn aksè nan panèl la.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pin,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: '••••',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _unlock,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Debloke Panèl'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDashboardTab(),
        _buildUsersTab(),
        _buildWithdrawalsTab(),
        _buildDepositsTab(),
      ],
    );
  }

  Widget _buildDashboardTab() {
    final d = _dashboard ?? {};
    final usersCount = d['users_count'] ?? _users.length;
    final totalBal = d['total_user_balance'] ?? 0;
    final totalDep = d['total_deposited'] ?? 0;
    final totalWd = d['total_withdrawn'] ?? 0;
    final activeInv = d['active_investments_count'] ?? 0;

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _metricCard('Itilizatè', '$usersCount', Icons.people, const Color(0xFF2563EB))),
              const SizedBox(width: 12),
              Expanded(child: _metricCard('Plan aktif', '$activeInv', Icons.trending_up, const Color(0xFF059669))),
            ],
          ),
          const SizedBox(height: 12),
          _metricCard('Balans total kliyan', '$totalBal HTG', Icons.account_balance_wallet, const Color(0xFFD97706)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metricCard('Total Depo', '$totalDep HTG', Icons.arrow_downward, const Color(0xFF059669))),
              const SizedBox(width: 12),
              Expanded(child: _metricCard('Total Retrè', '$totalWd HTG', Icons.arrow_upward, const Color(0xFFDC2626))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (ctx, i) {
          final u = _users[i];
          final phone = u['phone'] ?? '';
          final name = '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim();
          final bal = u['balance'] ?? 0;
          final isAdmin = u['is_admin'] == true;

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
                CircleAvatar(
                  backgroundColor: isAdmin ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                  child: Icon(
                    isAdmin ? Icons.shield : Icons.person,
                    color: isAdmin ? const Color(0xFFD97706) : const Color(0xFF059669),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name.isNotEmpty ? name : 'San non',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          if (isAdmin) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('ADMIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(phone, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('Balans: $bal HTG', style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF059669)),
                  tooltip: 'Jere balans',
                  onPressed: () => _showAdjustBalanceDialog(u),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWithdrawalsTab() {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: _withdrawals.isEmpty
          ? const Center(child: Text('Pa gen okenn retrè anrejistre.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _withdrawals.length,
              itemBuilder: (ctx, i) {
                final w = _withdrawals[i];
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
                      const Icon(Icons.arrow_upward, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${w['amount']} HTG sou ${w['phone'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Status: ${w['status']} • Ref: ${w['reference'] ?? '-'}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDepositsTab() {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: _deposits.isEmpty
          ? const Center(child: Text('Pa gen okenn depo anrejistre.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _deposits.length,
              itemBuilder: (ctx, i) {
                final d = _deposits[i];
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
                      const Icon(Icons.arrow_downward, color: Color(0xFF059669)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${d['amount']} HTG (${d['provider'] ?? ''})', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Status: ${d['status']} • Ref: ${d['reference'] ?? '-'}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
