import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

// Activity Entry Model
class ActivityEntry {
  final String title;
  final DateTime dateTime;
  final String details;
  final String id;
  final String party;
  final String activityType;

  ActivityEntry({
    required this.title,
    required this.dateTime,
    required this.details,
    required this.id,
    required this.party,
    required this.activityType,
  });
}

class Activites extends StatefulWidget {
  const Activites({super.key});

  @override
  _ActivitesState createState() => _ActivitesState();
}

class _ActivitesState extends State<Activites> {
  // Filter variables
  String? _selectedParty;
  String? _selectedActivityType;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  String _sortBy = 'Latest First';
  int? _selectedMonth;
  int? _selectedYear;

  // Sample data
  final List<ActivityEntry> _allEntries = [
    ActivityEntry(
      title: 'Created Inward Challan',
      dateTime: DateTime(2025, 9, 6, 10, 0),
      details: 'A-388, Sudama Puri Colony, Bihari Pura, Ghaziabad-201001',
      id: 'B-08-4433',
      party: 'ABC Enterprises',
      activityType: 'Inward Challan',
    ),
    ActivityEntry(
      title: 'Added Eway Bill Details',
      dateTime: DateTime(2025, 9, 5, 17, 15),
      details: 'Plot 7, Site-IV, Sahibabad Industrial Area, Ghaziabad-201010',
      id: 'B-08-4432',
      party: 'XYZ Industries',
      activityType: 'Eway Bill',
    ),
    ActivityEntry(
      title: 'Created Service Slip',
      dateTime: DateTime(2025, 9, 5, 16, 20),
      details: 'Sector 63, Noida-201301, Uttar Pradesh, India',
      id: 'S-09-5521',
      party: 'ABC Enterprises',
      activityType: 'Service Slip',
    ),
    ActivityEntry(
      title: 'Created Gate Pass',
      dateTime: DateTime(2025, 9, 5, 14, 5),
      details: 'A-388, Sudama Puri Colony, Bihari Pura, Ghaziabad-201001',
      id: 'G-08-3312',
      party: 'PQR Limited',
      activityType: 'Gate Pass',
    ),
    ActivityEntry(
      title: 'Created Inward Challan',
      dateTime: DateTime(2025, 9, 5, 11, 30),
      details: 'Industrial Area Phase 2, Chandigarh-160002',
      id: 'B-08-4434',
      party: 'XYZ Industries',
      activityType: 'Inward Challan',
    ),
    ActivityEntry(
      title: 'Created Outward Challan',
      dateTime: DateTime(2025, 9, 5, 9, 45),
      details: 'Knowledge Park, Greater Noida-201310',
      id: 'O-08-7721',
      party: 'ABC Enterprises',
      activityType: 'Outward Challan',
    ),
    ActivityEntry(
      title: 'Updated Gate Pass',
      dateTime: DateTime(2025, 8, 28, 15, 30),
      details: 'Sector 18, Gurgaon-122001, Haryana, India',
      id: 'G-08-3310',
      party: 'PQR Limited',
      activityType: 'Gate Pass',
    ),
  ];

  List<String> get _parties {
    return _allEntries.map((e) => e.party).toSet().toList()..sort();
  }

  List<String> get _activityTypes {
    return _allEntries.map((e) => e.activityType).toSet().toList()..sort();
  }

  List<ActivityEntry> get _filteredEntries {
    List<ActivityEntry> filtered = List.from(_allEntries);

    // Party filter
    if (_selectedParty != null) {
      filtered = filtered.where((e) => e.party == _selectedParty).toList();
    }

    // Activity type filter
    if (_selectedActivityType != null) {
      filtered = filtered
          .where((e) => e.activityType == _selectedActivityType)
          .toList();
    }

    // Date range filter
    if (_startDate != null) {
      filtered = filtered
          .where((e) =>
              e.dateTime.isAfter(_startDate!.subtract(Duration(days: 1))))
          .toList();
    }
    if (_endDate != null) {
      filtered = filtered
          .where((e) => e.dateTime.isBefore(_endDate!.add(Duration(days: 1))))
          .toList();
    }

    // Month filter
    if (_selectedMonth != null && _selectedYear != null) {
      filtered = filtered
          .where((e) =>
              e.dateTime.month == _selectedMonth &&
              e.dateTime.year == _selectedYear)
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((e) =>
              e.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.details.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Sorting
    if (_sortBy == 'Latest First') {
      filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    } else {
      filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }

    return filtered;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedParty = null;
      _selectedActivityType = null;
      _startDate = null;
      _endDate = null;
      _searchQuery = '';
      _selectedMonth = null;
      _selectedYear = null;
    });
  }

