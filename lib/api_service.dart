import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class QuoteApiService {

  /// Fetch a random motivational quote - GUARANTEED TO WORK
  Future<Map<String, dynamic>> getRandomQuote() async {

    // API 1: Type.fit Quotes (NO API KEY NEEDED - MOST RELIABLE)
    try {
      print('🌐 Attempting Type.fit API...');
      final response = await http.get(
        Uri.parse('https://type.fit/api/quotes'),
      ).timeout(const Duration(seconds: 8));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          // Pick a random quote from the list
          final random = Random();
          final quote = data[random.nextInt(data.length)];

          String content = quote['text'] ?? 'Stay calm. Stay productive 💙';
          String author = quote['author'] ?? 'Unknown';

          // Clean up author name (remove ", type.fit" if present)
          if (author.contains(',')) {
            author = author.split(',')[0];
          }

          print('✅ Quote received: $content');
          print('👤 Author: $author');

          return {
            'content': content,
            'author': author,
            'success': true,
          };
        }
      }
    } catch (e) {
      print('❌ Type.fit API failed: $e');
    }

    // API 2: Quotable.io (Backup)
    try {
      print('🌐 Attempting Quotable API...');
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random?maxLength=150'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Quotable API success');
        return {
          'content': data['content'] ?? 'Stay calm. Stay productive 💙',
          'author': data['author'] ?? 'Unknown',
          'success': true,
        };
      }
    } catch (e) {
      print('❌ Quotable API failed: $e');
    }

    // API 3: DummyJSON Quotes (Another reliable backup)
    try {
      print('🌐 Attempting DummyJSON API...');
      final random = Random();
      final quoteId = random.nextInt(30) + 1; // Random quote between 1-30

      final response = await http.get(
        Uri.parse('https://dummyjson.com/quotes/$quoteId'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ DummyJSON API success');
        return {
          'content': data['quote'] ?? 'Stay calm. Stay productive 💙',
          'author': data['author'] ?? 'Unknown',
          'success': true,
        };
      }
    } catch (e) {
      print('❌ DummyJSON API failed: $e');
    }

    // Fallback to curated motivational quotes (ALWAYS WORKS)
    print('📚 Using fallback quotes');
    final defaultQuotes = [
      {'content': 'The secret of getting ahead is getting started.', 'author': 'Mark Twain'},
      {'content': 'Success is not final, failure is not fatal: it is the courage to continue that counts.', 'author': 'Winston Churchill'},
      {'content': 'Believe you can and you\'re halfway there.', 'author': 'Theodore Roosevelt'},
      {'content': 'It always seems impossible until it\'s done.', 'author': 'Nelson Mandela'},
      {'content': 'Don\'t watch the clock; do what it does. Keep going.', 'author': 'Sam Levenson'},
      {'content': 'The future depends on what you do today.', 'author': 'Mahatma Gandhi'},
      {'content': 'Quality is not an act, it is a habit.', 'author': 'Aristotle'},
      {'content': 'The only way to do great work is to love what you do.', 'author': 'Steve Jobs'},
      {'content': 'Don\'t let yesterday take up too much of today.', 'author': 'Will Rogers'},
      {'content': 'You learn more from failure than from success.', 'author': 'Unknown'},
      {'content': 'It\'s not whether you get knocked down, it\'s whether you get up.', 'author': 'Vince Lombardi'},
      {'content': 'If you are working on something that you really care about, you don\'t have to be pushed.', 'author': 'Steve Jobs'},
      {'content': 'People who are crazy enough to think they can change the world, are the ones who do.', 'author': 'Rob Siltanen'},
      {'content': 'Failure will never overtake me if my determination to succeed is strong enough.', 'author': 'Og Mandino'},
      {'content': 'We may encounter many defeats but we must not be defeated.', 'author': 'Maya Angelou'},
    ];

    final random = Random();
    final selectedQuote = defaultQuotes[random.nextInt(defaultQuotes.length)];

    return {
      'content': selectedQuote['content']!,
      'author': selectedQuote['author']!,
      'success': false, // Using fallback
    };
  }
}