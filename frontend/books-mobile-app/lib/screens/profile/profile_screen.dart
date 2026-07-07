import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Profile / Info screen showing client info, copy token, developer info, and logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        key: const Key('profile_screen_title'),
        title: const Text('Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Info Section
            _SectionHeader(title: 'Client Info', icon: Icons.person_outline),
            const SizedBox(height: 12),
            Container(
              key: const Key('profile_client_card'),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Name',
                    value: auth.clientName ?? '—',
                    valueKey: const Key('profile_client_name'),
                  ),
                  _InfoRow(
                    label: 'Email',
                    value: auth.clientEmail ?? '—',
                    valueKey: const Key('profile_client_email'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Token', style: TextStyle(fontSize: 12, color: Colors.white54)),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          auth.token ?? '—',
                          key: const Key('profile_client_token'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Color(0xFF10B981),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('profile_btn_copy_token'),
                      onPressed: auth.token != null
                          ? () {
                              Clipboard.setData(ClipboardData(text: auth.token!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  key: Key('profile_snackbar_copied'),
                                  content: Text('Token copied to clipboard!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Token'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Developer Info Section
            _SectionHeader(title: 'About This App', icon: Icons.info_outline),
            const SizedBox(height: 12),
            Container(
              key: const Key('profile_developer_card'),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x0FFFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x2EFFFFFF)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'App', value: 'Simple Books', valueKey: Key('profile_app_name')),
                  _InfoRow(label: 'Version', value: 'v0.3.0', valueKey: Key('profile_app_version')),
                  _InfoRow(label: 'Developer', value: 'AXONS CoE-QA', valueKey: Key('profile_developer_name')),
                  _InfoRow(label: 'Platform', value: 'Flutter + Python API', valueKey: Key('profile_platform')),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('profile_btn_logout'),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Logout?'),
                      content: const Text('You will need to login again to access orders.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Logout', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await context.read<AuthProvider>().logout();
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444).withOpacity(0.15),
                  foregroundColor: const Color(0xFFEF4444),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Reset Server
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('profile_btn_reset_server'),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Reset Server?'),
                      content: const Text('This will clear all data: stock, orders, and clients.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Reset', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await context.read<AuthProvider>().resetServer();
                  }
                },
                icon: const Icon(Icons.refresh, size: 16, color: Color(0xFFEF4444)),
                label: const Text('Reset Server', style: TextStyle(color: Color(0xFFEF4444))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFA5B4FC)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Key? valueKey;
  const _InfoRow({required this.label, required this.value, this.valueKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
          const Spacer(),
          Text(value, key: valueKey, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
