import 'package:flutter/material.dart';

class VehiclePlateWidget extends StatelessWidget {
  final String plate;
  final bool isMercosul;
  final String city;

  const VehiclePlateWidget({
    super.key,
    required this.plate,
    this.isMercosul = true,
    this.city = "BRASIL",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 35,
      decoration: BoxDecoration(
        color: isMercosul ? Colors.white : const Color(0XFFB0B0B0),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: isMercosul ? const Color(0xFF003399) : Colors.transparent,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            ),
            child: isMercosul
            ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.public, size: 6, color: Colors.white),
                  Text(
                    city.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(width: 6, height: 4, color: Colors.green),
                ],
              ),
            )
            : Center(
              child: Text(
                city.toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                plate.toUpperCase(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isMercosul ? 12 : 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
