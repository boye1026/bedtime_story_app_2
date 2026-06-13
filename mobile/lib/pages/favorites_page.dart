// mobile/lib/pages/favorites_page.dart
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/story.dart';
import 'story_display_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final StorageService _storageService = StorageService();
  List<Story> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    
    final favorites = await _storageService.getFavorites();
    
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(String storyId) async {
    await _storageService.removeFavorite(storyId);
    await _loadFavorites();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已取消收藏')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('暂无收藏故事', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('在故事页面点击❤️收藏你喜欢的故事', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/story-list'),
                        child: const Text('去探索故事'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final story = _favorites[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoryDisplayPage(
                                storyTitle: story.title,
                                storyContent: story.content,
                                story: story,
                              ),
                            ),
                          ).then((_) => _loadFavorites());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.auto_stories, size: 30, color: Colors.deepPurple),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(story.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(story.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text(story.formattedDate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey),
                                onPressed: () => _removeFavorite(story.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
