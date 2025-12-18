import 'package:flutter/material.dart';

class BannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 239, 186, 190),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          
          SizedBox(
            height: 130, // increased
            width: 120, // increased
            child: Image.asset(
              "assets/images/blood_banner.png",
              fit: BoxFit.cover, // zooms inside frame
            ),
          ),

          const SizedBox(width: 14), 
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                Text(
                  "Save a life",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "Give Blood",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

            
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    _Dot(color: Colors.red),
                    SizedBox(width: 5),
                    _Dot(color: Colors.black),
                    SizedBox(width: 5),
                    _Dot(color: Colors.white),
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

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
