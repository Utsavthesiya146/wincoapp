import 'package:flutter/material.dart';

enum F2fStatus {
  scheduled('scheduled', 'Scheduled'),
  completed('completed', 'Completed'),
  rescheduled('Re-scheduled', 'Re-scheduled'),
  cancelled('cancelled', 'Cancelled');

  final String code;
  final String label;

  const F2fStatus(this.code, this.label);

  static F2fStatus fromString(String val) {
    final lower = val.trim().toLowerCase();
    if (lower.contains('sched') && !lower.contains('re')) {
      return F2fStatus.scheduled;
    }
    if (lower.contains('comp')) {
      return F2fStatus.completed;
    }
    if (lower.contains('re-sched') || lower.contains('resched')) {
      return F2fStatus.rescheduled;
    }
    if (lower.contains('cancel')) {
      return F2fStatus.cancelled;
    }
    return F2fStatus.scheduled;
  }

  Color get color {
    switch (this) {
      case F2fStatus.scheduled:
        return const Color(0xFF0D6EFD); // Blue
      case F2fStatus.completed:
        return const Color(0xFF146C43); // Emerald Green
      case F2fStatus.rescheduled:
        return const Color(0xFFF28C00); // Amber/Orange
      case F2fStatus.cancelled:
        return const Color(0xFF842029); // Dark Red
    }
  }

  Color get backgroundColor {
    switch (this) {
      case F2fStatus.scheduled:
        return const Color(0xFFE3F2FD);
      case F2fStatus.completed:
        return const Color(0xFFD1E7DD);
      case F2fStatus.rescheduled:
        return const Color(0xFFFFF3CD);
      case F2fStatus.cancelled:
        return const Color(0xFFF8D7DA);
    }
  }

