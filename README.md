# flutter-dev

Bộ script hỗ trợ khởi động môi trường phát triển Flutter trên Linux với Android Emulator, Genymotion hoặc Waydroid.

## Yêu cầu

- Bash
- Flutter và Android SDK đã được cài đặt
- `adb` có trong `PATH`
- `code` có trong `PATH` để tự mở project bằng Visual Studio Code
- Các công cụ tương ứng với script muốn sử dụng:
	- Android Emulator: Android SDK Emulator và ít nhất một AVD
	- Genymotion: `gmtool` và ít nhất một virtual device
	- Waydroid: `waydroid`
- `sudo` nếu user hiện tại không có quyền ghi vào `/usr/local/bin`

## Cài đặt

Chạy từ thư mục gốc của repository:

```bash
chmod +x install.sh uninstall.sh
./install.sh
```

Script sẽ copy toàn bộ file `.sh` trong `src/` vào `/usr/local/bin/` và đặt quyền thực thi cho chúng.

Sau khi cài đặt, các lệnh có thể được gọi từ bất kỳ thư mục nào.

## Sử dụng

Các script nhận tham số tùy chọn là đường dẫn đến project Flutter. Nếu không truyền, thư mục hiện tại (`.`) sẽ được mở.

### Android Emulator

Tự chọn AVD đầu tiên, khởi động emulator, đợi Android boot xong rồi mở project:

```bash
flutter-dev-androidstudio /path/to/flutter-project
```

### Genymotion

Khởi động virtual device. Nếu có nhiều device, script sẽ yêu cầu chọn một device:

```bash
flutter-dev-genymotion /path/to/flutter-project
```

### Waydroid

Khởi động Waydroid, kết nối ADB và mở giao diện Waydroid:

```bash
flutter-dev-waydroid /path/to/flutter-project
```

### Dọn dẹp môi trường

Dừng emulator, Genymotion, Waydroid, Android Studio, Gradle và ADB server đang chạy:

```bash
flutter-cleanup
```

## Gỡ cài đặt

Chạy từ repository:

```bash
./uninstall.sh
```

Script sẽ xóa các script đã cài trong `/usr/local/bin/`. Các công cụ Flutter, Android SDK, Genymotion và Waydroid không bị xóa.
