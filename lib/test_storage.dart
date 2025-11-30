import 'dart:html' as html;
import 'dart:convert';

void testLocalStorage() {
  print('=== Testing localStorage ===');
  
  try {
    // Test yazma
    final testData = {'test': 'value', 'number': 42};
    html.window.localStorage['test_key'] = jsonEncode(testData);
    print('Yazıldı: test_key = ${jsonEncode(testData)}');
    
    // Test okuma
    final retrieved = html.window.localStorage['test_key'];
    print('Okundu: test_key = $retrieved');
    
    if (retrieved != null) {
      final decoded = jsonDecode(retrieved);
      print('Decode edildi: $decoded');
    }
    
    // Tüm keys
    print('localStorage keys: ${html.window.localStorage.keys.toList()}');
    
  } catch (e, stackTrace) {
    print('Error: $e');
    print('StackTrace: $stackTrace');
  }
}
