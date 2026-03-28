// lib/lib/constants.dart
import 'package:flutter/material.dart';
import 'package:justscroll/theme/colors.dart';

class SourceInfo {
  final String label;
  final Color bgColor;
  final Color textColor;
  const SourceInfo({required this.label, required this.bgColor, required this.textColor});
}

class StatusInfo {
  final String label;
  final Color bgColor;
  final Color textColor;
  const StatusInfo({required this.label, required this.bgColor, required this.textColor});
}

final Map<String, SourceInfo> kSources = {
  'mangadex': SourceInfo(label: 'MangaDex', bgColor: AppColors.orange500.withOpacity(0.1), textColor: AppColors.orange500),
  'mal': SourceInfo(label: 'MyAnimeList', bgColor: AppColors.blue500.withOpacity(0.1), textColor: AppColors.blue500),
  'comicvine': SourceInfo(label: 'ComicVine', bgColor: AppColors.emerald500.withOpacity(0.1), textColor: AppColors.emerald500),
};

final Map<String, StatusInfo> kStatusMap = {
  'ongoing': StatusInfo(label: 'Ongoing', bgColor: AppColors.emerald500.withOpacity(0.1), textColor: AppColors.emerald500),
  'completed': StatusInfo(label: 'Completed', bgColor: AppColors.blue500.withOpacity(0.1), textColor: AppColors.blue500),
  'hiatus': StatusInfo(label: 'Hiatus', bgColor: AppColors.amber500.withOpacity(0.1), textColor: AppColors.amber500),
  'cancelled': StatusInfo(label: 'Cancelled', bgColor: AppColors.red500.withOpacity(0.1), textColor: AppColors.red500),
  'Publishing': StatusInfo(label: 'Ongoing', bgColor: AppColors.emerald500.withOpacity(0.1), textColor: AppColors.emerald500),
  'Finished': StatusInfo(label: 'Completed', bgColor: AppColors.blue500.withOpacity(0.1), textColor: AppColors.blue500),
  'On Hiatus': StatusInfo(label: 'Hiatus', bgColor: AppColors.amber500.withOpacity(0.1), textColor: AppColors.amber500),
};

const List<Map<String, String>> kGenres = [
  {'key': 'all', 'label': 'All'},
  {'key': 'action', 'label': 'Action'},
  {'key': 'adventure', 'label': 'Adventure'},
  {'key': 'comedy', 'label': 'Comedy'},
  {'key': 'drama', 'label': 'Drama'},
  {'key': 'fantasy', 'label': 'Fantasy'},
  {'key': 'horror', 'label': 'Horror'},
  {'key': 'mystery', 'label': 'Mystery'},
  {'key': 'romance', 'label': 'Romance'},
  {'key': 'sci-fi', 'label': 'Sci-Fi'},
  {'key': 'slice-of-life', 'label': 'Slice of Life'},
  {'key': 'sports', 'label': 'Sports'},
  {'key': 'supernatural', 'label': 'Supernatural'},
  {'key': 'thriller', 'label': 'Thriller'},
  {'key': 'isekai', 'label': 'Isekai'},
  {'key': 'mecha', 'label': 'Mecha'},
  {'key': 'psychological', 'label': 'Psychological'},
  {'key': 'shounen', 'label': 'Shounen'},
  {'key': 'shoujo', 'label': 'Shoujo'},
  {'key': 'seinen', 'label': 'Seinen'},
  {'key': 'josei', 'label': 'Josei'},
  {'key': 'martial-arts', 'label': 'Martial Arts'},
  {'key': 'historical', 'label': 'Historical'},
  {'key': 'music', 'label': 'Music'},
  {'key': 'school', 'label': 'School Life'},
];