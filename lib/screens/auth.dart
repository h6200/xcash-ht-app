import 'package:flutter/material.dart';
import '../api.dart';
import '../theme.dart';
import 'home.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  final _phone = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();

  String _normalizePhone(String s) {
    var p = s.replaceAll(RegExp(r'\D'), '');
    if (p.startsWith('509') && p.length == 11) return p;
    if (p.startsWith('0')) p = '509' + p.substring(1);
    return p;
  }

  Future<void> _submit() async {
    final phone = _normalizePhone(_phone.text.trim());
    if (phone.length < 8) {
      _showError('Antre yon nimewo telefòn valab (omwen 8 chif)');
      return;
    }
    setState(() => _loading = true);
    try {
      if (_isLogin) {
        final r = await Api.login(phone);
        await Api.saveToken(r['token'].toString());
      } else {
        if (_first.text.trim().isEmpty || _last.text.trim().isEmpty) {
          _showError('Tanpri antre prenon ak non ou');
          setState(() => _loading = false);
          return;
        }
        final r = await Api.register(
            phone, _first.text.trim(), _last.text.trim());
        await Api.saveToken(r['token'].toString());
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: kPageGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // ---- Bannè tèt rich (gradyan vèt → lò) ----
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: const [Color(0xFF052E22), Color(0xFF064E3B), Color(0xFF0B6B4C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF064E3B).withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Logo anndan yon "bèl kase" lò
                      Container(
                        width: 88,
                        height: 88,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          gradient: kGoldGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withOpacity(0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.png',
                            width: 82,
                            height: 82,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'XCASH HT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isLogin ? 'Konekte sou kont ou' : 'Kreye nouvo kont ou',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFD1FAE5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Divider ak "aksel lò"
                      Container(
                        width: 48,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: kGoldGradient,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ---- Kad fòm ----
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: XcColors.line),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Nimewo telefòn',
                          prefixIcon: Icon(Icons.phone_iphone, color: Color(0xFF059669)),
                          prefixText: '+509 ',
                          hintText: '33 45 67 89',
                        ),
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _first,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Prenon',
                            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF059669)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _last,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Non',
                            prefixIcon: Icon(Icons.badge_outlined, color: Color(0xFF059669)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Bouton ak gradyan vèt → emerald
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: _loading ? null : const LinearGradient(
                            colors: [Color(0xFF064E3B), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF059669).withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: const Color(0xFF9CA3AF),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(_isLogin ? 'Konekte' : 'Enskri kounye a'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ---- Lyen baskil login/enskri ak aksan lò ----
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin
                          ? 'Ou poko gen kont? Enskri la a'
                          : 'Ou gen kont deja? Konekte',
                      style: const TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
