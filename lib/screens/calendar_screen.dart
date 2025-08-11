import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  @override
  Widget build(BuildContext context) {
    final days = ['27', '28', '29', '30', '31', '1', '2'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Today',
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Color(0xFF584A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 24,
            color: Color(0xFF584A4A),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Productive Day, Richo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF584A4A),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'July, 29 2025',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF584A4A),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                return index == 2
                    ? CircleAvatar(
                        backgroundColor: Color(0xFFA0D7C8),
                        radius: 18.0,
                        child: Text(
                          days[index],
                          style: TextStyle(
                            fontWeight: index == 2
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Color(0xFF584A4A),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Text(
                        days[index],
                        style: TextStyle(
                          fontWeight:
                              index == 2 ? FontWeight.bold : FontWeight.normal,
                          color: index == 2 ? Colors.black : Colors.grey,
                          fontSize: 16,
                        ),
                      );
              }),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Container(
                  width: 368,
                  height: 71,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFFA0D7C8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '5:30 am',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF584A4A),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          'Do the dishes',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF584A4A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 368,
                  height: 71,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFFA0D7C8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '6:00 am',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF584A4A),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          'Run with family',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF584A4A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 368,
                  height: 71,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFFA0D7C8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '8:00 am',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF584A4A),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          'Take a bath',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF584A4A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 368,
                  height: 71,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFFA0D7C8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '1:00 pm',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF584A4A),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          'Meet with friend',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF584A4A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 368,
                  height: 71,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFFA0D7C8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '2:45 pm',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF584A4A),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          'Pray',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF584A4A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
