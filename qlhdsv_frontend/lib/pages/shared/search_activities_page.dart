import 'package:flutter/material.dart';
import '../../services/activity_service.dart';

class SearchActivitiesPage extends StatefulWidget {
  const SearchActivitiesPage({super.key});

  @override
  State<SearchActivitiesPage> createState() => _SearchActivitiesPageState();
}

class _SearchActivitiesPageState extends State<SearchActivitiesPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> results = [];
  bool searching = false;

  Future<void> _search() async {
    final keyword = _searchCtrl.text.trim();
    if (keyword.isEmpty) return;
    setState(() => searching = true);

    // Gọi API search backend (nếu có) hoặc lấy tất cả rồi lọc
    final data = await ActivityService.getActivities(); // lấy toàn bộ
    final filtered = data.where((a) {
      final title = (a["title"] ?? "").toLowerCase();
      final loc = (a["location"] ?? "").toLowerCase();
      return title.contains(keyword.toLowerCase()) ||
          loc.contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      results = filtered;
      searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tìm kiếm hoạt động"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: "Nhập tên hoặc địa điểm hoạt động...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => results.clear());
                  },
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 15),
            searching
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: results.isEmpty
                        ? const Center(
                            child: Text(
                              "Chưa có kết quả tìm kiếm.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (context, i) {
                              final a = results[i];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 4),
                                child: ListTile(
                                  leading: const Icon(Icons.event_note,
                                      color: Colors.blueAccent),
                                  title: Text(a["title"] ?? ""),
                                  subtitle: Text(
                                      "Địa điểm: ${a["location"] ?? "-"}\nThời gian: ${a["start_at"] ?? "-"}"),
                                  onTap: () {
                                    // TODO: có thể chuyển sang chi tiết (tùy role)
                                  },
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
