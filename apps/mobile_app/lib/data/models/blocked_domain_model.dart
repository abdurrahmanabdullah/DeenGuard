import 'package:equatable/equatable.dart';

class BlockedDomain extends Equatable {
  final String id;
  final String domain;
  final String category;
  final DateTime createdAt;
  final bool isActive;

  const BlockedDomain({
    required this.id,
    required this.domain,
    required this.category,
    required this.createdAt,
    this.isActive = true,
  });

  factory BlockedDomain.fromJson(Map<String, dynamic> json) {
    return BlockedDomain(
      id: json['id'] as String,
      domain: json['domain'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'domain': domain,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [id, domain, category, createdAt, isActive];
}

class BlockedApp extends Equatable {
  final String id;
  final String packageName;
  final String appName;
  final String category;
  final DateTime createdAt;
  final bool isActive;

  const BlockedApp({
    required this.id,
    required this.packageName,
    required this.appName,
    required this.category,
    required this.createdAt,
    this.isActive = true,
  });

  factory BlockedApp.fromJson(Map<String, dynamic> json) {
    return BlockedApp(
      id: json['id'] as String,
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, packageName, appName, category, createdAt, isActive];
}
