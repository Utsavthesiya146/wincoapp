class VisitorItem {
  final String id;
  final String visitorName;
  final String company;
  final String phone;
  final String visitedDate;
  final String addedBy;
  final String status;

  const VisitorItem({
    required this.id,
    required this.visitorName,
    required this.company,
    required this.phone,
    required this.visitedDate,
    required this.addedBy,
    required this.status,
  });

  factory VisitorItem.fromJson(Map<String, dynamic> json) {
    return VisitorItem(
      id: json['id']?.toString() ?? '',
      visitorName: json['visitor_name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      visitedDate: json['visited_date']?.toString() ?? '',
      addedBy: json['added_by']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Visited',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitor_name': visitorName,
      'company': company,
      'phone': phone,
      'visited_date': visitedDate,
      'added_by': addedBy,
      'status': status,
    };
  }
}

class VisitorSubmissionPayload {
  final String visitorName;
  final String company;
  final String email;
  final String phone;
  final String dateVisited;

  const VisitorSubmissionPayload({
    required this.visitorName,
    required this.company,
    required this.email,
    required this.phone,
    required this.dateVisited,
  });

  Map<String, dynamic> toFormData() {
    return {
      'visitor_name': visitorName,
      'company': company,
      'email': email,
      'phone': phone,
      'date_visited': dateVisited,
    };
  }
}

class VisitorsPageData {
  final List<VisitorItem> visitors;
  final int totalVisitors;

  const VisitorsPageData({
    required this.visitors,
    required this.totalVisitors,
  });

  factory VisitorsPageData.baseline() {
    return const VisitorsPageData(
      visitors: [],
      totalVisitors: 0,
    );
  }

  factory VisitorsPageData.fromHtml(String html) {
    final list = <VisitorItem>[];
    final rowMatches = RegExp(r'<tr[^>]*>(.*?)</tr>', dotAll: true, caseSensitive: false).allMatches(html);

    for (final rm in rowMatches) {
      final row = rm.group(1)!;
      final tds = RegExp(r'<td[^>]*>(.*?)</td>', dotAll: true, caseSensitive: false).allMatches(row).toList();
      if (tds.length >= 7) {
        final id = tds[0].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        if (int.tryParse(id) == null) continue;

        final visitor = tds[1].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final company = tds[2].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final phone = tds[3].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final visitedDate = tds[4].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final addedBy = tds[5].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final status = tds[6].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();

        list.add(VisitorItem(
          id: id,
          visitorName: visitor,
          company: company,
          phone: phone,
          visitedDate: visitedDate,
          addedBy: addedBy,
          status: status.isNotEmpty ? status : 'Visited',
        ));
      }
    }

    return VisitorsPageData(
      visitors: list,
      totalVisitors: list.length,
    );
  }
}

