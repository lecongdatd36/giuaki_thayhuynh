import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/activity_service.dart';

class LecturerActivityCreatePage extends StatefulWidget {
  const LecturerActivityCreatePage({super.key});

  @override
  State<LecturerActivityCreatePage> createState() =>
      _LecturerActivityCreatePageState();
}

class _LecturerActivityCreatePageState
    extends State<LecturerActivityCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;
  late TextEditingController locCtrl;
  late TextEditingController slotCtrl;
  late TextEditingController pointCtrl;

  DateTime? startDateTime;
  DateTime? endDateTime;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController();
    descCtrl = TextEditingController();
    locCtrl = TextEditingController();
    slotCtrl = TextEditingController();
    pointCtrl = TextEditingController(text: "25");
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isStart ? startDateTime : endDateTime) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        (isStart ? startDateTime : endDateTime) ?? DateTime.now(),
      ),
    );
    if (time == null) return;

    setState(() {
      final dt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      isStart ? startDateTime = dt : endDateTime = dt;
    });
  }

  String _formatDT(DateTime? dt) {
    if (dt == null) return "Chọn ngày giờ";
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  Future<void> saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    if (startDateTime == null || endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng chọn thời gian bắt đầu và kết thúc"),
        ),
      );
      return;
    }

    setState(() => loading = true);

    final payload = {
      "title": titleCtrl.text,
      "description": descCtrl.text,
      "location": locCtrl.text,
      "start_at": DateFormat('yyyy-MM-dd HH:mm').format(startDateTime!),
      "end_at": DateFormat('yyyy-MM-dd HH:mm').format(endDateTime!),
      "max_slots": int.tryParse(slotCtrl.text) ?? 0,
      "reward_point": int.tryParse(pointCtrl.text) ?? 25,
      "status": "OPEN",
    };

    final res = await ActivityService.createActivity(payload);

    setState(() => loading = false);

    if (res["id"] != null || res["message"]?.contains("thành công") == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Tạo hoạt động thành công"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Lỗi khi tạo hoạt động")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Tạo hoạt động giảng dạy"),
        backgroundColor: Colors.redAccent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(titleCtrl, "Tên hoạt động", Icons.title, required: true),
            const SizedBox(height: 12),
            _field(descCtrl, "Mô tả", Icons.description, lines: 3),
            const SizedBox(height: 12),
            _field(locCtrl, "Địa điểm", Icons.location_on),

            const SizedBox(height: 20),
            const Text(
              "Thời gian",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Date time pickers
            Row(
              children: [
                Expanded(
                  child: _dateTimeCard(
                    "Bắt đầu",
                    startDateTime,
                    () => _pickDateTime(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateTimeCard(
                    "Kết thúc",
                    endDateTime,
                    () => _pickDateTime(false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              " Thông tin khác",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _field(
                    slotCtrl,
                    "Số lượng",
                    Icons.people,
                    number: true,
                    required: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    pointCtrl,
                    "Điểm thưởng",
                    Icons.stars,
                    number: true,
                    required: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: loading ? null : saveActivity,
              icon:
                  loading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.add),
              label: const Text("Tạo hoạt động"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int lines = 1,
    bool number = false,
    bool required = false,
  }) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      maxLines: lines,
      keyboardType: number ? TextInputType.number : null,
      validator: (v) {
        if (required && (v == null || v.isEmpty)) return "Không được để trống";
        if (number && v != null && v.isNotEmpty && int.tryParse(v) == null) {
          return "Phải là số";
        }
        return null;
      },
    );
  }

  Widget _dateTimeCard(String label, DateTime? dt, VoidCallback onTap) {
    final selected = dt != null;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? Colors.redAccent : Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDT(dt),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
