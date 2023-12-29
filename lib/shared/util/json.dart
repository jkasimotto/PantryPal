import 'dart:convert';

bool isJson(String str) {
  try {
    jsonDecode(str);
  } catch (e) {
    return false;
  }
  return true;
}
