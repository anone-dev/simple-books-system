import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Auth screen with Register, Login, and Token modes.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Register fields
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();

  // Login fields
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Token field
  final _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              const Icon(Icons.menu_book, size: 64, color: Color(0xFF818CF8)),
              const SizedBox(height: 12),
              Text('Simple Books', key: const Key('auth_app_title'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  foreground: Paint()..shader = const LinearGradient(
                    colors: [Color(0xFFA5B4FC), Color(0xFF6366F1)],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                )),
              const SizedBox(height: 4),
              Text('CoE-QA Training App', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54)),
              const SizedBox(height: 32),

              // Error message
              if (auth.error != null)
                Container(
                  key: const Key('auth_error_message'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0x26EF4444),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0x4DEF4444)),
                  ),
                  child: Text(auth.error!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
                ),

              // Tab bar
              TabBar(
                key: const Key('auth_mode_tabs'),
                controller: _tabController,
                tabs: const [
                  Tab(key: Key('auth_tab_register'), text: 'Register'),
                  Tab(key: Key('auth_tab_login'), text: 'Login'),
                  Tab(key: Key('auth_tab_token'), text: 'Token'),
                ],
              ),
              const SizedBox(height: 20),

              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRegisterTab(auth),
                    _buildLoginTab(auth),
                    _buildTokenTab(auth),
                  ],
                ),
              ),

              // Reset Server button
              const Divider(),
              TextButton.icon(
                key: const Key('auth_btn_reset_server'),
                onPressed: _resetServer,
                icon: const Icon(Icons.refresh, size: 16, color: Colors.red),
                label: const Text('Reset Server', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
              Text('v3.4.0 • AXONS CoE-QA', style: TextStyle(fontSize: 11, color: Colors.white24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterTab(AuthProvider auth) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            key: const Key('auth_input_name'),
            controller: _regNameController,
            decoration: const InputDecoration(labelText: 'Client Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('auth_input_email'),
            controller: _regEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('auth_input_password'),
            controller: _regPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('auth_btn_register'),
              onPressed: auth.isLoading ? null : _register,
              child: auth.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Register'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginTab(AuthProvider auth) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            key: const Key('auth_login_email'),
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('auth_login_password'),
            controller: _loginPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('auth_btn_login'),
              onPressed: auth.isLoading ? null : _login,
              child: auth.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenTab(AuthProvider auth) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            key: const Key('auth_input_token'),
            controller: _tokenController,
            decoration: const InputDecoration(labelText: 'Access Token', border: OutlineInputBorder(), hintText: 'Paste your token here'),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('auth_btn_token_login'),
              onPressed: _loginWithToken,
              child: const Text('Login with Token'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
    final auth = context.read<AuthProvider>();
    await auth.register(
      _regNameController.text.trim(),
      _regEmailController.text.trim(),
      _regPasswordController.text,
    );
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    await auth.login(
      _loginEmailController.text.trim(),
      _loginPasswordController.text,
    );
  }

  void _loginWithToken() {
    final token = _tokenController.text.trim();
    if (token.isNotEmpty) {
      context.read<AuthProvider>().loginWithToken(token);
    }
  }

  Future<void> _resetServer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Server?'),
        content: const Text('This will clear all data: stock, orders, and clients.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().resetServer();
    }
  }
}
