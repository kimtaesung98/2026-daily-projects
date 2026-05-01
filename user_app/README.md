# Smart Care-Connect (user_app)

시니어(피보호자)의 안전을 보호자(가족)에게 실시간으로 전달하는 Flutter 앱.

---

## 1. Architecture

**Clean Architecture (Data / Domain / Presentation 3-layer)** + **BLoC** + **get_it / injectable** DI.

```
lib/
├─ main.dart                     # Firebase 초기화 + DI 부트스트랩 + runApp
├─ app/
│  ├─ app.dart                   # MaterialApp (Material 3, light/dark)
│  └─ theme/
│     ├─ app_theme.dart
│     └─ app_colors.dart         # Status semantic colors (Normal/Idle/Warning/Emergency)
├─ core/
│  ├─ constants/
│  │  └─ risk_thresholds.dart    # RiskScore 임계값 단일 진실 공급원
│  ├─ error/
│  │  ├─ failures.dart           # sealed class Failure
│  │  └─ exceptions.dart         # DataSource 예외
│  ├─ usecases/
│  │  └─ usecase.dart            # UseCase / StreamUseCase / NoParams
│  └─ utils/
│     └─ responsive.dart         # LayoutBuilder + ScreenType
├─ di/
│  └─ injection.dart             # @InjectableInit + 수동 등록 fallback
├─ services/
│  └─ notification_service.dart  # NotificationService (Firebase Messaging)
└─ features/
   └─ senior/
      ├─ domain/
      │  ├─ entities/            # Senior, RiskScore, SeniorStatus
      │  ├─ repositories/        # SeniorRepository (abstract)
      │  └─ usecases/            # GetSeniors / WatchSeniors
      ├─ data/
      │  ├─ models/              # SeniorModel (Firestore DTO)
      │  ├─ datasources/         # SeniorRemoteDataSource (Firestore)
      │  └─ repositories/        # SeniorRepositoryImpl
      └─ presentation/
         ├─ bloc/                # SeniorBloc / Event / State
         ├─ pages/
         │  ├─ senior_dashboard_page.dart
         │  └─ views/
         │     ├─ senior_dashboard_mobile_view.dart
         │     └─ senior_dashboard_tablet_view.dart
         └─ widgets/             # SeniorCard, RiskScoreBadge
```

### 핵심 규칙

- 모든 Repository · UseCase 는 `Either<Failure, Success>` 반환 → 호출 측이 에러를 강제 분기.
- `RiskScore` 는 0~100 범위의 Value Object 이며 `SeniorStatus` 와 1:1 매핑.
- RiskScore ≥ 80(Emergency) 발생 시 `SeniorRepositoryImpl` 이 `NotificationService.notifyEmergency()` 를 호출하고, 같은 시니어에 대한 중복 알림은 디바운스 처리.
- 화면은 `ResponsiveLayout` + `LayoutBuilder` 로 Mobile / Tablet 뷰를 완전히 분리.

### Status 기준 (RiskScore)

| 점수    | Status    | 색상              | 동작                               |
| ------- | --------- | ----------------- | ---------------------------------- |
| 0–19    | Normal    | green             | —                                  |
| 20–49   | Idle      | grey              | UI 안내                            |
| 50–79   | Warning   | amber             | UI 강조                            |
| 80–100  | Emergency | red               | UI 강조 + Notification 즉시 호출  |

---

## 2. Setup

### 2.1 의존성 설치

```bash
flutter pub get
```

### 2.2 Firebase 설정

1. [FlutterFire CLI](https://firebase.flutter.dev/docs/cli) 설치 후

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   → `lib/firebase_options.dart` 가 생성됩니다.

2. `lib/main.dart` 에서 다음 줄을 활성화:

   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

3. Firestore 컬렉션 `seniors/{seniorId}` 스키마:

   ```
   name: string
   age: number
   guardianId: string
   riskScore: number          // 0 ~ 100
   lastActiveAt: timestamp?
   ```

### 2.3 DI 코드 생성 (선택)

수동 등록(`configureDependenciesManually`)으로도 동작하지만, `@injectable` 애노테이션을 활용하려면:

```bash
dart run build_runner build --delete-conflicting-outputs
```

생성된 `injection.config.dart` 가 만들어진 뒤 `injection.dart` 에서 `await init(sl);` 라인을 활성화하세요.

---

## 3. Run

```bash
flutter run
```

테스트:

```bash
flutter test
```

---

## 4. Coding Standard

- `const` 생성자 적극 활용 (위젯 리빌드 비용 최소화).
- 모든 public API 는 한글/영문 doc comment 작성.
- BLoC 이벤트는 `sealed class` 로 정의하고 `switch (state.status)` 로 패턴 매칭.
- DataSource → Repository 변환 시 예외를 반드시 `Failure` 로 매핑.
