import '../../core/constants/app_constants.dart';

class DashboardStatsModel {
  final int activeMembers;
  final int chaptersCount;
  final double totalBusinessValue;
  final double referralValue;
  final DateTime lastUpdated;

  const DashboardStatsModel({
    required this.activeMembers,
    required this.chaptersCount,
    required this.totalBusinessValue,
    required this.referralValue,
    required this.lastUpdated,
  });

  /// Factory with verified website baseline values
  factory DashboardStatsModel.baseline() {
    return DashboardStatsModel(
      activeMembers: AppConstants.baselineActiveMembers,
      chaptersCount: AppConstants.baselineChapters,
      totalBusinessValue: AppConstants.baselineTotalBusiness,
      referralValue: AppConstants.baselineAverageReferral,
      lastUpdated: DateTime.now(),
    );
  }

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      activeMembers: (json['active_members'] as num?)?.toInt() ?? AppConstants.baselineActiveMembers,
      chaptersCount: (json['chapters_count'] as num?)?.toInt() ?? AppConstants.baselineChapters,
      totalBusinessValue: (json['total_business_value'] as num?)?.toDouble() ?? AppConstants.baselineTotalBusiness,
      referralValue: (json['referral_value'] as num?)?.toDouble() ?? AppConstants.baselineAverageReferral,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_members': activeMembers,
      'chapters_count': chaptersCount,
      'total_business_value': totalBusinessValue,
      'referral_value': referralValue,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

