import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import 'login_screen.dart';

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
      final isBiometricAvailable =
          await _biometricService.isBiometricAvailable();

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
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthService>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final firstName = _userData['firstName'] ?? 'Utilisateur';
    final lastName = _userData['lastName'] ?? '';
    final email = _userData['email'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${firstName[0]}${lastName[0]}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$firstName $lastName',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Account settings section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compte',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.lock_outlined),
                        title: const Text('Changer le mot de passe'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _changePassword,
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Adresse email'),
                        subtitle: const Text('Non modifiable'),
                        trailing: const Icon(Icons.lock),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Security settings section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sécurité',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    if (_isBiometricEnabled)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.fingerprint),
                          title: const Text('Authentification biométrique'),
                          subtitle:
                              const Text('Utilisée pour les actions sensibles'),
                          trailing: const Icon(Icons.check_circle,
                              color: Color(0xFF34D399)),
                        ),
                      )
                    else
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.fingerprint_outlined),
                          title: const Text('Authentification biométrique'),
                          subtitle: const Text('Non disponible sur cet appareil'),
                          trailing: const Icon(Icons.close_outlined,
                              color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // App settings section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Application',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.info_outlined),
                        title: const Text('À propos'),
                        subtitle: const Text('Version 1.0.0'),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('Politique de confidentialité'),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: const Text('Conditions d\'utilisation'),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Logout button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Déconnexion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({Key? key}) : super(key: key);

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Changer le mot de passe'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: !_showCurrentPassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe actuel',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showCurrentPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(
                        () => _showCurrentPassword = !_showCurrentPassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordController,
              obscureText: !_showNewPassword,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showNewPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() => _showNewPassword = !_showNewPassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirmer le nouveau mot de passe',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(
                        () => _showConfirmPassword = !_showConfirmPassword);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            // Implement password change logic
            Navigator.pop(context);
          },
          child: const Text('Changer'),
        ),
      ],
    );
  }
}
