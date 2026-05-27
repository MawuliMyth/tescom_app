part of '../dashboard_screen.dart';

// Contact form route used for support and update requests.
// This file is intentionally separated so each screen has a clear home.

class _ContactFormPage extends StatefulWidget {
  const _ContactFormPage({required this.title});

  final String title;

  @override
  State<_ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<_ContactFormPage> {
  bool sent = false;

  @override
  Widget build(BuildContext context) {
    return _DemoPageShell(
      title: widget.title,
      subtitle: sent
          ? 'Your message has been submitted.'
          : 'Send a message to the relevant support desk.',
      children: [
        if (!sent) ...[
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Type your message',
              filled: true,
              fillColor: const Color(0xFFF6F6F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => setState(() => sent = true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF34368C),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Send Message'),
          ),
        ] else
          const _InfoCard(
            item: _InfoItem(
              title: 'Message Sent',
              subtitle: 'Support desk notified',
              body:
                  'The support desk has received your message.',
              icon: Icons.mark_email_read_outlined,
            ),
          ),
      ],
    );
  }
}

