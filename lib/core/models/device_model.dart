class DeviceModel {
  final int id;
  final String name;
  final String status;
  final String topic;

  DeviceModel({
    required this.id,
    required this.name,
    required this.status,
    required this.topic,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      topic: json['topic'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'topic': topic,
    };
  }

  bool get isOn => status.toUpperCase() == 'ON';
}
