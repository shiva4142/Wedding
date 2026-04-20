import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/wedding_config.dart';
import '../../core/theme/app_theme.dart';
import '../../models/guest.dart';
import '../../models/rsvp.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart' as ui;

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

enum _Tab { rsvps, guests }

enum _Filter { all, yes, no }

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  _Tab _tab = _Tab.rsvps;
  _Filter _filter = _Filter.all;
  String _search = '';

  bool _loading = true;
  List<Rsvp> _rsvps = [];
  List<Guest> _guests = [];
  List<Guest> _notResponded = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final r = await api.adminRsvps();
      final g = await api.adminListGuests();
      setState(() {
        _rsvps = ((r['rsvps'] as List?) ?? [])
            .map((e) => Rsvp.fromJson(e as Map<String, dynamic>))
            .toList();
        _notResponded = ((r['notResponded'] as List?) ?? [])
            .map((e) => Guest.fromJson(e as Map<String, dynamic>))
            .toList();
        _guests = g;
      });
    } on ApiException catch (e) {
      if (e.message == 'unauthorized') {
        await ref.read(adminTokenProvider.notifier).logout();
        if (mounted) context.go('/admin/login');
      } else {
        _showSnack('Error: ${e.message}');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  int get _attendingGuests =>
      _rsvps.where((r) => r.attending).fold(0, (a, r) => a + (r.guests > 0 ? r.guests : 1));

  int get _declinedCount => _rsvps.where((r) => !r.attending).length;

  List<Rsvp> get _filteredRsvps {
    var l = _rsvps;
    if (_filter == _Filter.yes) l = l.where((r) => r.attending).toList();
    if (_filter == _Filter.no) l = l.where((r) => !r.attending).toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      l = l.where((r) => (r.name + r.phone).toLowerCase().contains(q)).toList();
    }
    return l;
  }

  Future<void> _logout() async {
    await ref.read(adminTokenProvider.notifier).logout();
    if (mounted) context.go('/admin/login');
  }

  Future<void> _addGuest() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final notes = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Guest'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 10),
              TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
              const SizedBox(height: 10),
              TextField(controller: notes, decoration: const InputDecoration(labelText: 'Notes')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok == true && name.text.trim().isNotEmpty) {
      try {
        await ref.read(apiServiceProvider).adminAddGuest(
              name: name.text.trim(),
              phone: phone.text.trim(),
              notes: notes.text.trim(),
            );
        _showSnack('Guest added');
        _load();
      } on ApiException catch (e) {
        _showSnack('Failed: ${e.message}');
      }
    }
  }

  Future<void> _deleteGuest(Guest g) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove guest?'),
        content: Text('Remove ${g.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(apiServiceProvider).adminDeleteGuest(g.id);
      _load();
    }
  }

  String _inviteUrl(Guest g) =>
      '${WeddingConfig.siteUrl}/invite?guest=${Uri.encodeQueryComponent(g.slug)}';

  void _copyInvite(Guest g) {
    Clipboard.setData(ClipboardData(text: _inviteUrl(g)));
    _showSnack('Copied invite for ${g.name}');
  }

  Future<void> _remind(Guest g) async {
    if (g.phone.isEmpty) {
      _showSnack('No phone on file for ${g.name}');
      return;
    }
    try {
      final waLink = await ref.read(apiServiceProvider).adminRemind(
            phone: g.phone,
            name: g.name,
            slug: g.slug,
            siteUrl: WeddingConfig.siteUrl,
          );
      await launchUrl(Uri.parse(waLink), webOnlyWindowName: '_blank');
      _showSnack('Reminder prepared for ${g.name}');
    } on ApiException catch (e) {
      _showSnack('Failed: ${e.message}');
    }
  }

  void _exportCsv() {
    final url = ref.read(apiServiceProvider).exportCsvUrl();
    final token = ref.read(adminTokenProvider);
    // Open in new tab; Authorization header can't be sent via window.open,
    // so we append the token as a query param backend can also read if needed.
    // For demo we just hit the URL — works in dev with `flutter run -d chrome`.
    launchUrl(Uri.parse('$url?token=$token'), webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFE5EC), Color(0xFFFDF9F3), Color(0xFFFDF6E3)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(),
                  const SizedBox(height: 22),
                  _stats(),
                  const SizedBox(height: 22),
                  _tabs(),
                  const SizedBox(height: 16),
                  if (_tab == _Tab.rsvps) _rsvpsCard() else _guestsCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wedding Admin',
            style: AppTheme.script(size: 28, color: AppPalette.roseDeep)),
        Text('${WeddingConfig.groom} & ${WeddingConfig.bride}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 30)),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      children: [
        ui.GhostButton(
            label: 'View Site', icon: Icons.open_in_new, onPressed: () => context.go('/')),
        ui.PrimaryButton(label: 'Export CSV', icon: Icons.download, onPressed: _exportCsv),
        ui.GhostButton(label: 'Logout', icon: Icons.logout, onPressed: _logout),
      ],
    );

    // Do not use [Spacer] inside [Wrap] — it only works in Row/Column and breaks layout on web.
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              const SizedBox(height: 16),
              actions,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }

  Widget _stats() {
    final tiles = [
      ('Total RSVPs', _rsvps.length, AppPalette.roseDeep),
      ('Attending Guests', _attendingGuests, const Color(0xFF2E7D32)),
      ('Declined', _declinedCount, const Color(0xFFB7791F)),
      ('Pending', _notResponded.length, const Color(0xFF3F51B5)),
    ];
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth > 720 ? 4 : 2;
      final w = (c.maxWidth - (cols - 1) * 14) / cols;
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: tiles.asMap().entries.map((e) {
          final i = e.key;
          final t = e.value;
          return SizedBox(
            width: w,
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.$1.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 11, letterSpacing: 2, color: AppPalette.muted)),
                  const SizedBox(height: 6),
                  Text('${t.$2}',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: t.$3, fontSize: 38)),
                ],
              ),
            ).animate().fadeIn(delay: (i * 60).ms).slideY(begin: .15),
          );
        }).toList(),
      );
    });
  }

  Widget _tabs() {
    Widget chip(String label, _Tab v) => InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () => setState(() => _tab = v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: _tab == v ? AppPalette.roseDeep : Colors.white.withOpacity(.6),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(label,
                style: TextStyle(
                  color: _tab == v ? Colors.white : AppPalette.ink,
                  fontWeight: FontWeight.w600,
                )),
          ),
        );

    return Row(
      children: [
        chip('RSVPs (${_rsvps.length})', _Tab.rsvps),
        const SizedBox(width: 10),
        chip('Guest List (${_guests.length})', _Tab.guests),
      ],
    );
  }

  Widget _rsvpsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search name or phone...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              for (final f in _Filter.values)
                ChoiceChip(
                  label: Text(switch (f) {
                    _Filter.all => 'All',
                    _Filter.yes => 'Attending',
                    _Filter.no => 'Not attending',
                  }),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: AppPalette.gold,
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: AppPalette.rose)),
            )
          else
            _rsvpsTable(),
          if (_notResponded.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text('Pending responses (${_notResponded.length})',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _notResponded
                  .map((g) => SizedBox(
                        width: 280,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppPalette.gold.withOpacity(.3)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(g.phone.isEmpty ? 'No phone' : g.phone,
                                  style: const TextStyle(fontSize: 12, color: AppPalette.muted)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  TextButton(
                                    onPressed: () => _copyInvite(g),
                                    child: const Text('Copy link'),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _remind(g),
                                    icon: const Icon(Icons.send, size: 14),
                                    label: const Text('Remind',
                                        style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF25D366),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rsvpsTable() {
    final list = _filteredRsvps;
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(child: Text('No RSVPs match your filters yet.')),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(.4)),
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Guests')),
          DataColumn(label: Text('Message')),
          DataColumn(label: Text('When')),
        ],
        rows: list.map((r) {
          return DataRow(cells: [
            DataCell(Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(r.phone)),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: r.attending
                      ? const Color(0xFFC8E6C9)
                      : const Color(0xFFFFCDD2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(r.attending ? 'Attending' : 'Declined',
                    style: TextStyle(
                      color: r.attending
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
            DataCell(Text('${r.attending ? (r.guests > 0 ? r.guests : 1) : 0}')),
            DataCell(SizedBox(
              width: 240,
              child: Text(r.message.isEmpty ? '—' : r.message, overflow: TextOverflow.ellipsis),
            )),
            DataCell(Text(_short(r.createdAt),
                style: const TextStyle(fontSize: 11, color: AppPalette.muted))),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _guestsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Create unique invite links — each guest gets a personalized URL.',
                  style: TextStyle(color: AppPalette.muted),
                ),
              ),
              ui.PrimaryButton(label: 'Add Guest', icon: Icons.add, onPressed: _addGuest),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: AppPalette.rose)),
            )
          else if (_guests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: Text('No guests yet — add one!')),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Invite Link')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _guests
                    .map((g) => DataRow(cells: [
                          DataCell(Text(g.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(g.phone.isEmpty ? '—' : g.phone)),
                          DataCell(Text('/invite?guest=${g.slug}',
                              style: const TextStyle(fontSize: 11, color: AppPalette.muted))),
                          DataCell(Wrap(
                            spacing: 6,
                            children: [
                              IconButton(
                                tooltip: 'Copy link',
                                icon: const Icon(Icons.copy, size: 16),
                                onPressed: () => _copyInvite(g),
                              ),
                              IconButton(
                                tooltip: 'Open invite',
                                icon: const Icon(Icons.open_in_new, size: 16),
                                onPressed: () => launchUrl(Uri.parse(_inviteUrl(g)),
                                    webOnlyWindowName: '_blank'),
                              ),
                              IconButton(
                                tooltip: 'WhatsApp',
                                icon: const Icon(Icons.send, size: 16, color: Color(0xFF25D366)),
                                onPressed: () => _remind(g),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(Icons.delete_outline, size: 16, color: AppPalette.roseDeep),
                                onPressed: () => _deleteGuest(g),
                              ),
                            ],
                          )),
                        ]))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _short(String iso) {
    if (iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
