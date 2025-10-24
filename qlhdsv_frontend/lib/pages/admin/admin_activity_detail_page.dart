import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/activity_service.dart';
import '../../services/user_service.dart';

class AdminActivityDetailPage extends StatefulWidget {
  final Map<String, dynamic>? activity;
  const AdminActivityDetailPage({super.key, this.activity});

  @override
  State<AdminActivityDetailPage> createState() =>
      _AdminActivityDetailPageState();
}

class _AdminActivityDetailPageState extends State<AdminActivityDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final locCtrl = TextEditingController();
  final slotCtrl = TextEditingController();
  final pointCtrl = TextEditingController();

  DateTime? startDateTime;
  DateTime? endDateTime;
  List<dynamic> lecturers = [];
  int? selectedLecturerId;
  String? lecturerName;
  bool loading = false;

  bool get isEdit => widget.activity != null;

  @override
  void initState() {
    super.initState();
    final a = widget.activity;
    if (a != null) {
      titleCtrl.text = a["title"] ?? "";
      descCtrl.text = a["description"] ?? "";
      locCtrl.text = a["location"] ?? "";
      slotCtrl.text = a["max_slots"]?.toString() ?? "";
      pointCtrl.text = a["reward_point"]?.toString() ?? "25";
      lecturerName = a["lecturer_name"];

      try {
        if (a["start_at"] != null)
          startDateTime = DateTime.parse(a["start_at"]);
        if (a["end_at"] != null) endDateTime = DateTime.parse(a["end_at"]);
      } catch (e) {}
    } else {
      pointCtrl.text = "25";
      _loadLecturers();
    }
  }

  Future<void> _loadLecturers() async {
    try {
      lecturers = await UserService.getLecturers();
      setState(() {});
    } catch (e) {}
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isStart ? startDateTime : endDateTime) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (startDateTime == null || endDateTime == null) {
      _showMsg("Vui lòng chọn thời gian bắt đầu và kết thúc");
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
      if (selectedLecturerId != null) "lecturer_id": selectedLecturerId,
    };

    final res =
        isEdit
            ? await ActivityService.updateActivity(
              widget.activity!["id"],
              payload,
            )
            : await ActivityService.createActivity(payload);

    setState(() => loading = false);

    if (res["id"] != null || res["message"]?.contains("thành công") == true) {
      _showMsg(isEdit ? "Cập nhật thành công" : "Tạo thành công", true);
      Navigator.pop(context, true);
    } else {
      _showMsg(res["message"] ?? "Lỗi khi lưu");
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Xóa hoạt động?"),
            content: const Text("Hành động này không thể hoàn tác."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Xóa"),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    setState(() => loading = true);
    final res = await ActivityService.deleteActivity(widget.activity!["id"]);
    setState(() => loading = false);

    _showMsg(res["message"] ?? "Đã xóa");
    Navigator.pop(context, true);
  }

  void _showMsg(String msg, [bool success = false]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isEdit ? "Sửa hoạt động" : "Tạo hoạt động mới"),
        backgroundColor: Colors.redAccent,
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: loading ? null : _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Lecturer info
            if (isEdit && lecturerName != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.redAccent),
                  title: const Text("Giảng viên phụ trách"),
                  subtitle: Text(lecturerName!),
                ),
              ),

            const SizedBox(height: 16),

            // Basic info
            _field(titleCtrl, "Tên hoạt động", Icons.title, required: true),
            const SizedBox(height: 12),
            _field(descCtrl, "Mô tả", Icons.description, lines: 3),
            const SizedBox(height: 12),
            _field(locCtrl, "Địa điểm", Icons.location_on),

            const SizedBox(height: 20),
            const Text(
              " Thời gian",
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

            // Lecturer dropdown
            if (!isEdit) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedLecturerId,
                decoration: const InputDecoration(
                  labelText: "Giảng viên",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                items:
                    lecturers
                        .map(
                          (l) => DropdownMenuItem<int>(
                            value: l["id"],
                            child: Text(l["name"] ?? ""),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => selectedLecturerId = v),
                validator: (v) => v == null ? "Chọn giảng viên" : null,
              ),
            ],

            const SizedBox(height: 24),

            // Save button
            ElevatedButton.icon(
              onPressed: loading ? null : _save,
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
                      : Icon(isEdit ? Icons.save : Icons.add),
              label: Text(isEdit ? "Lưu" : "Tạo"),
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
        if (required && v!.isEmpty) return "Không được để trống";
        if (number && v!.isNotEmpty && int.tryParse(v) == null)
          return "Phải là số";
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
