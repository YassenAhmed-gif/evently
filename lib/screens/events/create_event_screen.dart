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

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _locationCtrl = TextEditingController();
  EventCategory _category = EventCategory.sport;
  DateTime? _date;
  TimeOfDay? _time;
  bool _isSaving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) setState(() => _time = t);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please choose a date'),
        backgroundColor: AppColor.red,
      ));
      return;
    }

    setState(() => _isSaving = true);

    try {
      await context.read<EventProvider>().addEvent(
            title: _title.text.trim(),
            description: _description.text.trim(),
            category: _category,
            date: _date!,
            time: _time,
            location: _locationCtrl.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to add event: $e'),
          backgroundColor: AppColor.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.createEvent)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyle.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category banner preview
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
                  value: _date == null
                      ? l.chooseDate
                      : DateFormat.yMMMd(l.localeName).format(_date!),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 12),
                _PickerRow(
                  icon: Icons.access_time,
                  label: l.eventTime,
                  value:
                      _time == null ? l.chooseTime : _time!.format(context),
                  onTap: _pickTime,
                ),
                const SizedBox(height: 16),
                Text(l.location, style: AppStyle.title18),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _locationCtrl,
                  hint: l.chooseEventLocation,
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 28),
                _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit, child: Text(l.addEvent)),
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
