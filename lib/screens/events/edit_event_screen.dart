import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_style.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/custom_text_field.dart';
import '../auth/validators.dart';

class EditEventScreen extends StatefulWidget {
  final EventModel event;
  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _locationTextCtrl;
  late final TextEditingController _description;
  late EventCategory _category;
  late DateTime _date;
  TimeOfDay? _time;
  late String _location;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.event.title);
    _description = TextEditingController(text: widget.event.description);
    _category = widget.event.category;
    _date = widget.event.date;
    _time = widget.event.time;
    _location = widget.event.location;
    _locationTextCtrl = TextEditingController(text: widget.event.location);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _locationTextCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
        context: context,
        initialTime: _time ?? TimeOfDay.now());
    if (t != null) setState(() => _time = t);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final updated = widget.event.copyWith(
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: _category,
      date: _date,
      time: _time,
      location: _location,
    );
    try {
      await context.read<EventProvider>().updateEvent(updated);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColor.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyle.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category banner
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _category.color,
                        _category.color.withValues(alpha: .6)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppStyle.radius),
                  ),
                  child: Icon(_category.icon, size: 72, color: Colors.white54),
                ),
                const SizedBox(height: 16),
                CategoryChips(
                  showAll: false,
                  selected: _category,
                  onSelect: (c) => setState(() => _category = c!),
                ),
                const SizedBox(height: 20),
                Text(l.title, style: AppStyle.title18),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _title,
                  hint: l.eventTitle,
                  icon: Icons.edit_note,
                  validator: (v) => Validators.required(v, l),
                ),
                const SizedBox(height: 16),
                Text(l.description, style: AppStyle.title18),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _description,
                  hint: l.eventDescription,
                  icon: Icons.notes,
                  maxLines: 4,
                  validator: (v) => Validators.required(v, l),
                ),
                const SizedBox(height: 16),
                _PickerRow(
                  icon: Icons.calendar_month_outlined,
                  label: l.eventDate,
                  value: DateFormat.yMMMd(l.localeName).format(_date),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 12),
                _PickerRow(
                  icon: Icons.access_time,
                  label: l.eventTime,
                  value: _time == null ? l.chooseTime : _time!.format(context),
                  onTap: _pickTime,
                ),
                const SizedBox(height: 16),
                Text(l.location, style: AppStyle.title18),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _locationTextCtrl,
                  hint: l.chooseEventLocation,
                  icon: Icons.location_on_outlined,
                  onChanged: (v) => _location = v,
                ),
                const SizedBox(height: 28),
                _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _save,
                        child: const Text('Save Changes'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const _PickerRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColor.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppStyle.body16)),
        TextButton(onPressed: onTap, child: Text(value)),
      ],
    );
  }
}
