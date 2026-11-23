import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/chapter_model.dart';
import '../models/meeting_model.dart';

abstract class ChapterRepository {
  Future<MyChapterPageData> getMyChapter();
  Future<AllChaptersPageData> getAllChapters();
  Future<MyChapterPageData> getChapterDetails(String chapterId);
  Future<List<ChapterModel>> getChapters();
  Future<ChapterModel> getChapterById(String id);
  Future<List<MeetingModel>> getUpcomingMeetings({String? chapterId});
}

final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  if (AppConfig.current.isMock) {
    return MockChapterRepository();
  } else {
    return LiveChapterRepository(apiClient);
  }
});

class LiveChapterRepository implements ChapterRepository {
  final ApiClient _apiClient;

  LiveChapterRepository(this._apiClient);

  @override
  Future<MyChapterPageData> getMyChapter() async {
    try {
      final response = await _apiClient.get(
        'https://wincoconnect.com/member/mychapter',
        options: Options(responseType: ResponseType.plain),
      );
      final html = response.data?.toString() ?? '';
      if (html.isNotEmpty && (html.contains('My Chapter') || html.contains('chapter-card-pro'))) {
        return MyChapterPageData.fromHtml(html);
      }
      throw AppException('Failed to load My Chapter data from live server.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error loading My Chapter: $e');
    }
  }

  @override
  Future<AllChaptersPageData> getAllChapters() async {
    try {
      final response = await _apiClient.get(
        'https://wincoconnect.com/member/chapter',
        options: Options(responseType: ResponseType.plain),
      );
      final html = response.data?.toString() ?? '';
      if (html.isNotEmpty && (html.contains('All Chapters') || html.contains('chapter-card-pro'))) {
        return AllChaptersPageData.fromHtml(html);
      }
      throw AppException('Failed to load All Chapters data from live server.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error loading All Chapters: $e');
    }
  }

  @override
  Future<MyChapterPageData> getChapterDetails(String chapterId) async {
    try {
      final response = await _apiClient.get(
        'https://wincoconnect.com/member/chapter/details/$chapterId',
        options: Options(responseType: ResponseType.plain),
      );
      final html = response.data?.toString() ?? '';
      if (html.isNotEmpty && html.contains('chapter-card-pro')) {
        return MyChapterPageData.fromHtml(html);
      }
      throw AppException('Failed to load chapter details for chapter $chapterId.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Network error loading chapter details: $e');
    }
  }

  @override
  Future<List<ChapterModel>> getChapters() async {
    final all = await getAllChapters();
    return all.chapters;
  }

  @override
  Future<ChapterModel> getChapterById(String id) async {
    final all = await getAllChapters();
    return all.chapters.firstWhere(
      (c) => c.id == id,
      orElse: () => throw NotFoundException('Chapter $id not found.'),
    );
  }

  @override
  Future<List<MeetingModel>> getUpcomingMeetings({String? chapterId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (chapterId != null) queryParams['chapter_id'] = chapterId;

      final response = await _apiClient.get('/meetings', queryParameters: queryParams);
      if (response.data is Map && response.data['data'] is List) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((e) => MeetingModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

class MockChapterRepository implements ChapterRepository {
  @override
  Future<MyChapterPageData> getMyChapter() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return MyChapterPageData.baseline();
  }

  @override
  Future<AllChaptersPageData> getAllChapters() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return AllChaptersPageData.baseline();
  }

  @override
  Future<MyChapterPageData> getChapterDetails(String chapterId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return MyChapterPageData.baseline();
  }

  @override
  Future<List<ChapterModel>> getChapters() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return AllChaptersPageData.baseline().chapters;
  }

  @override
  Future<ChapterModel> getChapterById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final all = AllChaptersPageData.baseline().chapters;
    return all.firstWhere(
      (c) => c.id == id,
      orElse: () => all.first,
    );
  }

  @override
  Future<List<MeetingModel>> getUpcomingMeetings({String? chapterId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      MeetingModel(
        id: 'MTG-01',
        chapterId: 'CHP0001',
        chapterName: 'Winco - Jayanagar',
        title: 'Weekly Conclave - Synergy & Business',
        dateTime: DateTime.now().add(const Duration(days: 3)),
        venue: 'The Grand Luxury Hotel',
        address: 'MG Road, Bengaluru',
        agenda: '1-to-1 Presentations, Business Slips & Guest Welcome',
        keySpeaker: 'Chief Structural Consultant',
        isUpcoming: true,
        isVisitorAllowed: true,
      ),
    ];
  }
}
