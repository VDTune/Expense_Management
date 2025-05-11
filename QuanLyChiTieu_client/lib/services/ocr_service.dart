import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  // Danh sách từ khóa mở rộng
  final List<String> totalKeywords = [
    // Tiếng Việt
    r'Tổng cộng', r'Tổng tiền', r'Tổng thành tiền', r'Tổng giá trị', r'Tổng',r'Tổng dịch vụ',r'Tổng hàng',
    r'Tổng hóa đơn', r'Tổng thanh toán', r'Tổng số tiền', r'Tổng phải trả',
    r'Thành tiền', r'Số tiền thanh toán', r'Tiền mặt', r'Tiền thanh toán',
    r'Tổng tiền dịch vụ', r'Số tiền cần trả', r'Cần thanh toán', r'Số tiền trả',
    r'Số tiền cuối cùng', r'Tổng:', r'T. tiền',

    // Tiếng Anh
    r'Total', r'Total Amount', r'Invoice Total', r'Amount Due', r'Amount Payable',
    r'Total Payable', r'Payable Amount', r'Subtotal', r'Net Total', r'Grand Total',
    r'Final Total', r'Balance Due', r'Payment Due', r'Cash Amount'
  ]; 

  Future<Map<String, String>> extractData(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();
    String totalAmount = '';
    String date = '';

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      print("Recognized Text: \n${recognizedText.text}\n");

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final cleanedLine = line.text.trim();

          // Kiểm tra từ khóa tổng tiền (dựa trên danh sách mở rộng)
          if (_containsTotalKeyword(cleanedLine)) {
            totalAmount = _extractAmount(cleanedLine);
            print("Found Total Amount: $totalAmount in line: ${cleanedLine}");
          }

          // Kiểm tra ngày tháng
          if (_containsDate(cleanedLine)) {
            date = _extractDate(cleanedLine);
            print("Found Date: $date in line: ${cleanedLine}");
          }
        }
      }

      // Nếu không tìm thấy tổng tiền, thử tìm dòng cuối liên quan đến số tiền
      if (totalAmount.isEmpty) {
        final possibleAmounts = recognizedText.text.split('\n').reversed;
        for (final line in possibleAmounts) {
          final cleanedLine = line.trim();
          if (_isPotentialAmountLine(cleanedLine)) {
            totalAmount = _extractAmount(cleanedLine);
            print("Fallback Total Amount: $totalAmount from line: ${cleanedLine}");
            break;
          }
        }
      }
    } catch (e) {
      print("Error during OCR processing: $e");
    } finally {
      await textRecognizer.close();
    }

    return {'totalAmount': totalAmount, 'date': date};
  }

  // Helper method to check if the line contains any total-related keywords
  bool _containsTotalKeyword(String text) {
    return totalKeywords.any((keyword) => text.contains(RegExp(keyword, caseSensitive: false)));
  }

  // Helper method to check if the line contains a date
  bool _containsDate(String text) {
    return RegExp(r'\d{2}[/-]\d{2}[/-]\d{4}').hasMatch(text) || RegExp(r'\d{4}[/-]\d{2}[/-]\d{2}').hasMatch(text);
  }

  // Helper method to extract date from text
  String _extractDate(String text) {
    final dateMatch = RegExp(r'\d{2}[/-]\d{2}[/-]\d{4}|\d{4}[/-]\d{2}[/-]\d{2}').firstMatch(text);
    return dateMatch?.group(0) ?? '';
  }

  // Helper method to extract amount from text
  String _extractAmount(String text) {
    final matches = RegExp(r'[\d.,]+').allMatches(text);

    for (var match in matches) {
      String amount = match.group(0)!;
      amount = _normalizeAmount(amount);
      if (amount.isNotEmpty) {
        return amount;
      }
    }
    return '';
  }

  // Helper method to normalize the amount (handle comma and dot as thousand and decimal separators)
  String _normalizeAmount(String amount) {
    // Remove any non-numeric characters except for dot and comma
    amount = amount.replaceAll(RegExp(r'[^\d.,]'), '');

    // Check if the amount contains both comma and dot
    if (amount.contains(',') && amount.contains('.')) {
      if (amount.indexOf(',') < amount.indexOf('.')) {
        // Comma is used as thousand separator and dot as decimal separator
        amount = amount.replaceAll(',', '');
      } else {
        // Dot is used as thousand separator and comma as decimal separator
        amount = amount.replaceAll('.', '').replaceAll(',', '.');
      }
    } else if (amount.contains(',')) {
      // If the comma is in the last part, treat it as a decimal separator
      if (amount.indexOf(',') < amount.length - 3) {
        amount = amount.replaceAll(',', '');
      } else {
        amount = amount.replaceAll(',', '.');
      }
    }
    return amount;
  }

  // Helper method to check if a line is potentially a total amount line
  bool _isPotentialAmountLine(String text) {
    return RegExp(r'[\d.,]+').hasMatch(text) && !RegExp(r'[a-zA-Z]').hasMatch(text);
  }
}
