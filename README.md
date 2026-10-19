# SpendWise AI

Ứng dụng di động hỗ trợ theo dõi và phân tích chi tiêu cá nhân. SpendWise AI hướng đến việc giảm thao tác nhập liệu thủ công bằng cách nhận diện văn bản từ hóa đơn, trích xuất thông tin giao dịch, lưu dữ liệu trên thiết bị và hiển thị thống kê chi tiêu.

## Mục tiêu dự án

SpendWise AI giúp người dùng quản lý các khoản chi, theo dõi biến động chi tiêu theo tuần/tháng và hiểu rõ hơn thói quen chi tiêu thông qua thống kê trực quan.

## Chức năng chính

- **Quản lý chi tiêu:** ghi nhận và theo dõi các khoản chi cá nhân.
- **Nhận diện chữ trên hóa đơn:** sử dụng Google ML Kit Text Recognition để nhận diện văn bản từ hình ảnh được chọn.
- **Trích xuất thông tin bằng Regex:** tìm các trường phù hợp trong văn bản, chẳng hạn số tiền hoặc ngày giao dịch. Người dùng nên kiểm tra kết quả trước khi lưu vì định dạng hóa đơn và tin nhắn có thể khác nhau.
- **Lưu trữ cục bộ:** sử dụng SQLite để lưu dữ liệu chi tiêu trên thiết bị.
- **Phân tích chi tiêu:** tổng hợp dữ liệu theo tuần/tháng và đưa ra nhận xét dựa trên quy tắc so sánh dữ liệu.
- **Biểu đồ thống kê:** sử dụng `fl_chart` để trực quan hóa dữ liệu theo danh mục và thời gian, tùy theo các màn hình đã triển khai trong mã nguồn.

## Công nghệ sử dụng

| Công nghệ/thư viện | Mục đích |
|---|---|
| Flutter, Dart | Xây dựng ứng dụng đa nền tảng |
| Google ML Kit Text Recognition | Nhận diện văn bản từ hình ảnh hóa đơn |
| Regular Expressions (Regex) | Tìm và trích xuất thông tin theo mẫu |
| SQLite (`sqflite`) | Lưu trữ dữ liệu cục bộ |
| `fl_chart` | Hiển thị biểu đồ thống kê |
| `image_picker` | Chọn hình ảnh từ thiết bị |

Các thư viện và phiên bản cụ thể được khai báo trong `pubspec.yaml` và `pubspec.lock`.

## Yêu cầu môi trường

- Flutter SDK và Dart tương thích với dự án.
- Android Studio hoặc Android SDK đã được cài đặt.
- Thiết bị Android hoặc trình giả lập để chạy ứng dụng.

Kiểm tra môi trường Flutter bằng lệnh:

```bash
flutter doctor
```

## Cách tải và chạy dự án

### 1. Clone repository



### 2. Cài đặt thư viện

```bash
flutter pub get
```

### 3. Chạy ứng dụng

```bash
flutter run
```

Bạn cũng có thể mở thư mục dự án bằng Android Studio hoặc VS Code. Nếu ứng dụng không chạy, hãy kiểm tra phiên bản Flutter/Dart, Android SDK và thông báo lỗi hiển thị trong Terminal.

## Cấu trúc thư mục

```text
MiniProject3/
├── android/                # Cấu hình nền tảng Android
├── ios/                    # Cấu hình nền tảng iOS
├── lib/                    # Mã nguồn Dart/Flutter
├── test/                   # Kiểm thử (nếu có)
├── pubspec.yaml            # Khai báo thư viện và tài nguyên
├── pubspec.lock            # Phiên bản thư viện đã khóa
├── analysis_options.yaml   # Quy tắc phân tích mã Dart
└── README.md               # Tài liệu dự án
```

Cấu trúc thực tế có thể khác tùy các thư mục và file hiện có trong repository.

## Dữ liệu và quyền riêng tư

- Dữ liệu chi tiêu được thiết kế để lưu cục bộ bằng SQLite.
- Khả năng hoạt động hoàn toàn offline phụ thuộc vào cách cấu hình và triển khai từng thư viện.
- Kết quả nhận diện OCR có thể không chính xác; hãy kiểm tra số tiền, ngày và nội dung trước khi xác nhận giao dịch.
- Không đưa dữ liệu giao dịch cá nhân, ảnh hóa đơn thật, mật khẩu, API key hoặc thông tin bí mật lên repository công khai.

## Phạm vi phân tích AI

Nếu phiên bản hiện tại tạo nhận xét bằng các luật so sánh (ví dụ so sánh tổng chi tiêu giữa hai giai đoạn), hãy mô tả đây là **phân tích theo quy tắc trên thiết bị**. Chỉ nên gọi là mô hình học máy dự đoán nếu dự án thực sự tích hợp và đánh giá một mô hình như vậy.

## Trạng thái dự án

README mô tả mục tiêu, công nghệ và cách chạy ứng dụng. Mức độ hoàn thành của từng chức năng cần được xác nhận bằng mã nguồn và kiểm thử thực tế; tài liệu này không thay thế cho việc kiểm thử ứng dụng.

## Báo lỗi

Nếu gặp lỗi khi cài đặt hoặc chạy ứng dụng, hãy tạo Issue trong repository và cung cấp:
- Các bước tái hiện lỗi.
- Thông báo lỗi liên quan.
- Phiên bản Flutter/Dart và thiết bị đang sử dụng.

## Repository


