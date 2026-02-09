import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models/trip_model.dart';
import 'providers/trips_provider.dart';

/// Create/Edit custom trip page
class CreateTripPage extends ConsumerStatefulWidget {
  final TripModel? trip; // null = create, non-null = edit

  const CreateTripPage({super.key, this.trip});

  @override
  ConsumerState<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends ConsumerState<CreateTripPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _startingLocationCtrl;
  late DateTime _startDate;
  late DateTime _endDate;
  late List<String> _places;
  late String _selectedTransport;
  final _placeCtrl = TextEditingController();

  final _transportModes = [
    'Train',
    'Public Transportation',
    'Vehicle (Car)',
    'Bike',
    'Walking',
    'Flying',
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.trip?.title ?? '');
    _descriptionCtrl = TextEditingController(
      text: widget.trip?.description ?? '',
    );
    _startingLocationCtrl = TextEditingController(
      text:
          (widget.trip?.locations != null &&
              (widget.trip!.locations?.isNotEmpty ?? false))
          ? widget.trip!.locations!.first
          : '',
    );
    _startDate = widget.trip?.startDate ?? DateTime.now();
    _endDate =
        widget.trip?.endDate ?? DateTime.now().add(const Duration(days: 1));
    _places = List.from(widget.trip?.locations ?? []);
    _selectedTransport = _transportModes[0];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _startingLocationCtrl.dispose();
    _placeCtrl.dispose();
    super.dispose();
  }

  void _addPlace() {
    if (_placeCtrl.text.isNotEmpty) {
      setState(() {
        _places.add(_placeCtrl.text);
        _placeCtrl.clear();
      });
    }
  }

  void _removePlace(int index) {
    setState(() => _places.removeAt(index));
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _saveTrip() async {
    if (_titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Trip title is required')));
      return;
    }

    if (_places.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one destination')),
      );
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    final now = DateTime.now();

    final trip = TripModel(
      id: widget.trip?.id ?? now.millisecondsSinceEpoch.toString(),
      userId: widget.trip?.userId ?? 'user', // TODO: replace with auth user id
      title: _titleCtrl.text,
      description: _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
      startDate: _startDate,
      endDate: _endDate,
      locations: _places,
      status: widget.trip?.status ?? 'scheduled',
      createdAt: widget.trip?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      ref.read(tripsProvider.notifier).upsertTrip(trip);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.trip == null ? 'Trip created!' : 'Trip updated!',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip == null ? 'Create Trip' : 'Edit Trip'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Trip Title',
              hintText: 'e.g., My Summer Getaway',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // Description
          TextField(
            controller: _descriptionCtrl,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Tell us about this trip...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          // Starting Location
          TextField(
            controller: _startingLocationCtrl,
            decoration: const InputDecoration(
              labelText: 'Starting Location',
              hintText: 'e.g., Colombo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // Start Date
          ListTile(
            title: const Text('Start Date'),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(_startDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickStartDate,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 12),
          // End Date
          ListTile(
            title: const Text('End Date'),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(_endDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickEndDate,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 16),
          // Transportation Mode
          DropdownButtonFormField<String>(
            initialValue: _selectedTransport,
            decoration: const InputDecoration(
              labelText: 'Primary Mode of Transportation',
              border: OutlineInputBorder(),
            ),
            items: _transportModes
                .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedTransport = val);
            },
          ),
          const SizedBox(height: 24),
          // Destinations
          Text(
            'Destinations (${_places.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _placeCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Add destination...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addPlace,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // List of places
          if (_places.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No destinations added yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _places.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, idx) {
                return ListTile(
                  leading: CircleAvatar(child: Text('${idx + 1}')),
                  title: Text(_places[idx]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removePlace(idx),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          // Save Button
          ElevatedButton(
            onPressed: _saveTrip,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(widget.trip == null ? 'Create Trip' : 'Save Changes'),
          ),
        ],
      ),
    );
  }
}
