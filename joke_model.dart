class Joke {
  final String text;
  final int id;

  Joke({
    required this.text,
    required this.id,
  });

  // From JSON
  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      text: json['joke'] as String,
      id: json['id'] as int,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'joke': text,
      'id': id,
    };
  }
}

class JokeResponse {
  final bool error;
  final List<Joke> jokes;

  JokeResponse({
    required this.error,
    required this.jokes,
  });

  factory JokeResponse.fromJson(Map<String, dynamic> json) {
    return JokeResponse(
      error: json['error'] as bool,
      jokes: (json['jokes'] as List<dynamic>)
          .map((jokeJson) => Joke.fromJson(jokeJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'jokes': jokes.map((joke) => joke.toJson()).toList(),
    };
  }
}