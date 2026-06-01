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
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  bool submitting = false;
  bool sent = false;
  String? error;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final message = messageController.text.trim();

    if (name.length < 2 || !email.contains('@') || message.length < 5) {
      setState(() => error = 'Enter your name, a valid email, and a message.');
      return;
    }

    setState(() {
      submitting = true;
      error = null;
    });

    try {
      await AppRepository().sendContactMessage(
        name: name,
        email: email,
        topic: widget.title,
        message: message,
      );
      if (!mounted) return;
      setState(() => sent = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => error = 'We could not send your message. Try again.');
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

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
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: _contactInputDecoration('Your name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _contactInputDecoration('Email address'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: messageController,
            maxLines: 4,
            decoration: _contactInputDecoration('Type your message'),
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(
              error!,
              style: const TextStyle(
                color: Color(0xFFB42318),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 14),
          FilledButton(
            onPressed: submitting ? null : submit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF34368C),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(submitting ? 'Sending...' : 'Send Message'),
          ),
        ] else
          const _InfoCard(
            item: _InfoItem(
              title: 'Message Sent',
              subtitle: 'Support desk notified',
              body: 'The support desk has received your message.',
              icon: Icons.mark_email_read_outlined,
            ),
          ),
      ],
    );
  }

  InputDecoration _contactInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF6F6F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}