  IconData get icon {
    switch (this) {
      case F2fStatus.scheduled:
        return Icons.event_available_outlined;
      case F2fStatus.completed:
        return Icons.check_circle_outline;
      case F2fStatus.rescheduled:
        return Icons.update_outlined;
      case F2fStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}

class F2fMemberOption {
  final String userCode;
  final String name;
  final String chapter;

  const F2fMemberOption({
    required this.userCode,
    required this.name,
    required this.chapter,
  });

  String get displayText => chapter.isNotEmpty ? '$name ($chapter)' : name;

  factory F2fMemberOption.fromJson(Map<String, dynamic> json) {
    return F2fMemberOption(
      userCode: json['user_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      chapter: json['chapter']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_code': userCode,
      'name': name,
      'chapter': chapter,
    };
  }
}

class F2fMeetingItem {
  final String id;
  final String f2fCode;
  final String fromMemberName;
  final String fromMemberEmail;
  final String? fromMemberAvatar;
  final String toMemberName;
  final String toMemberEmail;
  final String? toMemberAvatar;
  final String location;
  final String meetingDate;
  final F2fStatus status;
  final String createdDate;
  final String summary;

  const F2fMeetingItem({
    required this.id,
    required this.f2fCode,
    required this.fromMemberName,
    required this.fromMemberEmail,
    this.fromMemberAvatar,
    required this.toMemberName,
    required this.toMemberEmail,
    this.toMemberAvatar,
    required this.location,
    required this.meetingDate,
    required this.status,
    required this.createdDate,
    required this.summary,
  });

  factory F2fMeetingItem.fromJson(Map<String, dynamic> json) {
    return F2fMeetingItem(
      id: json['id']?.toString() ?? '',
      f2fCode: json['f2f_code']?.toString() ?? '',
      fromMemberName: json['from_member_name']?.toString() ?? '',
      fromMemberEmail: json['from_member_email']?.toString() ?? '',
      fromMemberAvatar: json['from_member_avatar']?.toString(),
      toMemberName: json['to_member_name']?.toString() ?? '',
      toMemberEmail: json['to_member_email']?.toString() ?? '',
      toMemberAvatar: json['to_member_avatar']?.toString(),
      location: json['location']?.toString() ?? '',
      meetingDate: json['meeting_date']?.toString() ?? '',
      status: F2fStatus.fromString(json['status']?.toString() ?? 'scheduled'),
      createdDate: json['created_date']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'f2f_code': f2fCode,
      'from_member_name': fromMemberName,
      'from_member_email': fromMemberEmail,
      'from_member_avatar': fromMemberAvatar,
      'to_member_name': toMemberName,
      'to_member_email': toMemberEmail,
      'to_member_avatar': toMemberAvatar,
      'location': location,
      'meeting_date': meetingDate,
      'status': status.code,
      'created_date': createdDate,
      'summary': summary,
    };
  }
}

class F2fSummary {
  final int totalMeetings;
  final int scheduledCount;
  final int completedCount;
  final int cancelledCount;

  const F2fSummary({
    required this.totalMeetings,
    required this.scheduledCount,
    required this.completedCount,
    required this.cancelledCount,
  });

  factory F2fSummary.baseline() {
    return const F2fSummary(
      totalMeetings: 1,
      scheduledCount: 1,
      completedCount: 0,
      cancelledCount: 0,
    );
  }
}

class F2fSubmissionPayload {
  final String toUser;
  final String date;
  final String location;
  final String summary;

  const F2fSubmissionPayload({
    required this.toUser,
    required this.date,
    required this.location,
    required this.summary,
  });

  Map<String, dynamic> toFormData() {
    return {
      'to_user': toUser,
      'date': date,
      'location': location,
      'summary': summary,
    };
  }
}

class F2fStatusUpdatePayload {
  final String f2fCode;
  final String status;
  final String summary;

  const F2fStatusUpdatePayload({
    required this.f2fCode,
    required this.status,
    required this.summary,
  });

  Map<String, dynamic> toFormData() {
    return {
      'f2f_code': f2fCode,
      'status': status,
      'summary': summary,
    };
  }
}

class F2fPageData {
  final F2fSummary summary;
  final List<F2fMeetingItem> meetings;
  final List<F2fMemberOption> members;

  const F2fPageData({
    required this.summary,
    required this.meetings,
    required this.members,
  });

  factory F2fPageData.baseline() {
    return const F2fPageData(
      summary: F2fSummary(
        totalMeetings: 1,
        scheduledCount: 1,
        completedCount: 0,
        cancelledCount: 0,
      ),
      meetings: [
        F2fMeetingItem(
          id: '1',
          f2fCode: 'F2F0030',
          fromMemberName: 'Harri Kumar',
          fromMemberEmail: 'harri@jobhunterr.com',
          fromMemberAvatar: 'https://wincoconnect.com/uploads/profile/1776448893_87ba65669f2cb1799190.jpeg',
          toMemberName: 'Manjunath D',
          toMemberEmail: 'manjunath@vankarinteriors.com',
          toMemberAvatar: 'https://wincoconnect.com/uploads/profile/1786029115_76bbf8d76e43805c5217.jpeg',
          location: 'Vankar Interiors',
          meetingDate: '17 May 2026',
          status: F2fStatus.scheduled,
          createdDate: '16 Oct 2026, 15:29',
          summary: 'Spoke about business and I got quality referral',
        ),
      ],
      members: [
        F2fMemberOption(
          userCode: 'USR00007',
          name: 'Santhosha H R',
          chapter: 'Winco - Jayanagar',
        ),
        F2fMemberOption(
          userCode: 'USR00002',
          name: 'SHASHANK M',
          chapter: 'Winco - JP Nagar',
        ),
        F2fMemberOption(
          userCode: 'USR00008',
          name: 'Vinya Shetty',
          chapter: 'Winco - HSR Layout',
        ),
      ],
    );
  }

  factory F2fPageData.fromHtml(String html) {
    // 1. Extract member options from #addNewf2fData select
    final members = <F2fMemberOption>[];
    final selectMatch = RegExp(r'<select name="to_user"[^>]*>(.*?)</select>', dotAll: true, caseSensitive: false).firstMatch(html);
    if (selectMatch != null) {
      final selectContent = selectMatch.group(1)!;
      final optMatches = RegExp(r'<option value="(USR\d+)"[^>]*>\s*(.*?)\s*</option>', dotAll: true, caseSensitive: false).allMatches(selectContent);
      for (final om in optMatches) {
        final code = om.group(1)!.trim();
        final rawLabel = om.group(2)!.replaceAll(RegExp(r'\s+'), ' ').trim();
        // Parse name and chapter if present: "Harri Kumar (Winco - Jayanagar )"
        String name = rawLabel;
        String chapter = '';
        final parenMatch = RegExp(r'^(.*?)\s*\((.*?)\)$').firstMatch(rawLabel);
        if (parenMatch != null) {
          name = parenMatch.group(1)!.trim();
          chapter = parenMatch.group(2)!.trim();
        }
        members.add(F2fMemberOption(userCode: code, name: name, chapter: chapter));
      }
    }

    // 2. Extract meeting rows from table
    final meetings = <F2fMeetingItem>[];
    final rowMatches = RegExp(r'<tr[^>]*>(.*?)</tr>', dotAll: true, caseSensitive: false).allMatches(html);

    for (final rm in rowMatches) {
      final rowContent = rm.group(1)!;
      final tdMatches = RegExp(r'<td[^>]*>(.*?)</td>', dotAll: true, caseSensitive: false).allMatches(rowContent).toList();
      if (tdMatches.length >= 7) {
        final id = tdMatches[0].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        // If first column is not numeric or not an id, skip header rows
        if (int.tryParse(id) == null && !id.startsWith('F2F')) {
          continue;
        }

        final fromHtml = tdMatches[1].group(1)!;
        final toHtml = tdMatches[2].group(1)!;
        final location = tdMatches[3].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final meetingDate = tdMatches[4].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final statusRaw = tdMatches[5].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final createdDate = tdMatches[6].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final actionHtml = tdMatches.length > 7 ? tdMatches[7].group(1)! : '';

        // Parse From Member
        final fromNameMatch = RegExp(r'<div class="name">(.*?)</div>', dotAll: true).firstMatch(fromHtml);
        final fromName = fromNameMatch != null ? fromNameMatch.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim() : 'WINCO Member';
        final fromEmailMatch = RegExp(r'<small>(.*?)</small>', dotAll: true).firstMatch(fromHtml);
        final fromEmail = fromEmailMatch != null ? fromEmailMatch.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim() : '';
        final fromAvatarMatch = RegExp(r'src="([^"]+)"').firstMatch(fromHtml);
        final fromAvatar = fromAvatarMatch?.group(1)?.trim();

        // Parse To Member
        final toNameMatch = RegExp(r'<div class="name">(.*?)</div>', dotAll: true).firstMatch(toHtml);
        final toName = toNameMatch != null ? toNameMatch.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim() : 'WINCO Member';
        final toEmailMatch = RegExp(r'<small>(.*?)</small>', dotAll: true).firstMatch(toHtml);
        final toEmail = toEmailMatch != null ? toEmailMatch.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim() : '';
        final toAvatarMatch = RegExp(r'src="([^"]+)"').firstMatch(toHtml);
        final toAvatar = toAvatarMatch?.group(1)?.trim();

        // Parse F2F code
        final codeMatch = RegExp(r"edit_f2f\('([^']+)'\)").firstMatch(actionHtml);
        final f2fCode = codeMatch?.group(1) ?? 'F2F-$id';

        final status = F2fStatus.fromString(statusRaw);

        meetings.add(F2fMeetingItem(
          id: id,
          f2fCode: f2fCode,
          fromMemberName: fromName,
          fromMemberEmail: fromEmail,
          fromMemberAvatar: fromAvatar,
          toMemberName: toName,
          toMemberEmail: toEmail,
          toMemberAvatar: toAvatar,
          location: location,
          meetingDate: meetingDate,
          status: status,
          createdDate: createdDate,
          summary: '',
        ));
      }
    }

    // 3. Compute Summary Counts
    int scheduled = 0;
    int completed = 0;
    int cancelled = 0;

    for (final m in meetings) {
      switch (m.status) {
        case F2fStatus.scheduled:
        case F2fStatus.rescheduled:
          scheduled++;
          break;
        case F2fStatus.completed:
          completed++;
          break;
        case F2fStatus.cancelled:
          cancelled++;
          break;
      }
    }

    return F2fPageData(
      summary: F2fSummary(
        totalMeetings: meetings.length,
        scheduledCount: scheduled,
        completedCount: completed,
        cancelledCount: cancelled,
      ),
      meetings: meetings,
      members: members,
    );
  }
}

