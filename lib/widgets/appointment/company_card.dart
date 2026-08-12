import 'package:flutter/material.dart';

import '../../models/appointment/company.dart';

class CompanyCard extends StatelessWidget {
  final Company company;
  final VoidCallback onBookNow;

  const CompanyCard({
    super.key,
    required this.company,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFFB8B8B8),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            company.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Text(
            company.coverageArea,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6D6D6D),
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: company.services.map((service) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  service,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 13),
          const Divider(color: Color(0xFFD6D6D6)),
          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.greenAccent,
                    size: 16,
                  ),
                  Text(
                    '${company.rating} (${company.reviewCount} reviews)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Text(
                'Response in ${company.responseTime}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onBookNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}