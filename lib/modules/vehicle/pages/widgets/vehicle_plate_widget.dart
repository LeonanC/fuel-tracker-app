import 'package:flutter/material.dart';

class VehiclePlateWidget extends StatelessWidget {
  final String plate;
  final bool isMercosul;
  final String city;
  final String? state;

  const VehiclePlateWidget({
    super.key,
    required this.plate,
    this.isMercosul = true,
    required this.city,
    this.state,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isMercosul ? Colors.white : const Color(0xFFC0C0C0);
    final borderColor = isMercosul ? Colors.black : const Color(0xFF3A3A3A);

    return Container(
      width: 82,
      height: 38,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: isMercosul ? const Color(0xFF003399) : Colors.transparent,
              border: isMercosul
                  ? null
                  : const Border(
                      bottom: BorderSide(color: Color(0xFF3A3A3A), width: 1),
                    ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(2),
              ),
            ),
            child: isMercosul
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.public, size: 6, color: Colors.white),
                        Text(
                          city.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 5,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 7,
                          height: 5,
                          color: Colors.green,
                          child: Container(
                            width: 3,
                            height: 2,
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      state != null
                      ? "${state!.toUpperCase()} - ${city.toUpperCase()}"
                      : city.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 4.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                        overflow: TextOverflow.ellipsis,
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
                  fontSize: isMercosul ? 13 : 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: isMercosul ? 0.5 : 1.0,
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
