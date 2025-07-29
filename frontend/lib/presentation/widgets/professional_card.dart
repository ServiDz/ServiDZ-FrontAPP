import 'package:flutter/material.dart';

class ProfessionalCard extends StatelessWidget {
  final String name;
  final String job;
  final String location;
  final String image;
  final bool available;
  final double rating;
  final Color backgroundColor;

  const ProfessionalCard({
    super.key,
    required this.name,
    required this.job,
    required this.location,
    required this.image,
    required this.available,
    required this.rating,
    required this.backgroundColor, required Color primaryColor, required int elevation, required Null Function() onTap, required Color accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(image),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(job),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.circle,
                        color: available ? Colors.green : Colors.red, size: 10),
                    const SizedBox(width: 4),
                    Text(
                      available ? 'Available' : 'Unavailable',
                      style: TextStyle(
                          color: available ? Colors.green : Colors.red,
                          fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ...List.generate(
                      rating.floor(),
                      (index) =>
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                    ),
                    if (rating % 1 > 0)
                      const Icon(Icons.star_half,
                          color: Colors.amber, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
