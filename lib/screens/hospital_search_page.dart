import 'package:flutter/material.dart';

import '../widgets/app_widgets.dart';

class HospitalSearchPage extends StatefulWidget {
  const HospitalSearchPage({super.key});

  @override
  State<HospitalSearchPage> createState() => _HospitalSearchPageState();
}

class _HospitalSearchPageState extends State<HospitalSearchPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    setState(() => _query = _searchController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hospital search is not connected to Google Maps yet.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hospital search')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const DemoDataNotice(),
          const SizedBox(height: 18),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submitSearch(),
            decoration: InputDecoration(
              hintText: 'Search hospital or healthcare facility',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Search',
                onPressed: _submitSearch,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 230,
            decoration: BoxDecoration(
              color: const Color(0xFFE6EDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD5DFEA)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 58, color: Color(0xFF52728F)),
                SizedBox(height: 10),
                Text(
                  'Map preview',
                  style: TextStyle(
                    color: Color(0xFF28465F),
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Google Maps integration pending',
                  style: TextStyle(color: Color(0xFF52728F), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Search requested: $_query',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          const EmptyState(
            icon: Icons.local_hospital_outlined,
            title: 'No hospital results loaded',
            message:
                'Connect Places or an appropriate Maps Platform service, '
                'configure a restricted API key, request location permission '
                'only when needed, and then render verified search results here.',
          ),
          const SizedBox(height: 14),
          const Text(
            'This page does not provide verified hospital locations or '
            'emergency routing. For an urgent emergency, use local emergency '
            'services rather than relying on this prototype.',
            style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}
