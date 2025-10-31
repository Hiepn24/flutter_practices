import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const String apiKey = '';
const String apiUrl =
    'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: NewsPage(),
    );
  }
}

class Article {
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;

  Article({
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] as String,
      description: json['description'] as String?,
      url: json['url'] as String,
      urlToImage: json['urlToImage'] as String?,
    );
  }
}

class ApiService {
  Future<List<Article>> fetchArticles() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        final List<dynamic> articlesJson = json['articles'];

        return articlesJson.map((item) => Article.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load news. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }
}

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late Future<List<Article>> _articlesFuture;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  void _fetchNews() {
    setState(() {
      _articlesFuture = apiService.fetchArticles();
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter News Reader'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchNews,
          ),
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Lỗi: ${snapshot.error}'),
              ),
            );
          }

          else if (snapshot.hasData) {
            final articles = snapshot.data!;

            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];

                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                    leading: article.urlToImage != null
                        ? Image.network(
                      article.urlToImage!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        return progress == null
                            ? child
                            : Container(
                            width: 100,
                            height: 100,
                            child: Center(child: CircularProgressIndicator()));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                            width: 100,
                            height: 100,
                            child: Icon(Icons.image_not_supported, color: Colors.grey));
                      },
                    )
                        : Container(
                        width: 100,
                        height: 100,
                        child: Icon(Icons.image, color: Colors.grey)
                    ),
                    title: Text(
                      article.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      article.description ?? 'No description available',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    onTap: () {
                      _launchURL(article.url);
                    },
                  ),
                );
              },
            );
          }

          else {
            return Center(child: Text('No news found.'));
          }
        },
      ),
    );
  }
}