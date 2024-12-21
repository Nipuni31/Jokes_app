import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'joke_model.dart';

class JokeService {
  final String _baseUrl = 'https://v2.jokeapi.dev/joke';
  final Dio _dio = Dio();
  static const String _cacheKey = 'cached_jokes';
  static const String _cacheDateKey = 'jokes_cache_date';

  Future<List<Joke>> fetchJokes() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/Programming',
        queryParameters: {
          'amount': '5',
          'type': 'single',
          'blacklistFlags': ['nsfw', 'religious', 'political', 'racist', 'sexist', 'explicit'].join(','),
        },
      );

      if (response.statusCode == 200) {
        final jokeResponse = JokeResponse.fromJson(response.data as Map<String, dynamic>);
        if (!jokeResponse.error) {
          await _cacheJokes(jokeResponse.jokes);
          return jokeResponse.jokes;
        }
      }
      return await _getCachedJokes();
    } on DioException catch (e) {
      print('Network error: $e');
      return await _getCachedJokes();
    } catch (e) {
      print('Error fetching jokes: $e');
      return await _getCachedJokes();
    }
  }

  Future<void> _cacheJokes(List<Joke> jokes) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final jokesJson = jokes.map((joke) => joke.toJson()).toList();
      await prefs.setString(_cacheKey, json.encode(jokesJson));

      await prefs.setString(_cacheDateKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching jokes: $e');
    }
  }

  Future<List<Joke>> _getCachedJokes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJokesString = prefs.getString(_cacheKey);

      if (cachedJokesString != null) {
        final List<dynamic> decodedJokes = json.decode(cachedJokesString);
        return decodedJokes
            .map((jokeJson) => Joke.fromJson(jokeJson as Map<String, dynamic>))
            .toList();
      }

      return [
        Joke(
          id: -1,
          text: 'No jokes available offline. Please check your internet connection.',
        ),
      ];
    } catch (e) {
      return [
        Joke(
          id: -1,
          text: 'Error loading jokes: $e',
        ),
      ];
    }
  }

  Future<bool> hasCachedJokes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_cacheKey);
  }

  Future<String?> getLastCacheDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cacheDateKey);
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheDateKey);
  }
}