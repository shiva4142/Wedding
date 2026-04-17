import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/gold_divider.dart';
import '../../../widgets/primary_button.dart' as ui;

class RsvpSection extends ConsumerStatefulWidget {
  const RsvpSection({super.key, this.guestName, this.guestSlug});
  final String? guestName;
  final String? guestSlug;

  @override
  ConsumerState<RsvpSection> createState() => _RsvpSectionState();
}

class _RsvpSectionState extends ConsumerState<RsvpSection> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.guestName ?? '');
  final _phone = TextEditingController();
  final _message = TextEditingController();
  bool _attending = true;
  int _guests = 1;
  bool _submitting = false;
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(apiServiceProvider).submitRsvp(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            attending: _attending,
            guests: _attending ? _guests : 0,
            message: _message.text.trim(),
            guestSlug: widget.guestSlug ?? '',
          );
      setState(() => _done = true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeControllerProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            children: [
              Text(tr(lang, 'will_you_join'), style: AppTheme.script(size: 32)),
              const SizedBox(height: 4),
              Text(tr(lang, 'rsvp'),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 38)),
              const GoldDivider(),
              if (widget.guestName != null && widget.guestName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: [
                        const TextSpan(text: 'Dear '),
                        TextSpan(
                          text: widget.guestName,
                          style: const TextStyle(
                            color: AppPalette.roseDeep,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: ', please let us know if you can make it.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(26),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _done
                      ? _success(context, lang)
                      : _form(context, lang),
                ),
              ).animate().fadeIn().slideY(begin: .12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _form(BuildContext context, AppLang lang) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label(tr(lang, 'name')),
          TextFormField(
            controller: _name,
            decoration: _inputDeco('Full name'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          _label(tr(lang, 'phone')),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: _inputDeco('+91 90000 00000'),
            validator: (v) => (v == null || v.trim().length < 6) ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          _label(tr(lang, 'attending')),
          Row(
            children: [
              Expanded(
                child: _choice(
                  selected: _attending,
                  label: '🌹 ${tr(lang, 'yes')}',
                  onTap: () => setState(() => _attending = true),
                  primary: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _choice(
                  selected: !_attending,
                  label: '💔 ${tr(lang, 'no')}',
                  onTap: () => setState(() => _attending = false),
                  primary: false,
                ),
              ),
            ],
          ),
          if (_attending) ...[
            const SizedBox(height: 14),
            _label(tr(lang, 'guests')),
            Row(
              children: [
                _stepBtn(Icons.remove,
                    () => setState(() => _guests = (_guests - 1).clamp(1, 20))),
                const SizedBox(width: 14),
                Text('$_guests',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppPalette.roseDeep, fontSize: 32)),
                const SizedBox(width: 14),
                _stepBtn(Icons.add,
                    () => setState(() => _guests = (_guests + 1).clamp(1, 20))),
              ],
            ),
          ],
          const SizedBox(height: 14),
          _label(tr(lang, 'message')),
          TextFormField(
            controller: _message,
            maxLines: 3,
            decoration: _inputDeco('A sweet note for the couple...'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: const TextStyle(color: AppPalette.roseDeep, fontSize: 13)),
          ],
          const SizedBox(height: 18),
          ui.PrimaryButton(
            label: _submitting ? 'Sending...' : tr(lang, 'submit'),
            icon: Icons.send,
            onPressed: _submitting ? null : _submit,
            expanded: true,
          ),
        ],
      ),
    );
  }

  Widget _success(BuildContext context, AppLang lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppPalette.roseDeep,
              boxShadow: [
                BoxShadow(color: AppPalette.rose, blurRadius: 24, spreadRadius: 4),
              ],
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 46),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .then()
              .shake(hz: 2, duration: 600.ms),
          const SizedBox(height: 18),
          Text(tr(lang, 'success'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 24),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text("We can't wait to celebrate with you.",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(.7),
              )),
          const SizedBox(height: 18),
          ui.GhostButton(
            label: 'Update RSVP',
            icon: Icons.edit_outlined,
            onPressed: () => setState(() => _done = false),
          ),
        ],
      ),
    );
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 4),
        child: Text(s,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppPalette.muted,
            )),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppPalette.gold.withOpacity(.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppPalette.gold.withOpacity(.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.gold, width: 2),
        ),
      );

  Widget _choice({
    required bool selected,
    required String label,
    required VoidCallback onTap,
    required bool primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? (primary ? AppPalette.roseDeep : AppPalette.ink)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? (primary ? AppPalette.roseDeep : AppPalette.ink)
                : AppPalette.gold.withOpacity(.4),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: AppPalette.rose.withOpacity(.3), blurRadius: 16)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : null,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) => InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(.5),
            border: Border.all(color: AppPalette.gold.withOpacity(.4)),
          ),
          child: Icon(icon, size: 18),
        ),
      );
}
