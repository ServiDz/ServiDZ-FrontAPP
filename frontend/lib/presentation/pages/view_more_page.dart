import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/data/services/tasker_service.dart';
import 'package:frontend/data/services/ai_service.dart';

class ViewMore extends StatefulWidget {
  const ViewMore({Key? key}) : super(key: key);

  @override
  State<ViewMore> createState() => _ViewMoreState();
}


class _ViewMoreState extends State<ViewMore> {
  List<Map<String, dynamic>> _taskers = [];
  List<Map<String, dynamic>> _filteredTaskers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isAIProcessing = false;
  double _aiButtonScale = 1.0;
  double _aiButtonRotation = 0.0;
  double _aiButtonElevation = 4.0;

  @override
  void initState() {
    super.initState();
    _loadTaskers();
  }

  Future<void> _loadTaskers() async {
    try {
      final taskers = await TaskerService().fetchTaskers();
      setState(() {
        _taskers = taskers;
        _filteredTaskers = taskers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load taskers: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _searchTaskers(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredTaskers = _taskers.where((tasker) {
        final name = tasker['name'].toLowerCase();
        final skills = tasker['skills'].toLowerCase();
        return name.contains(query.toLowerCase()) || 
                skills.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _filteredTaskers = _taskers;
    });
  }

  Future<void> _showAIExplanationDialog() async {
    final shouldProceed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 36,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'AI Tasker Match',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Upload a photo of your problem and our AI will recommend the perfect taskers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Colors.blue,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldProceed ?? false) {
      await _pickAndAnalyzeImage();
    }
  }

  Future<void> _pickAndAnalyzeImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _isAIProcessing = true;
          _aiButtonRotation = 0.0;
          _aiButtonScale = 0.9;
          _aiButtonElevation = 2.0;
        });
        
      showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    contentPadding: const EdgeInsets.symmetric(
      vertical: 24,
      horizontal: 16,
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(Colors.blue[700]!),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Analyzing your image...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.blue[800],
          ),
        ),
      ],
    ),
  ),
);

        final response = await AIService.predictCategory(File(image.path));
        
        Navigator.of(context).pop();
        
        final predictedCategory = response['category'] as String? ?? 'unknown';
        final taskers = (response['taskers'] as List?) ?? [];

        setState(() {
          _isSearching = true;
          _searchController.text = predictedCategory;
          _filteredTaskers = taskers.map<Map<String, dynamic>>((tasker) {
            return {
              'name': tasker['fullName'] ?? 'Unknown Tasker',
              'skills': tasker['profession'] ?? 'No skills listed',
              'profileImage': tasker['profilePic'] ?? '',
              'rating': tasker['rating']?.toString() ?? '0',
              'reviews': (tasker['ratings']?.length ?? 0).toString(),
            };
          }).toList();
          _isAIProcessing = false;
          _aiButtonScale = 1.0;
          _aiButtonElevation = 4.0;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI suggested: $predictedCategory'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      setState(() {
        _isAIProcessing = false;
        _aiButtonScale = 1.0;
        _aiButtonElevation = 4.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildAISearchButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()
        ..scale(_aiButtonScale)
        ..rotateZ(_aiButtonRotation * 3.1415927 / 180),
      child: FloatingActionButton(
        onPressed: _isAIProcessing ? null : () {
          setState(() {
            _aiButtonScale = 0.9;
            _aiButtonRotation = -5.0;
            _aiButtonElevation = 2.0;
          });
          Future.delayed(const Duration(milliseconds: 100), () {
            setState(() {
              _aiButtonScale = 1.0;
              _aiButtonRotation = 5.0;
            });
            Future.delayed(const Duration(milliseconds: 100), () {
              setState(() {
                _aiButtonRotation = 0.0;
                _aiButtonElevation = 4.0;
              });
              _showAIExplanationDialog();
            });
          });
        },
        backgroundColor: Colors.blue,
        elevation: _aiButtonElevation,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isAIProcessing
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                )
              : const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
        ),
      ),
    );
  }

  Widget _buildTaskerCard(Map<String, dynamic> tasker) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle tasker tap
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(tasker['profileImage']),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: Colors.blue[100]!,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tasker['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tasker['skills'],
                      style: TextStyle(
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber[400],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tasker['rating']} (${tasker['reviews']} reviews)',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.blue[400],
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
      backgroundColor: Colors.grey[50],
      floatingActionButton: _buildAISearchButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading taskers...',
                    style: TextStyle(
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadTaskers,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                          ),
                          child: const Text(
                            'Try Again',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _searchTaskers,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Search taskers...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.blue,
                            ),
                            suffixIcon: _isSearching
                                ? IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.grey[500],
                                    ),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    if (_isSearching)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Text(
                              '${_filteredTaskers.length} ${_filteredTaskers.length == 1 ? 'match' : 'matches'} found',
                              style: TextStyle(
                                color: Colors.blue[800],
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: _clearSearch,
                              child: Text(
                                'Clear',
                                style: TextStyle(
                                  color: Colors.blue[400],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: _filteredTaskers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 60,
                                    color: Colors.blue[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _isSearching
                                        ? 'No matching taskers found'
                                        : 'No taskers available',
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isSearching
                                        ? 'Try adjusting your search or use our AI search'
                                        : 'Check back later for available taskers',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (_isSearching) ...[
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: _showAIExplanationDialog,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 14,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.auto_awesome,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      label: const Text(
                                        'Try AI Search',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
                              itemCount: _filteredTaskers.length,
                              itemBuilder: (context, index) {
                                final tasker = _filteredTaskers[index];
                                return _buildTaskerCard(tasker);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}