  void _applyQuickFilter(String filter) {
    setState(() {
      DateTime now = DateTime.now();
      switch (filter) {
        case 'Today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day);
          _selectedMonth = null;
          _selectedYear = null;
          break;
        case 'Yesterday':
          DateTime yesterday = now.subtract(Duration(days: 1));
          _startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
          _endDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
          _selectedMonth = null;
          _selectedYear = null;
          break;
        case 'This Week':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _endDate = now;
          _selectedMonth = null;
          _selectedYear = null;
          break;
        case 'This Month':
          _selectedMonth = now.month;
          _selectedYear = now.year;
          _startDate = null;
          _endDate = null;
          break;
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: ListView(
                  children: [
                    // Quick Filters
                    Text('Quick Filters',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        'Today',
                        'Yesterday',
                        'This Week',
                        'This Month'
                      ].map((filter) {
                        return ChoiceChip(
                          label: Text(filter),
                          selected: false,
                          onSelected: (selected) {
                            _applyQuickFilter(filter);
                            setModalState(() {});
                            setState(() {});
                          },
                          selectedColor: Colors.teal,
                          labelStyle: TextStyle(color: Colors.teal.shade700),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    // Party Filter
                    Text('Party/Customer',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedParty,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select Party',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        DropdownMenuItem(
                            value: null, child: Text('All Parties')),
                        ..._parties.map((party) =>
                            DropdownMenuItem(value: party, child: Text(party))),
                      ],
                      onChanged: (value) {
                        setModalState(() => _selectedParty = value);
                        setState(() => _selectedParty = value);
                      },
                    ),
                    SizedBox(height: 20),

                    // Activity Type Filter
                    Text('Activity Type',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedActivityType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select Type',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        DropdownMenuItem(value: null, child: Text('All Types')),
                        ..._activityTypes.map((type) =>
                            DropdownMenuItem(value: type, child: Text(type))),
                      ],
                      onChanged: (value) {
                        setModalState(() => _selectedActivityType = value);
                        setState(() => _selectedActivityType = value);
                      },
                    ),
                    SizedBox(height: 20),

                    // Month & Year Filter
                    Text('Month & Year',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedMonth,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Month',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            items: [
                              DropdownMenuItem(value: null, child: Text('All')),
                              ...List.generate(
                                  12,
                                  (i) => DropdownMenuItem(
                                        value: i + 1,
                                        child: Text([
                                          'Jan',
                                          'Feb',
                                          'Mar',
                                          'Apr',
                                          'May',
                                          'Jun',
                                          'Jul',
                                          'Aug',
                                          'Sep',
                                          'Oct',
                                          'Nov',
                                          'Dec'
                                        ][i]),
                                      )),
                            ],
                            onChanged: (value) {
                              setModalState(() => _selectedMonth = value);
                              setState(() => _selectedMonth = value);
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedYear,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Year',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            items: [
                              DropdownMenuItem(value: null, child: Text('All')),
                              ...List.generate(
                                  6,
                                  (i) => DropdownMenuItem(
                                        value: 2025 - i,
                                        child: Text('${2025 - i}'),
                                      )),
                            ],
                            onChanged: (value) {
                              setModalState(() => _selectedYear = value);
                              setState(() => _selectedYear = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Date Range Filter
                    Text('Date Range',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.calendar_today),
                            label: Text(_startDate == null
                                ? 'Start Date'
                                : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  _startDate = picked;
                                  _selectedMonth = null;
                                  _selectedYear = null;
                                });
                                setState(() {
                                  _startDate = picked;
                                  _selectedMonth = null;
                                  _selectedYear = null;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.calendar_today),
                            label: Text(_endDate == null
                                ? 'End Date'
                                : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  _endDate = picked;
                                  _selectedMonth = null;
                                  _selectedYear = null;
                                });
                                setState(() {
                                  _endDate = picked;
                                  _selectedMonth = null;
                                  _selectedYear = null;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Sort By
                    Text('Sort By',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _sortBy,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: ['Latest First', 'Oldest First']
                          .map((sort) =>
                              DropdownMenuItem(value: sort, child: Text(sort)))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() => _sortBy = value!);
                        setState(() => _sortBy = value!);
                      },
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _clearAllFilters();
                        setModalState(() {});
                        Navigator.pop(context);
                      },
                      child: Text('Clear All'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Apply Filters',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text("Daily Entries", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by ID, Title, or Details...',
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // Active Filters Chips
          if (_selectedParty != null ||
              _selectedActivityType != null ||
              _startDate != null ||
              _selectedMonth != null)
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedParty != null)
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text('Party: $_selectedParty'),
                        onDeleted: () => setState(() => _selectedParty = null),
                        deleteIcon: Icon(Icons.close, size: 18),
                      ),
                    ),
                  if (_selectedActivityType != null)
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text('Type: $_selectedActivityType'),
                        onDeleted: () =>
                            setState(() => _selectedActivityType = null),
                        deleteIcon: Icon(Icons.close, size: 18),
                      ),
                    ),
                  if (_selectedMonth != null)
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text('Month: ${[
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec'
                        ][_selectedMonth! - 1]} $_selectedYear'),
                        onDeleted: () => setState(() {
                          _selectedMonth = null;
                          _selectedYear = null;
                        }),
                        deleteIcon: Icon(Icons.close, size: 18),
                      ),
                    ),
                  if (_startDate != null || _endDate != null)
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(
                            'Date: ${_startDate?.day}/${_startDate?.month} - ${_endDate?.day}/${_endDate?.month}'),
                        onDeleted: () => setState(() {
                          _startDate = null;
                          _endDate = null;
                        }),
                        deleteIcon: Icon(Icons.close, size: 18),
                      ),
                    ),
                ],
              ),
            ),

          // Results Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredEntries.length} Results',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700),
                ),
                if (_selectedParty != null ||
                    _selectedActivityType != null ||
                    _startDate != null ||
                    _selectedMonth != null)
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: Text('Clear All'),
                  ),
              ],
            ),
          ),

          // Entries List
          Expanded(
            child: _filteredEntries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No activities found',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredEntries.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildEntry(_filteredEntries[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntry(ActivityEntry entry) {
    String getMonthAbbreviation(int month) {
      const months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ];
      return months[month - 1];
    }

    final String date =
        "${entry.dateTime.day} ${getMonthAbbreviation(entry.dateTime.month)} ${entry.dateTime.year}";
    final String time =
        "${entry.dateTime.hour.toString().padLeft(2, '0')}:${entry.dateTime.minute.toString().padLeft(2, '0')}";

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 58,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 13,
                    child: Icon(Icons.person, color: Colors.teal, size: 18),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  Text(
                    entry.id,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.business, size: 16, color: Colors.grey.shade600),
              SizedBox(width: 4),
              Text(entry.party,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 16, color: Colors.grey.shade600),
              SizedBox(width: 4),
              Text(date, style: TextStyle(fontSize: 14, color: Colors.black87)),
              SizedBox(width: 16),
              Icon(Icons.access_time_outlined,
                  size: 16, color: Colors.grey.shade600),
              SizedBox(width: 4),
              Text(time, style: TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
          SizedBox(height: 8),
          Text(entry.details,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}

class DailyEntries extends StatefulWidget {
  const DailyEntries({
    super.key,
  });

  @override
  _DailyEntriesState createState() => _DailyEntriesState();
}

class _DailyEntriesState extends State<DailyEntries> {
  // State variable to hold the currently selected date.
  // It's initialized to a specific date to match the sample data for demonstration.
  // In a real app, you would use DateTime.now().
  DateTime _selectedDate = DateTime(2025, 9, 6);

  // A complete list of all entries. In a real app, this would come from a database or API.
  final List<ActivityEntry> _allEntries = [
    // Today's entries (Sep 6, 2025)
    // ActivityEntry(
    //   title: 'Created Inward Challan',
    //   dateTime: DateTime(2025, 9, 5, 10, 0),
    //   details:
    //       'A-388, Sudama Puri Colony, Bihari Pura, Ghaziabad-201001, Uttar Pradesh, India',
    //   id: 'B-08-4433',
    // ),
    // ActivityEntry(
    //   title: 'Updated Gate Pass',
    //   dateTime: DateTime(2025, 9, 5, 14, 30),
    //   details:
    //       'Plot 7, Site-IV, Sahibabad Industrial Area, Ghaziabad-201010, Uttar Pradesh, India',
    //   id: 'C-01-1122',
    // ),
    // // Yesterday's entries (Sep 5, 2025)
    // ActivityEntry(
    //   title: 'Added Eway Bill Details',
    //   dateTime: DateTime(2025, 9, 5, 17, 15),
    //   details:
    //       'A-388, Sudama Puri Colony, Bihari Pura, Ghaziabad-201001, Uttar Pradesh, India',
    //   id: 'B-08-4432',
    // ),
    // ActivityEntry(
    //   title: 'Created Service Slip',
    //   dateTime: DateTime(2025, 9, 5, 16, 20),
    //   details:
    //       'A-388, Sudama Puri Colony, Bihari Pura, Ghaziabad-201001, Uttar Pradesh, India',
    //   id: 'B-08-4432',
    // ),
    // ActivityEntry(
    //   title: 'Created Gate Pass',
    //   dateTime: DateTime(2025, 9, 5, 14, 5),
    //   details:
    //       'A-388, Sudama Puri Colony, Bihari Pura, Ghaziabad-201001, Uttar Pradesh, India',
    //   id: 'B-08-4432',
    // ),
    // ActivityEntry(
    //   title: 'Created Inward Challan',
    //   dateTime: DateTime(2025, 9, 5, 11, 30),
    //   details:
    //       'A-388, Sudama Puri Colony, Bihari Pura, Ghaziabad-201001, Uttar Pradesh, India',
    //   id: 'B-08-4432',
    // ),
    // ActivityEntry(
    //   title: 'Created Outward Challan',
    //   dateTime: DateTime(2025, 9, 5, 9, 45),
    //   details:
    //       'A-388, Sudama Puri Colony, Bihari Pura, Ghaziabad-201001, Uttar Pradesh, India',
    //   id: 'B-08-4432',
    // ),
  ];

  // This list will hold only the entries that match the _selectedDate.
  List<ActivityEntry> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    // Filter the entries for the initial selected date when the widget is first created.
    _filterEntries();
  }

  // This function filters the main list of entries based on the selected date.
  void _filterEntries() {
    setState(() {
      _filteredEntries = _allEntries.where((entry) {
        return entry.dateTime.year == _selectedDate.year &&
            entry.dateTime.month == _selectedDate.month &&
            entry.dateTime.day == _selectedDate.day;
      }).toList();
    });
  }

  // This function shows the date picker and updates the state.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      // If a new date is picked, update the state and filter the entries again.
      _selectedDate = picked;
      _filterEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          "Activities",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Widget to display and change the current date
            _buildDatePicker(context),
            SizedBox(height: 20),
            // The list of entries for the selected date
            Expanded(
              child: _filteredEntries.isEmpty
                  ? Center(
                      child: Text(
                        "No activities found for this date.",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredEntries.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildEntry(entry: _filteredEntries[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // A widget for picking the date
  Widget _buildDatePicker(BuildContext context) {
    // Helper to get full month name
    String getMonthName(int month) {
      const months = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ];
      return months[month - 1];
    }

    String formattedDate =
        "${_selectedDate.day} ${getMonthName(_selectedDate.month)}, ${_selectedDate.year}";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedDate,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.teal),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
    );
  }

  // The widget for a single entry card, now taking an ActivityEntry object
  Widget _buildEntry({required ActivityEntry entry}) {
    // Helper to get short month name
    String getMonthAbbreviation(int month) {
      const months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ];
      return months[month - 1];
    }

    // Format date and time from the DateTime object
    final String date =
        "${entry.dateTime.day} ${getMonthAbbreviation(entry.dateTime.month)} ${entry.dateTime.year}";
    final String time =
        "${entry.dateTime.hour.toString().padLeft(2, '0')}:${entry.dateTime.minute.toString().padLeft(2, '0')}";

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 58,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 13,
                    child: Icon(
                      Icons.person,
                      color: Colors.teal,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    entry.title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Spacer(),
                  Text(
                    entry.id,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 16, color: Colors.grey.shade600),
              SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.access_time_outlined,
                  size: 16, color: Colors.grey.shade600),
              SizedBox(width: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            entry.details,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
