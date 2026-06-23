# PlanetPizza
- Xem báo cáo doanh thu.

## Luồng Hoạt Động Chính

### Luồng đặt hàng

```text
User đăng nhập
→ Chọn món
→ Chọn size/topping/đồ uống dùng kèm
→ Thêm vào giỏ hàng
→ Nhập thông tin giao hàng
→ Chọn thanh toán
→ Xác nhận đơn
→ Lưu đơn vào Firestore
→ User nhận thông báo đơn hàng
```

### Luồng admin xử lý đơn hàng

```text
Admin đăng nhập
→ Vào Admin Dashboard
→ Chọn Quản lý đơn hàng
→ Xem danh sách đơn
→ Cập nhật trạng thái đơn
→ Firestore cập nhật realtime
→ User thấy thông báo trạng thái mới
```

### Luồng tích điểm

```text
User đặt hàng thành công
→ Tổng tiền đơn hàng / 10.000
→ Cộng điểm vào user.loyaltyPoints
```

Ví dụ:

```text
254.000đ / 10.000 = 25 điểm
```

Nếu admin hủy đơn hàng, hệ thống sẽ trừ lại số điểm đã cộng từ đơn đó.

## Các Collection Firestore

### `users`

Lưu thông tin tài khoản.

Các field chính:

```text
uid
username
email
phone
role
defaultAddress
linkedPaymentMethod
notificationsEnabled
language
disabled
loyaltyPoints
```

### `orders`

Lưu đơn hàng.

Các field chính:

```text
id
items
totalAmount
address
phone
dateTime
userEmail
customerName
paymentMethod
status
```

Status đơn hàng:

```text
pending
preparing
shipping
completed
cancelled
```

### `contact_requests`

Lưu yêu cầu liên hệ/góp ý của khách hàng.

Các field chính:

```text
name
phone
email
subject
message
recipientEmail
userEmail
createdAt
status
```

## Build APK

Build bản debug:

```bash
flutter build apk --debug
```

File APK sau khi build:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Build bản release:

```bash
flutter build apk --release
```

File release:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Lưu Ý Khi Upload GitHub

Nên upload:

```text
lib/
assets/
android/
test/
pubspec.yaml
pubspec.lock
analysis_options.yaml
README.md
.gitignore
```

Không nên upload:

```text
build/
.dart_tool/
.gradle/
.idea/
*.apk
*.rar
*.log
```

### Về `google-services.json`

Nếu đây là đồ án/demo học tập, có thể upload `android/app/google-services.json` để người chấm dễ chạy project.

Nếu repository public hoặc dùng cho sản phẩm thật, nên cân nhắc không upload file này. Khi đó, trong README cần ghi rõ người chạy app phải tự tạo Firebase project và tự thêm file:

```text
android/app/google-services.json
```

Lưu ý: Firebase config trong `google-services.json` không giống private key server, nhưng vẫn nên bảo vệ project bằng Firebase Rules và không để database mở tự do.

### Không bao giờ upload

```text
serviceAccountKey.json
private key
password thật
token bí mật
API secret server
```

## Gợi Ý `.gitignore`

Nếu chưa có `.gitignore`, nên đảm bảo có các dòng sau:

```gitignore
.dart_tool/
.packages
.flutter-plugins
.flutter-plugins-dependencies
