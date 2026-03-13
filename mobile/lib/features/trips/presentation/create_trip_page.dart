import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models/trip_model.dart';
import '../data/models/trip_dto.dart';
import 'providers/trips_provider.dart';
import '../../places/widgets/destination_picker.dart';

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

  final _transportModes = [
    'Train',
    'Public Transportation',
    'Vehicle (Car)',
    'Bike',
    'Walking',    
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
          ? widget.trip!.locations!.first.name
          : '',
    );
    _startDate = widget.trip?.startDate ?? DateTime.now();
    _endDate =
        widget.trip?.endDate ?? DateTime.now().add(const Duration(days: 1));
    _places = widget.trip?.locations?.map((l) => l.name).toList() ?? [];
    _selectedTransport = _transportModes[0];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _startingLocationCtrl.dispose();
    super.dispose();
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

    final locations = _places.map((p) => TripLocation(name: p, day: 1)).toList();

    try {
      if (widget.trip == null) {
        final dto = CreateTripDto(
          title: _titleCtrl.text,
          description: _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
          startDate: _startDate,
          endDate: _endDate,
          locations: locations,
        );
        await ref.read(tripsProvider.notifier).createTrip(dto);
      } else {
        final dto = UpdateTripDto(
          title: _titleCtrl.text,
          description: _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
          startDate: _startDate,
          endDate: _endDate,
          locations: locations,
        );
        await ref.read(tripsProvider.notifier).updateTrip(widget.trip!.id, dto);
      }

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
          
          // Smart Starting Location
          const Text('Starting Location', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _startingLocationCtrl.text.isEmpty ? 'Search starting point...' : _startingLocationCtrl.text,
                    style: TextStyle(
                      color: _startingLocationCtrl.text.isEmpty ? Colors.grey.shade600 : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.blue),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Select Starting Point'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: DestinationPicker(
                            onDestinationSelected: (name) {
                              setState(() {
                                _startingLocationCtrl.text = name;
                              });
                              Navigator.pop(context); // Close the popup after picking
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
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
            value: _selectedTransport,
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

          // ==========================================
          // MULTIPLE DESTINATIONS SECTION
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Destinations (${_places.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (_places.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() => _places.clear());
                  },
                  child: const Text('Clear All', style: TextStyle(color: Colors.red, fontSize: 12)),
                )
            ],
          ),
          const SizedBox(height: 12),

          // 1. Show the list of chosen destinations
          if (_places.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Text(
                  'No destinations added yet.\nClick below to start adding!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ..._places.asMap().entries.map((entry) {
              final index = entry.key;
              final place = entry.value;
              return Card(
                key: ValueKey('place_$index'),
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.shade100),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.blue.shade600,
                    child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(place, style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        _places.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            }),

          const SizedBox(height: 12),

          // 2. The "Add Another Location" Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add Destination'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: DestinationPicker(
                        onDestinationSelected: (name) {
                          setState(() {
                            if (!_places.contains(name)) {
                              _places.add(name);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Location already added!')),
                              );
                            }
                          });
                          Navigator.pop(context); // Close popup
                        },
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Add Another Location'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: Colors.blue.shade700,
                side: BorderSide(color: Colors.blue.shade300, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 32),

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

