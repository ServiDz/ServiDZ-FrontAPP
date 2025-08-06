import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/data/services/earning_service.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');
  TimeRange _selectedTimeRange = TimeRange.weekly;
  int _currentIndex = 1;

  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic> _apiData = {};
  String? _accessToken;
  final EarningService _earningService = EarningService();


  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchData();
  }

Future<void> _loadTokenAndFetchData() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    final token = await _earningService.getAccessToken();
    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication required. Please login again.';
      });
      return;
    }

    await _fetchEarnings(token);
  } catch (e) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Something went wrong. Please try again.';
    });
  }
}


 Future<void> _fetchEarnings(String token) async {
  try {
    final data = await _earningService.fetchEarnings(token);
    setState(() {
      _apiData = data!;
      _isLoading = false;
    });
  } on UnauthorizedException {
    try {
      final newToken = await _earningService.refreshToken();
      if (newToken != null) {
        await _fetchEarnings(newToken);
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Session expired. Please login again.';
        _isLoading = false;
      });
    }
  } catch (e) {
    print('[EXCEPTION] Error in fetch: $e');
    setState(() {
      _isLoading = false;
      _errorMessage = 'Failed to load earnings. Please try again.';
    });
  }
}


  Future<void> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');
      
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await http.post(
        Uri.parse('http://192.168.1.16:5000/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await prefs.setString('accessToken', data['accessToken']);
        setState(() {
          _accessToken = data['accessToken'];
        });
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Session expired. Please login again.';
      });
    }
  }

  List<Earning> get _currentEarnings {
    final earnings = (_apiData['earnings'] as List?) ?? [];
    
    return earnings.map((e) {
      final date = DateTime.parse(e['createdAt']);
      String day;
      
      switch (_selectedTimeRange) {
        case TimeRange.weekly:
          day = DateFormat('EEE').format(date);
          break;
        case TimeRange.monthly:
          day = 'Week ${((date.day - 1) ~/ 7) + 1}';
          break;
        case TimeRange.yearly:
          day = DateFormat('MMM').format(date);
          break;
      }
      
      return Earning(
        day: day,
        amount: (e['amount'] ?? 0).toDouble(),
        completedJobs: 1,
      );
    }).toList();
  }

  double get _totalEarnings => (_apiData['total'] ?? 0).toDouble();
  int get _totalJobs => (_apiData['earnings'] as List?)?.length ?? 0;
  double get _averagePerJob => _totalJobs > 0 ? _totalEarnings / _totalJobs : 0;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
              ),
              SizedBox(height: 16),
              Text(
                'Loading your earnings...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadTokenAndFetchData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Earnings",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTokenAndFetchData,
        color: Colors.blue[800],
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeRangeSelector(),
              const SizedBox(height: 24),
              
              // Summary Cards
              Row(
                children: [
                  Expanded(child: _buildSummaryCard(
                    title: "Total Earnings",
                    value: _currencyFormat.format(_totalEarnings),
                    icon: Icons.attach_money_outlined,
                    color: Colors.blue,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard(
                    title: "Completed Jobs",
                    value: _totalJobs.toString(),
                    icon: Icons.check_circle_outlined,
                    color: Colors.green,
                  )),
                ],
              ),
              const SizedBox(height: 12),
              _buildSummaryCard(
                title: "Average per Job",
                value: _currencyFormat.format(_averagePerJob),
                icon: Icons.trending_up_outlined,
                color: Colors.orange,
                fullWidth: true,
              ),
              const SizedBox(height: 24),
              
              // Earnings Chart
              _buildEarningsChart(_currentEarnings),
              const SizedBox(height: 24),
              
              // Transaction History
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Transaction History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ..._currentEarnings.map((earning) => _buildTransactionItem(earning)).toList(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTimeRangeButton(TimeRange.weekly, 'Weekly'),
          _buildTimeRangeButton(TimeRange.monthly, 'Monthly'),
          _buildTimeRangeButton(TimeRange.yearly, 'Yearly'),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(TimeRange range, String label) {
    final isSelected = _selectedTimeRange == range;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _selectedTimeRange = range),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[800] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.blue[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              if (!fullWidth)
                Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
            ],
          ),
          const SizedBox(height: 16),
          Text(title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsChart(List<Earning> earnings) {
    // For weekly view, we want to show all days from Sunday to Thursday
    if (_selectedTimeRange == TimeRange.weekly) {
      final daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
      final existingDays = earnings.map((e) => e.day).toList();
      
      // Add missing days with zero earnings
      for (final day in daysOfWeek) {
        if (!existingDays.contains(day)) {
          earnings.add(Earning(day: day, amount: 0, completedJobs: 0));
        }
      }
      
      // Sort by day of week
      earnings.sort((a, b) {
        return daysOfWeek.indexOf(a.day).compareTo(daysOfWeek.indexOf(b.day));
      });
    }

    // Group earnings by day/week/month
    final groupedEarnings = <String, Earning>{};
    for (final earning in earnings) {
      if (groupedEarnings.containsKey(earning.day)) {
        final existing = groupedEarnings[earning.day]!;
        groupedEarnings[earning.day] = Earning(
          day: earning.day,
          amount: existing.amount + earning.amount,
          completedJobs: existing.completedJobs + earning.completedJobs,
        );
      } else {
        groupedEarnings[earning.day] = earning;
      }
    }

    final chartData = groupedEarnings.values.toList();
    final maxAmount = chartData.fold(0.0, (max, item) => item.amount > max ? item.amount : max);
    final minBarHeight = 8.0;
    final maxBarHeight = 150.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Earnings Overview",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline, color: Colors.grey[500]),
                onPressed: () {
                  // Show info dialog
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((earning) {
                final heightFactor = maxAmount > 0 ? earning.amount / maxAmount : 0;
                final barHeight = (maxBarHeight * heightFactor).clamp(minBarHeight, maxBarHeight);
                final hasEarnings = earning.amount > 0;
                
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: '${earning.day}: ${_currencyFormat.format(earning.amount)}',
                        child: Container(
                          height: barHeight,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: hasEarnings 
                              ? LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.blue[800]!,
                                    Colors.blue[400]!,
                                  ],
                                )
                              : null,
                            color: hasEarnings ? null : Colors.white,
                          ),
                          child: Center(
                            child: hasEarnings 
                              ? null 
                              : Text(
                                  '',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        earning.day,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _currencyFormat.format(earning.amount),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Earning earning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.credit_card, 
              size: 20, 
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${earning.completedJobs} Jobs Completed",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  earning.day,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormat.format(earning.amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${earning.completedJobs} job${earning.completedJobs != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Earning {
  final String day;
  final double amount;
  final int completedJobs;

  Earning({
    required this.day,
    required this.amount,
    required this.completedJobs,
  });
}

enum TimeRange { weekly, monthly, yearly }

