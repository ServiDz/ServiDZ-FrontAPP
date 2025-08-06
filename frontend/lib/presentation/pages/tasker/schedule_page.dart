import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  final Map<DateTime, List<Task>> _tasksByDate = {
    DateTime.now(): [
      Task(
        title: "Complete Flutter UI",
        dueTime: "10:00 AM",
        priority: Priority.high,
      ),
      Task(
        title: "Team Meeting",
        dueTime: "02:30 PM",
        priority: Priority.medium,
        isCompleted: true,
      ),
    ],
    DateTime.now().add(const Duration(days: 1)): [
      Task(
        title: "Gym Session",
        dueTime: "06:00 PM",
        priority: Priority.low,
      ),
    ],
  };

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  Priority _selectedPriority = Priority.medium;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _taskController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTasks = _selectedDay != null ? _tasksByDate[_selectedDay] ?? [] : [];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue[800],
      ),
      body: Column(
        children: [
          // Calendar View
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildCalendar(),
          ),
          // Tasks Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(_selectedDay!),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                const Spacer(),
                Text(
                  "${selectedTasks.length} tasks",
                  style: TextStyle(
                    color: Colors.blue[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Tasks List
          Expanded(
            child: selectedTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.task_outlined,
                          size: 48,
                          color: Colors.blue[200],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No tasks for this day",
                          style: TextStyle(
                            color: Colors.blue[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: selectedTasks.length,
                    itemBuilder: (context, index) => 
                        _buildTaskCard(selectedTasks[index], index),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(color: Colors.blue[800]),
        weekendTextStyle: TextStyle(color: Colors.blue[800]),
        outsideTextStyle: TextStyle(color: Colors.blue[200]),
        todayDecoration: BoxDecoration(
          color: Colors.blue[100],
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.blue[600],
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.blue[400],
          shape: BoxShape.circle,
        ),
        markersAutoAligned: true,
        markerSize: 5,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          color: Colors.blue[800],
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Colors.blue[800],
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Colors.blue[800],
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.blue[800]),
        weekendStyle: TextStyle(color: Colors.blue[800]),
      ),
      eventLoader: (day) {
        return _tasksByDate[day] ?? [];
      },
    );
  }

  Widget _buildTaskCard(Task task, int index) {
    final priorityColors = {
      Priority.high: Colors.red[400]!,
      Priority.medium: Colors.orange[400]!,
      Priority.low: Colors.green[400]!,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                setState(() {
                  _tasksByDate[_selectedDay]![index] = 
                      task.copyWith(isCompleted: value!);
                });
              },
              activeColor: Colors.blue[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            // Task Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.isCompleted 
                          ? Colors.grey 
                          : Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.dueTime,
                        style: TextStyle(
                          color: Colors.blue[400],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColors[task.priority]!.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.priority.toString().split('.').last,
                          style: TextStyle(
                            color: priorityColors[task.priority],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    _timeController.text = DateFormat('HH:mm').format(DateTime.now());

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add New Task",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: "Task Name",
                        labelStyle: TextStyle(color: Colors.blue[600]),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Date",
                        labelStyle: TextStyle(color: Colors.blue[600]),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.blue[400],
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDay!,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Colors.blue[600]!,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          _dateController.text = 
                              DateFormat('yyyy-MM-dd').format(date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _timeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Time",
                        labelStyle: TextStyle(color: Colors.blue[600]),
                        suffixIcon: Icon(
                          Icons.access_time,
                          color: Colors.blue[400],
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Colors.blue[600]!,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (time != null) {
                          _timeController.text = 
                              "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Priority>(
                      value: _selectedPriority,
                      items: Priority.values
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p.toString().split('.').last,
                                  style: TextStyle(color: Colors.blue[800]),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedPriority = value!);
                      },
                      decoration: InputDecoration(
                        labelText: "Priority",
                        labelStyle: TextStyle(color: Colors.blue[600]),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.blue[400]!),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.blue[600]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_taskController.text.isNotEmpty) {
                                final taskDate = DateFormat('yyyy-MM-dd')
                                    .parse(_dateController.text);
                                
                                setState(() {
                                  _tasksByDate[taskDate] ??= [];
                                  _tasksByDate[taskDate]!.add(Task(
                                    title: _taskController.text,
                                    dueTime: _timeController.text,
                                    priority: _selectedPriority,
                                  ));
                                });
                                
                                _taskController.clear();
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Add Task",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class Task {
  final String title;
  final String dueTime;
  final Priority priority;
  bool isCompleted;

  Task({
    required this.title,
    required this.dueTime,
    required this.priority,
    this.isCompleted = false,
  });

  Task copyWith({
    String? title,
    String? dueTime,
    Priority? priority,
    bool? isCompleted,
  }) {
    return Task(
      title: title ?? this.title,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

enum Priority { high, medium, low }