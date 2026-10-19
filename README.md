SpendWise AI
Ứng dụng di động hỗ trợ theo dõi và phân tích chi tiêu cá nhân, hướng đến việc nhập khoản chi nhanh chóng từ hóa đơn hoặc nội dung tin nhắn, lưu dữ liệu trên thiết bị và xem xu hướng chi tiêu theo thời gian.
Nền tảng: Flutter
Repository: MiniProject3

Mục tiêu dự án
SpendWise AI được xây dựng nhằm giúp người dùng quản lý các khoản thu/chi thuận tiện hơn, giảm thao tác nhập liệu thủ công và hiểu rõ thói quen chi tiêu thông qua thống kê trực quan.
Chức năng chính
- Quản lý chi tiêu: ghi nhận và theo dõi các khoản chi cá nhân.
- Nhận diện chữ trên hóa đơn: sử dụng Google ML Kit Text Recognition để nhận diện văn bản từ hình ảnh được chọn.
- Trích xuất thông tin bằng Regex: áp dụng biểu thức chính quy để tìm các trường phù hợp trong văn bản nhận diện được, chẳng hạn số tiền hoặc ngày giao dịch. Kết quả cần được người dùng kiểm tra trước khi lưu vì định dạng hóa đơn/tin nhắn có thể khác nhau.
- Lưu trữ cục bộ: sử dụng SQLite để lưu dữ liệu trên thiết bị.
- Phân tích chi tiêu: tổng hợp dữ liệu theo tuần/tháng và đưa ra nhận xét dựa trên quy tắc so sánh dữ liệu chi tiêu.
- Biểu đồ thống kê: sử dụng fl_chart để trình bày dữ liệu trực quan, ví dụ biểu đồ tròn/Donut và biểu đồ theo thời gian, tùy theo màn hình được triển khai trong mã nguồn.
Công nghệ sử dụng
Công nghệ/thư viện	Mục đích
Flutter, Dart	Xây dựng ứng dụng đa nền tảng
Google ML Kit Text Recognition	Nhận diện văn bản từ hình ảnh hóa đơn
Regular Expressions (Regex)	Tìm và trích xuất thông tin theo mẫu
SQLite (sqflite)	Lưu trữ dữ liệu cục bộ
fl_chart	Hiển thị biểu đồ thống kê
image_picker	Cho phép chọn ảnh từ thiết bị


Các thư viện và phiên bản cụ thể được khai báo trong pubspec.yaml và pubspec.lock.
Cách chạy dự án
Yêu cầu
- Đã cài Flutter SDK và Dart tương thích với dự án.
- Đã cài Android Studio hoặc công cụ Android SDK.
- Có thiết bị Android hoặc trình giả lập để chạy ứng dụng.
Kiểm tra môi trường Flutter:
flutter doctor
Tải mã nguồn
git clone https://github.com/tranthithulam0510-max/MiniProject3.git
cd MiniProject3
Cài đặt thư viện
flutter pub get
Chạy ứng dụng
flutter run
Có thể mở thư mục dự án bằng Android Studio hoặc VS Code sau khi tải mã nguồn. Nếu lệnh chạy báo lỗi, hãy kiểm tra phiên bản Flutter/Dart, Android SDK và cấu hình thiết bị theo thông báo lỗi.
Cấu trúc thư mục
MiniProject3/
├── android/          # Cấu hình nền tảng Android
├── ios/              # Cấu hình nền tảng iOS
├── lib/              # Mã nguồn Dart/Flutter của ứng dụng
├── test/             # Kiểm thử (nếu có)
├── pubspec.yaml      # Khai báo thư viện và tài nguyên
├── pubspec.lock      # Phiên bản thư viện đã khóa
├── analysis_options.yaml
└── README.md         # Tài liệu dự án
Cấu trúc thực tế có thể khác đôi chút tùy các thư mục và file hiện có trong repository.
Xử lý dữ liệu và quyền riêng tư
- Dữ liệu chi tiêu được thiết kế để lưu cục bộ bằng SQLite.
- Phần nhận diện chữ và phân tích theo quy tắc có thể thực hiện trên thiết bị; khả năng hoạt động offline cụ thể phụ thuộc vào cấu hình thư viện và cách triển khai hiện tại.
- Văn bản OCR có thể nhận diện sai. Người dùng nên kiểm tra số tiền, ngày và nội dung trước khi xác nhận lưu giao dịch.
- Không commit dữ liệu giao dịch cá nhân, ảnh hóa đơn thật, mật khẩu, API key hoặc file cấu hình chứa thông tin bí mật lên repository công khai.
Phạm vi phân tích AI
Trong phiên bản sử dụng luật so sánh, ứng dụng có thể tổng hợp dữ liệu và tạo nhận xét dựa trên các quy tắc (ví dụ so sánh tổng chi tiêu giữa các giai đoạn). Đây là phân tích theo quy tắc trên thiết bị, không nên mô tả là mô hình học máy dự đoán nếu dự án chưa tích hợp và đánh giá một mô hình như vậy.
Trạng thái dự án
README mô tả mục tiêu, công nghệ và cách chạy dự án. Mức độ hoàn thành của từng chức năng cần được xác nhận bằng mã nguồn và kiểm thử thực tế; không nên xem mô tả trong tài liệu là bằng chứng rằng mọi chức năng đã hoạt động đầy đủ.
Đóng góp và báo lỗi
Nếu phát hiện lỗi khi cài đặt hoặc chạy ứng dụng, hãy tạo Issue trong repository và cung cấp:
- Các bước tái hiện lỗi.
- Thông báo lỗi liên quan.
- Phiên bản Flutter/Dart và thiết bị đang sử dụng.