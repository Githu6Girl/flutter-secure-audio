import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_components.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BiometricService _biometricService = BiometricService();
  Map<String, dynamic> _userData = {};
  bool _isBiometricEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = context.read<AuthService>();
      final userData = await authService.getUserData();
      final isBiometricAvailable = await _biometricService.isBiometricAvailable();

      setState(() {
        _userData = userData;
        _isBiometricEnabled = isBiometricAvailable;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              const Icon(Icons.logout, color: Color(0xFFF87171), size: 40),
              const SizedBox(height: 16),
              const Text('Déconnexion', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Voulez-vous vraiment vous déconnecter ?', style: TextStyle(color: Colors.white.withOpacity(0.7)), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Annuler', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF87171), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      context.read<AuthService>().logout();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text('Déconnecter', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    showDialog(context: context, builder: (context) => const ChangePasswordDialog());
  }

  Widget _buildGlassListTile({required IconData icon, required String title, String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8B5CF6)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)) : null,
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));

    final firstName = _userData['firstName'] ?? 'User';
    final lastName = _userData['lastName'] ?? '';
    final email = _userData['email'] ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Paramètres', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Profil
            GlassCard(
              child: Row(
                children:[
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors:[Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text('${firstName[0]}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Text('$firstName $lastName', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(email, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('COMPTE', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children:[
                  _buildGlassListTile(icon: Icons.lock_outline, title: 'Changer le mot de passe', onTap: _changePassword),
                  Divider(color: Colors.white.withOpacity(0.1), height: 1),
                  _buildGlassListTile(icon: Icons.email_outlined, title: 'Adresse email', subtitle: 'Non modifiable', trailing: const Icon(Icons.lock, color: Colors.white30, size: 18)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('SÉCURITÉ', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            GlassCard(
              padding: EdgeInsets.zero,
              child: _isBiometricEnabled
                  ? _buildGlassListTile(icon: Icons.fingerprint, title: 'Authentification biométrique', subtitle: 'Activée pour les favoris', trailing: const Icon(Icons.check_circle, color: Color(0xFF34D399)))
                  : _buildGlassListTile(icon: Icons.fingerprint_outlined, title: 'Biométrie non configurée', subtitle: 'Ajoutez une empreinte dans vos paramètres', trailing: const Icon(Icons.error_outline, color: Color(0xFFF87171))),
            ),
            const SizedBox(height: 24),

            // Bouton de déconnexion
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Color(0xFFF87171)),
                label: const Text('Déconnexion', style: TextStyle(color: Color(0xFFF87171), fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF87171).withOpacity(0.1),
                  side: BorderSide(color: const Color(0xFFF87171).withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ---- POPUP POUR CHANGER LE MOT DE PASSE EN MODE GLASS ----
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({Key? key}) : super(key: key);
  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  bool _showPsw1 = false;
  bool _showPsw2 = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            const Text('Modifier le mot de passe', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GlassTextField(
              controller: _currentController, label: 'Mot de passe actuel', prefixIcon: Icons.lock_outline, obscureText: !_showPsw1,
              suffixIcon: IconButton(icon: Icon(!_showPsw1 ? Icons.visibility_off : Icons.visibility, color: Colors.white54), onPressed: () => setState(() => _showPsw1 = !_showPsw1)),
            ),
            const SizedBox(height: 12),
            GlassTextField(
              controller: _newController, label: 'Nouveau mot de passe', prefixIcon: Icons.lock_reset, obscureText: !_showPsw2,
              suffixIcon: IconButton(icon: Icon(!_showPsw2 ? Icons.visibility_off : Icons.visibility, color: Colors.white54), onPressed: () => setState(() => _showPsw2 = !_showPsw2)),
            ),
            const SizedBox(height: 24),
            Row(
              children:[
                Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler', style: TextStyle(color: Colors.white.withOpacity(0.6))))),
                Expanded(child: GradientButton(text: 'Valider', onPressed: () => Navigator.pop(context))), // À relier à Firebase plus tard
              ],
            )
          ],
        ),
      ),
    );
  }
}