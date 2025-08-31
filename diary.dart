import 'package:flutter/material.dart';

class DiaryEntry {
  final String title;
  final String text;
  final DateTime date;

  DiaryEntry({required this.title, required this.text, required this.date});
}

void main() {
  runApp(const MyDiaryApp());
}

class MyDiaryApp extends StatelessWidget {
  const MyDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Diary",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DiaryPage(),
    );
  }
}

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  DateTime selectedMonth = DateTime.now();
  DateTime? selectedDay;
  List<DiaryEntry> entries = [];

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime.now(); // auto-select today
  }

  int daysInMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return nextMonth.difference(firstDay).inDays;
  }

  String monthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    int daysCount = daysInMonth(selectedMonth);
    int firstWeekday = DateTime(selectedMonth.year, selectedMonth.month, 1).weekday;

    List<TableRow> calendarRows = [];
    calendarRows.add(
      const TableRow(
        children: [
          _WeekdayBox("Mon"),
          _WeekdayBox("Tue"),
          _WeekdayBox("Wed"),
          _WeekdayBox("Thu"),
          _WeekdayBox("Fri"),
          _WeekdayBox("Sat"),
          _WeekdayBox("Sun"),
        ],
      ),
    );

    int totalCells = daysCount + (firstWeekday - 1);
    int rowCount = (totalCells / 7).ceil();
    int dayNum = 1;

    for (int row = 0; row < rowCount; row++) {
      List<Widget> cells = [];
      for (int col = 0; col < 7; col++) {
        int cellIndex = row * 7 + col;
        if (cellIndex < firstWeekday - 1 || dayNum > daysCount) {
          cells.add(Container());
        } else {
          DateTime thisDay = DateTime(selectedMonth.year, selectedMonth.month, dayNum);
          bool isSelected = selectedDay != null &&
              selectedDay!.year == thisDay.year &&
              selectedDay!.month == thisDay.month &&
              selectedDay!.day == thisDay.day;

          cells.add(
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedDay = thisDay;
                });
              },
              child: Container(
                margin: const EdgeInsets.all(2),
                height: 40,
                color: Colors.white,
                child: Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "$dayNum",
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          dayNum++;
        }
      }
      calendarRows.add(TableRow(children: cells));
    }

    List<DiaryEntry> filteredEntries = entries.where((entry) =>
        entry.date.year == selectedDay?.year &&
        entry.date.month == selectedDay?.month &&
        entry.date.day == selectedDay?.day).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Diary"),
        backgroundColor: Colors.black.withOpacity(0.6),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/DIARY2.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Container(
              color: Colors.blue,
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
                        selectedDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
                      });
                    },
                  ),
                  Text(
                    "${monthName(selectedMonth.month)} ${selectedMonth.year}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
                        selectedDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
                      });
                    },
                  ),
                ],
              ),
            ),
            Table(
              border: TableBorder.all(color: Colors.transparent),
              children: calendarRows,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.black, size: 30),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WriteDiaryScreen(selectedDay: selectedDay ?? DateTime.now()),
                    ),
                  );
                  if (result != null && result is DiaryEntry) {
                    setState(() => entries.insert(0, result));
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Entries",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredEntries.length,
                itemBuilder: (context, index) {
                  final entry = filteredEntries[index];
                  return Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${entry.date.day} ${monthName(entry.date.month)} ${entry.date.year}",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdayBox extends StatelessWidget {
  final String label;
  const _WeekdayBox(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      color: Colors.grey[300],
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class WriteDiaryScreen extends StatefulWidget {
  final DateTime selectedDay;
  const WriteDiaryScreen({super.key, required this.selectedDay});

  @override
  State<WriteDiaryScreen> createState() => _WriteDiaryScreenState();
}

class _WriteDiaryScreenState extends State<WriteDiaryScreen> {
  final titleController = TextEditingController();
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Write Entry")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Title",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Write your story...",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && textController.text.isNotEmpty) {
                  Navigator.pop(
                    context,
                    DiaryEntry(
                      title: titleController.text,
                      text: textController.text,
                      date: widget.selectedDay,
                    ),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
