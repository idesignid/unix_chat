import 'package:flutter_riverpod/flutter_riverpod.dart';

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');
