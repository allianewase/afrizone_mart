import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State {
  final _title = TextEditingController();
  final _rate = TextEditingController();
  final _slots = TextEditingController(text: '1');
  String? _category;
  String? _tier;
  String _payModel = 'hourly';
  String _location = 'physical';
  bool _published = false;

  @override
  Widget build(BuildContext context) {
    if (_published) {
      return _successView();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Create a task.', style: AppText.serif(size: 32)),
          const SizedBox(height: 6),
          const Text('Post a paid task for verified workers to apply to.',
              style: TextStyle(fontSize: 15, color: AppColors.text2)),
          const SizedBox(height: 24),

          _label('Title'),
          _input(_title, 'e.g. Weekend promo staff — Surulere'),

          _label('Category'),
          _dropdown(_category, [
            'Field / In-store',
            'Dispatch & delivery',
            'Data & research',
            'Skilled trade',
          ], (v) => setState(() => _category = v)),

          _label('Required tier'),
          _dropdown(_tier, [
            'Student',
            'Dispatch Rider',
            'Remote Freelancer',
            'In-Store / Promo',
            'Skilled Trade',
          ], (v) => setState(() => _tier = v)),

          _label('Pay model'),
          _segmented(),

          _label(_payModel == 'hourly' ? 'Rate per hour (₦)' : 'Fixed fee (₦)'),
          _input(_rate, _payModel == 'hourly' ? 'e.g. 1500' : 'e.g. 120000',
              number: true),

          _label('Work location'),
          _locationToggle(),

          _label('Number of slots'),
          _input(_slots, '1', number: true),

          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _title.text.trim().isEmpty
                  ? null
                  : () => setState(() => _published = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.text3,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text('Publish task',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _successView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✅', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 16),
              Text('Task published.',
                  style: AppText.serif(size: 28), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                  '"${_title.text}" is now open. Matched workers in the ${_tier ?? 'selected'} tier will be notified.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.text2)),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => setState(() {
                  _published = false;
                  _title.clear();
                  _rate.clear();
                  _slots.text = '1';
                  _category = null;
                  _tier = null;
                }),
                child: const Text('Create another'),
              ),
            ],
          ),
        ),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(t,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.text2,
                fontWeight: FontWeight.w500)),
      );

  Widget _input(TextEditingController c, String hint, {bool number = false}) {
    return TextField(
      controller: c,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.text3),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.orange, width: 2),
        ),
      ),
    );
  }

  Widget _dropdown(String? value, List items,
      ValueChanged onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          isExpanded: true,
          hint: const Text('Select…',
              style: TextStyle(color: AppColors.text3, fontSize: 14)),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _segmented() => Row(children: [
        _segBtn('Hourly rate', 'hourly'),
        const SizedBox(width: 8),
        _segBtn('Fixed fee', 'fixed'),
      ]);

  Widget _segBtn(String label, String value) {
    final on = _payModel == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _payModel = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? AppColors.navy : AppColors.surface2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label,
              style: TextStyle(
                  color: on ? Colors.white : AppColors.text2,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ),
    );
  }

  Widget _locationToggle() => Row(children: [
        _segBtnLoc('Physical site', 'physical'),
        const SizedBox(width: 8),
        _segBtnLoc('Remote', 'remote'),
      ]);

  Widget _segBtnLoc(String label, String value) {
    final on = _location == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _location = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? AppColors.navy : AppColors.surface2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label,
              style: TextStyle(
                  color: on ? Colors.white : AppColors.text2,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ),
    );
  }
}
