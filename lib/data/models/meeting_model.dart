class MeetingModel {
  final String id;
  final String chapterId;
  final String chapterName;
  final String title;
  final DateTime dateTime;
  final String venue;
  final String address;
  final String agenda;
  final String keySpeaker;
  final bool isUpcoming;
  final bool isVisitorAllowed;

  const MeetingModel({
    required this.id,
    required this.chapterId,
    required this.chapterName,
    required this.title,
    required this.dateTime,
    required this.venue,
    required this.address,
    required this.agenda,
    required this.keySpeaker,
    required this.isUpcoming,
    required this.isVisitorAllowed,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id']?.toString() ?? '',
      chapterId: json['chapter_id']?.toString() ?? '',
      chapterName: json['chapter_name'] ?? 'WINCO Chapter',
      title: json['title'] ?? 'Fortnightly Infrastructure Business Meet',
      dateTime: json['date_time'] != null
          ? DateTime.tryParse(json['date_time'].toString()) ?? DateTime.now().add(const Duration(days: 3))
          : DateTime.now().add(const Duration(days: 3)),
      venue: json['venue'] ?? 'Business Convention Centre',
      address: json['address'] ?? 'MG Road, Bengaluru',
      agenda: json['agenda'] ?? 'Project Sharing, 1-to-1 Conclaves & Business Referral Exchange',
      keySpeaker: json['key_speaker'] ?? 'Chief Structural Consultant',
      isUpcoming: json['is_upcoming'] ?? true,
      isVisitorAllowed: json['is_visitor_allowed'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'chapter_name': chapterName,
      'title': title,
      'date_time': dateTime.toIso8601String(),
      'venue': venue,
      'address': address,
      'agenda': agenda,
      'key_speaker': keySpeaker,
      'is_upcoming': isUpcoming,
      'is_visitor_allowed': isVisitorAllowed,
    };
  }
}

class ChapterMeetingItem {
  final String id;
  final String dateTime;
  final String eventTitle;
  final String chapter;
  final String location;
  final String mode;
  final String status;
  final String meetingLink;

  const ChapterMeetingItem({
    required this.id,
    required this.dateTime,
    required this.eventTitle,
    required this.chapter,
    required this.location,
    required this.mode,
    required this.status,
    required this.meetingLink,
  });

  factory ChapterMeetingItem.fromJson(Map<String, dynamic> json) {
    return ChapterMeetingItem(
      id: json['id']?.toString() ?? '',
      dateTime: json['date_time']?.toString() ?? '',
      eventTitle: json['event_title']?.toString() ?? '',
      chapter: json['chapter']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      mode: json['mode']?.toString() ?? 'Offline',
      status: json['status']?.toString() ?? 'Scheduled',
      meetingLink: json['meeting_link']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_time': dateTime,
      'event_title': eventTitle,
      'chapter': chapter,
      'location': location,
      'mode': mode,
      'status': status,
      'meeting_link': meetingLink,
    };
  }
}

class AttendanceRecord {
  final String event;
  final String chapter;
  final String date;
  final String status;

  const AttendanceRecord({
    required this.event,
    required this.chapter,
    required this.date,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      event: json['event']?.toString() ?? '',
      chapter: json['chapter']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Present',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'chapter': chapter,
      'date': date,
      'status': status,
    };
  }
}

class MeetingSubmissionPayload {
  final String chapterCode;
  final String date;
  final String time;
  final String title;
  final String mode;
  final String location;
  final String venue;
  final String description;

  const MeetingSubmissionPayload({
    required this.chapterCode,
    required this.date,
    required this.time,
    required this.title,
    this.mode = 'Offline',
    this.location = '',
    this.venue = '',
    this.description = '',
  });

  Map<String, dynamic> toFormData() {
    return {
      'chapter_code': chapterCode,
      'date': date,
      'time': time,
      'title': title,
      'mode': mode,
      'location': location,
      'venue': venue,
      'description': description,
    };
  }
}

class MeetingsPageData {
  final List<ChapterMeetingItem> meetings;
  final List<AttendanceRecord> attendance;

  const MeetingsPageData({
    required this.meetings,
    required this.attendance,
  });

  factory MeetingsPageData.baseline() {
    return const MeetingsPageData(
      meetings: [
        ChapterMeetingItem(
          id: '1',
          dateTime: '24 Jul 2026 09:45 AM',
          eventTitle: 'Project Collaboration Kumbalgodu',
          chapter: 'Winco - KR Puram',
          location: 'Promax Office',
          mode: 'Offline',
          status: 'Scheduled',
          meetingLink: '',
        ),
        ChapterMeetingItem(
          id: '2',
          dateTime: '10 Jul 2026 06:00 AM',
          eventTitle: 'Business meeting Jayanagar',
          chapter: 'Winco - Jayanagar',
          location: 'Jayanagar Club',
          mode: 'Offline',
          status: 'Completed',
          meetingLink: '',
        ),
      ],
      attendance: [
        AttendanceRecord(
          event: 'Project Collaboration',
          chapter: 'Winco - KR Puram',
          date: '24 Jul 2026',
          status: 'Present',
        ),
        AttendanceRecord(
          event: 'Business meeting',
          chapter: 'Winco - Jayanagar',
          date: '10 Jul 2026',
          status: 'Present',
        ),
      ],
    );
  }

  factory MeetingsPageData.fromHtml(String meetingsHtml, [String attendanceHtml = '']) {
    final meetings = <ChapterMeetingItem>[];
    final rowMatches = RegExp(r'<tr[^>]*>(.*?)</tr>', dotAll: true, caseSensitive: false).allMatches(meetingsHtml);

    for (final rm in rowMatches) {
      final row = rm.group(1)!;
      final tdMatches = RegExp(r'<td[^>]*>(.*?)</td>', dotAll: true, caseSensitive: false).allMatches(row).toList();
      if (tdMatches.length >= 7) {
        final id = tdMatches[0].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        if (int.tryParse(id) == null) continue;

        final dateTime = tdMatches[1].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final event = tdMatches[2].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final chapter = tdMatches[3].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final location = tdMatches[4].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final mode = tdMatches[5].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
        final status = tdMatches[6].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();

        meetings.add(ChapterMeetingItem(
          id: id,
          dateTime: dateTime,
          eventTitle: event,
          chapter: chapter,
          location: location.isNotEmpty ? location : 'Chapter Venue',
          mode: mode.isNotEmpty ? mode : 'Offline',
          status: status.isNotEmpty ? status : 'Scheduled',
          meetingLink: '',
        ));
      }
    }

    final attendance = <AttendanceRecord>[];
    if (attendanceHtml.isNotEmpty) {
      final attRows = RegExp(r'<tr[^>]*>(.*?)</tr>', dotAll: true, caseSensitive: false).allMatches(attendanceHtml);
      for (final arm in attRows) {
        final row = arm.group(1)!;
        final tds = RegExp(r'<td[^>]*>(.*?)</td>', dotAll: true, caseSensitive: false).allMatches(row).toList();
        if (tds.length >= 4) {
          final event = tds[0].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
          final chapter = tds[1].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
          final date = tds[2].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
          final status = tds[3].group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();

          if (event.isNotEmpty && !event.toLowerCase().contains('event')) {
            attendance.add(AttendanceRecord(
              event: event,
              chapter: chapter,
              date: date,
              status: status,
            ));
          }
        }
      }
    }

    return MeetingsPageData(
      meetings: meetings,
      attendance: attendance,
    );
  }
}
