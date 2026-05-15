class ActivityLog {
  final String id;
  final String action;
  final String description;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final String status; // 'success', 'failure', 'pending'
  final String? details;

  ActivityLog({
    required this.id,
    required this.action,
    required this.description,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.status,
    this.details,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      action: json['action'] as String,
      description: json['description'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      details: json['details'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'description': description,
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'details': details,
    };
  }
}
