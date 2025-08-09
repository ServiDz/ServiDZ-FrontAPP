import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend/data/services/schedule_service.dart'; 

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late AnimationController _animationController;
  final Map<DateTime, List<Booking>> _bookingsByDate = {};
  bool _isLoading = true;
  String? _taskerId;
  String _apiBaseUrl = 'http://192.168.1.4:5000';

  // Modern blue color scheme
  final Color _primaryColor = const Color(0xFF4285F4);
  final Color _darkBlue = const Color(0xFF3367D6);
  final Color _lightBlue = const Color(0xFFE8F0FE);
  final Color _white = Colors.white;
  final Color _textColor = const Color(0xFF202124);
  final Color _textSecondary = const Color(0xFF5F6368);

  final ScheduleService _scheduleService = ScheduleService();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    print('🔄 Starting _fetchSchedule...');
    setState(() => _isLoading = true);

    try {
      print('📥 Getting taskerId from SharedPreferences...');
      final taskerId = await _scheduleService.getTaskerId();
      print('📋 Retrieved taskerId: $taskerId');

      if (taskerId == null) {
        print('❌ Tasker ID is null, throwing exception');
        throw Exception('Tasker ID not found');
      }

      print('🌐 Fetching bookings for taskerId: $taskerId');
      final bookings = await _scheduleService.fetchSchedule(taskerId);
      print('✅ Bookings fetched: ${bookings.length}');

      setState(() {
        print('🧹 Clearing existing bookings...');
        _bookingsByDate.clear();

        for (var booking in bookings) {
          final normalizedDate = DateTime(booking.date.year, booking.date.month, booking.date.day);
          print('📅 Processing booking for date: $normalizedDate with description: ${booking.description}');

          _bookingsByDate[normalizedDate] ??= [];
          _bookingsByDate[normalizedDate]!.add(booking);
        }
      });

      print('🎬 Starting animation controller forward...');
      _animationController.forward();
    } catch (e) {
      print('❗ Error loading schedule: $e');
      debugPrint('Error loading schedule: $e');
      _showErrorSnackbar('Failed to load schedule');
    } finally {
      print('🔄 Finished _fetchSchedule, setting _isLoading to false');
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Booking> selectedBookings = _selectedDay != null
        ? (_bookingsByDate[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? <Booking>[])
        : <Booking>[];

    return Scaffold(
      backgroundColor: _white,
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingIndicator()
          : Column(
              children: [
                _buildCalendarSection(),
                _buildDateHeader(selectedBookings.length),
                _buildBookingsList(selectedBookings),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "My Schedule",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: _primaryColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading your schedule...",
            style: TextStyle(
              color: _textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildCalendar(),
      ),
    );
  }

  Widget _buildDateHeader(int bookingCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Text(
            DateFormat('EEEE, MMMM d').format(_selectedDay!),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "$bookingCount ${bookingCount == 1 ? 'event' : 'events'}",
              style: TextStyle(
                color: _darkBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings) {
    return Expanded(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: bookings.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: bookings.length,
                itemBuilder: (context, index) =>
                    _buildBookingCard(bookings[index], index),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: _lightBlue,
          ),
          const SizedBox(height: 16),
          Text(
            "No bookings for this day",
            style: TextStyle(
              color: _textSecondary,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() => _calendarFormat = format);
      },
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(color: _textColor),
        weekendTextStyle: TextStyle(color: _textColor),
        outsideTextStyle: TextStyle(color: _textSecondary.withOpacity(0.5)),
        todayDecoration: BoxDecoration(
          color: _lightBlue,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: _primaryColor,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: _primaryColor,
          shape: BoxShape.circle,
        ),
        markersAutoAligned: true,
        markerSize: 6,
        markerMargin: const EdgeInsets.symmetric(horizontal: 1),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          border: Border.all(color: _primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        formatButtonTextStyle: TextStyle(color: _primaryColor),
        titleTextStyle: TextStyle(
          color: _textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: _primaryColor,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: _primaryColor,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: _textColor.withOpacity(0.8)),
        weekendStyle: TextStyle(color: _textColor.withOpacity(0.8)),
      ),
      eventLoader: (day) {
        final normalizedDay = DateTime(day.year, day.month, day.day);
        return _bookingsByDate[normalizedDay] ?? [];
      },
    );
  }

  Widget _buildBookingCard(Booking booking, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200 + (index * 100)),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      transform: Matrix4.translationValues(0, _isLoading ? 50 : 0, 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: _white,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showBookingDetails(booking),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('h:mm a').format(booking.date),
                        style: TextStyle(
                          color: _primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.description,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: _textSecondary.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: _white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: _textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d').format(booking.date),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('h:mm a').format(booking.date),
                      style: TextStyle(
                        fontSize: 14,
                        color: _primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Details",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _lightBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                booking.description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: _textColor.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
