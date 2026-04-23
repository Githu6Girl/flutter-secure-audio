import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_components.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _selectedDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? DateTime(now.year - 13, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty || _surnameController.text.isEmpty ||
        _emailController.text.isEmpty || _passwordController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les mots de passe ne correspondent pas')));
      return;
    }

    final now = DateTime.now();
    int age = now.year - _selectedDate!.year;
    if (now.month < _selectedDate!.month || (now.month == _selectedDate!.month && now.day < _selectedDate!.day)) age--;

    if (age < 13) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vous devez avoir au moins 13 ans')));
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vous devez accepter les conditions')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _nameController.text.trim(),
        lastName: _surnameController.text.trim(),
        dateOfBirth: _selectedDate!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inscription réussie!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                const Text('Créer un compte', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Rejoignez l\'expérience Mawja', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
                const SizedBox(height: 32),

                GlassTextField(controller: _nameController, label: 'Prénom', prefixIcon: Icons.person_outline),
                const SizedBox(height: 16),

                GlassTextField(controller: _surnameController, label: 'Nom', prefixIcon: Icons.person_outline),
                const SizedBox(height: 16),

                GlassTextField(controller: _emailController, label: 'Email', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Row(
                      children:[
                        const Icon(Icons.calendar_today_outlined, color: Color(0xFF6366F1)),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate != null ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' : 'Date de naissance',
                          style: TextStyle(color: _selectedDate != null ? Colors.white : Colors.white.withOpacity(0.6), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                GlassTextField(
                  controller: _passwordController, label: 'Mot de passe', prefixIcon: Icons.lock_outlined, obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white54),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),

                GlassTextField(
                  controller: _confirmPasswordController, label: 'Confirmer mot de passe', prefixIcon: Icons.lock_outlined, obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white54),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children:[
                    Theme(
                      data: ThemeData(unselectedWidgetColor: Colors.white54),
                      child: Checkbox(
                        value: _agreeToTerms,
                        activeColor: const Color(0xFF6366F1),
                        checkColor: Colors.white,
                        onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'J\'accepte les conditions d\'utilisation',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                GradientButton(
                  text: 'S\'inscrire',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _register,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}