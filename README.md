# SpendWise AI (Flutter)

Theo dõi chi tiêu chạy hoàn toàn trên máy, không cần mạng.

| Chức năng | Công nghệ |
|---|---|
| Đọc chữ trên hóa đơn / ảnh hợp đồng | `google_mlkit_text_recognition` (on-device) |
| Tách số tiền, ngày, nơi chi từ OCR / SMS / hợp đồng | Regex (`lib/parser.dart`) |
| Phân loại danh mục | Từ khóa không dấu (`categorize`) |
| Lưu trữ | SQLite qua `sqflite` (`lib/data.dart`) |
| Pie / Donut / Cột, biến động theo tuần | `fl_chart` |
| AI nhận xét tháng nhiều hay ít | Luật so sánh trên máy (`lib/insight.dart`) |

## Chạy thử

```bash
flutter create spendwise_ai
# chép đè lib/ và pubspec.yaml của gói này vào thư mục vừa tạo
cd spendwise_ai
flutter pub get
flutter run
```

## Cấu hình bắt buộc

**Android** – `android/app/build.gradle`: `minSdkVersion 21` (ML Kit yêu cầu).

**iOS** – `ios/Podfile`: `platform :ios, '15.5'`; `ios/Runner/Info.plist` thêm:
```xml
<key>NSCameraUsageDescription</key><string>Chụp hóa đơn để trích xuất chi tiêu</string>
<key>NSPhotoLibraryUsageDescription</key><string>Chọn ảnh hóa đơn</string>
```

## Cách dùng
1. Tab **Quét AI** → chọn Hóa đơn / SMS / Hợp đồng → chụp ảnh hoặc dán văn bản → **Phân tích**.
2. Sửa lại kết quả nếu cần → **Lưu vào dữ liệu máy**.
3. Tab **Tổng quan** xem tổng chi, giao dịch gần đây (giữ để xóa), hạn mức tháng (`kBudget` trong `data.dart`).
4. Tab **Báo cáo** đổi Pie / Donut / Cột, xem biến động theo tuần và nhận xét của AI.

## Mở rộng
- Thêm mẫu Regex riêng cho từng ngân hàng trong `parser.dart`.
- Android có thể tự đọc SMS bằng plugin đọc inbox (iOS không cho phép).
- Thêm từ khóa danh mục trong `_catKeywords`.
