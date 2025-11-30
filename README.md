# 용돈 관리 앱 (Account Management App)

간단한 수입 및 지출 관리를 위한 플러터(Flutter) 기반의 모바일 애플리케이션입니다. 일별 및 월별 거래 내역을 추적하고, 홈 화면 위젯을 통해 현재 잔액을 빠르게 확인할 수 있습니다.

## 주요 기능

- **간편한 수입/지출 기록**: 직관적인 UI로 수입과 지출을 쉽게 추가, 수정, 삭제할 수 있습니다.
- **한눈에 보는 자산 현황**: 메인 화면에서 현재 잔액, 총수입, 총지출을 요약하여 보여줍니다.
- **거래 내역 확인**: 전체 거래 내역을 리스트 형태로 보거나, 캘린더 뷰를 통해 특정 날짜의 내역을 확인할 수 있습니다.
- **카테고리별 관리**: 수입(급여, 용돈 등)과 지출(식비, 교통, 쇼핑 등)을 카테고리별로 나누어 관리할 수 있습니다.
- **홈 화면 위젯**: 앱을 열지 않고도 홈 화면에서 바로 현재 잔액을 확인하고, '지출 추가' 화면으로 빠르게 이동할 수 있습니다.

## 스크린샷

| 메인 화면 | 캘린더 뷰 | 거래 추가 |
| :---: | :---: | :---: |
| <img src="https://placehold.co/300x600?text=Main+Screen" width="200"/> | <img src="https://placehold.co/300x600?text=Calendar+View" width="200"/> | <img src="https://placehold.co/300x600?text=Add+Transaction" width="200"/> |

*실제 앱 화면은 위 예시와 다를 수 있습니다.*


## 사용된 기술

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: `provider`
- **Database**: `sqflite` (로컬 데이터베이스)
- **UI Components**:
  - `table_calendar`: 캘린더 UI
  - `intl`: 날짜 및 통화 형식 지정
- **Android Integration**:
  - `home_widget`: 홈 화면 위젯 구현


## 설치 및 실행

```bash
# 1. 저장소 클론
git clone https://github.com/woojj12/AccountMgmt.git

# 2. 프로젝트 디렉토리로 이동
cd AccountMgmt

# 3. 의존성 설치
flutter pub get

# 4. 앱 실행
flutter run
```

## 릴리즈

최신 릴리즈 및 APK 파일은 [여기](https://github.com/woojj12/AccountMgmt/releases)에서 확인하실 수 있습니다.
