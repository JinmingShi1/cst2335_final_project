import 'package:flutter/material.dart';
import '../dao/flight_dao.dart';
import '../Entities/flight_entity.dart';
import '../localization/AppLocalizations.dart';

class FlightDetailPage extends StatefulWidget {
  final Flight flight;
  final FlightDao dao;

  const FlightDetailPage({
    super.key,
    required this.flight,
    required this.dao,
  });

  @override
  State<FlightDetailPage> createState() => _FlightDetailPageState();
}

class _FlightDetailPageState extends State<FlightDetailPage> {
  // 声明 AppLocalizations 和表单 GlobalKey
  late AppLocalizations t;
  final _formKey = GlobalKey<FormState>();

  // 为每个字段声明 TextEditingController
  late TextEditingController departureCityCtrl;
  late TextEditingController destinationCityCtrl;
  late TextEditingController departureTimeCtrl;
  late TextEditingController arrivalTimeCtrl;

  @override
  void initState() {
    super.initState();
    // 用传入的 flight 数据初始化 controllers
    departureCityCtrl = TextEditingController(text: widget.flight.departureCity);
    destinationCityCtrl = TextEditingController(text: widget.flight.destinationCity);
    departureTimeCtrl = TextEditingController(text: widget.flight.departureTime);
    arrivalTimeCtrl = TextEditingController(text: widget.flight.arrivalTime);
  }

  @override
  void dispose() {
    // 清理 controllers 以释放资源
    departureCityCtrl.dispose();
    destinationCityCtrl.dispose();
    departureTimeCtrl.dispose();
    arrivalTimeCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初始化 AppLocalizations
    t = AppLocalizations.of(context)!;
  }

  // 更新航班信息的处理函数
  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final updatedFlight = Flight(
        id: widget.flight.id,
        departureCity: departureCityCtrl.text,
        destinationCity: destinationCityCtrl.text,
        departureTime: departureTimeCtrl.text,
        arrivalTime: arrivalTimeCtrl.text,
      );

      await widget.dao.updateFlight(updatedFlight);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.translate("flightListFlightUpdated")))
        );
        // 返回 true 来通知列表页刷新
        Navigator.pop(context, true);
      }
    }
  }

  // 删除航班信息的处理函数
  Future<void> _handleDelete() async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.translate("Delete")),
        content: Text("${t.translate("flightListConfirmDelete")} ${widget.flight.departureCity}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t.translate("Cancel"))
          ),
          ElevatedButton(
            onPressed: () async {
              await widget.dao.deleteFlight(widget.flight);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.translate("flightListFlightDeleted")))
                );
                Navigator.pop(dialogContext); // 关闭对话框
                Navigator.pop(context, true); // 返回 true 通知列表页刷新
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(t.translate("Delete")),
          ),
        ],
      ),
    );
  }

  // 一个辅助函数来构建带样式的 TextFormField
  Widget _buildStyledTextFormField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty'; // 可以替换成国际化文本
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${t.translate("Edit")}: ${widget.flight.departureCity}"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _handleDelete,
            tooltip: t.translate("Delete"),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStyledTextFormField(controller: departureCityCtrl, label: t.translate("flightListDepartureCity")),
                _buildStyledTextFormField(controller: destinationCityCtrl, label: t.translate("flightListDestinationCity")),
                _buildStyledTextFormField(controller: departureTimeCtrl, label: t.translate("flightListDepartureTime")),
                _buildStyledTextFormField(controller: arrivalTimeCtrl, label: t.translate("flightListArrivalTime")),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(t.translate("Update")),
                  onPressed: _handleUpdate,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}