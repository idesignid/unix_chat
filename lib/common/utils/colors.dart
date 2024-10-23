import 'package:flutter/material.dart';

// Function to convert hex color codes to Color objects
Color hexToColor(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('FF');
  buffer.write(hex.replaceAll('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

// Define colors using hexadecimal values
const String backgroundColorHex = '050505';
const String textColorHex = '2197DF';
const String appBarColorHex = '514C49';
const String webAppBarColorHex = '2a2f32';
const String messageColorHex = '2197DF';
const String senderMessageColorHex = '252d31';
const String tabColorHex = '2197DF';
const String searchBarColorHex = '323738';
const String dividerColorHex = '252d32';
const String chatBarMessageHex = '1e2428';
const String mobileChatBoxColorHex = '514C49';

// Colors
final Color backgroundColor = hexToColor(backgroundColorHex);
final Color textColor = hexToColor(textColorHex);
final Color appBarColor = hexToColor(appBarColorHex);
final Color webAppBarColor = hexToColor(webAppBarColorHex);
final Color messageColor = hexToColor(messageColorHex);
final Color senderMessageColor = hexToColor(senderMessageColorHex);
final Color tabColor = hexToColor(tabColorHex);
final Color searchBarColor = hexToColor(searchBarColorHex);
final Color dividerColor = hexToColor(dividerColorHex);
final Color chatBarMessage = hexToColor(chatBarMessageHex);
final Color mobileChatBoxColor = hexToColor(mobileChatBoxColorHex);

const greyColor = Colors.grey;
const blackColor = Colors.black;
