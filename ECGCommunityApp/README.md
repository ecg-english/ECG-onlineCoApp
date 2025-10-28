# ECG Community iOS App

SwiftUIで作成されたECGコミュニティアプリのiOSネイティブ版

## 必要要件

- Xcode 15.0以上
- iOS 16.0以上
- Swift 5.9以上

## セットアップ

### 1. Xcodeプロジェクトの作成

1. Xcodeを開く
2. "Create a new Xcode project"を選択
3. "iOS" > "App"を選択
4. 以下の設定でプロジェクトを作成:
   - Product Name: `ECGCommunityApp`
   - Team: あなたの開発チーム
   - Organization Identifier: `com.ecg`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: `None`
5. 保存先: `/Users/kairidaiho/ECG-onlineCoApp/ECGCommunityApp`

### 2. ソースファイルの追加

このディレクトリ内の以下のフォルダをXcodeプロジェクトに追加してください:

- `Models/` - データモデル
- `Services/` - APIサービス
- `ViewModels/` - ビューモデル
- `Views/` - SwiftUIビュー

### 3. APIエンドポイントの設定

`Services/APIService.swift`の`baseURL`を実際のバックエンドURLに変更してください:

```swift
private let baseURL = "https://your-render-app.onrender.com/api"
```

ローカル開発の場合:
```swift
private let baseURL = "http://localhost:3000/api"
```

### 4. Info.plistの設定

プロジェクトに`Info.plist`を追加し、HTTPSでないローカルサーバーへの接続を許可してください（開発時のみ）。

## プロジェクト構造

```
ECGCommunityApp/
├── Models/              # データモデル
│   ├── User.swift
│   ├── Channel.swift
│   ├── Event.swift
│   ├── Learning.swift
│   └── Shop.swift
├── Services/            # APIサービス
│   └── APIService.swift
├── ViewModels/          # ビューモデル
│   ├── AuthViewModel.swift
│   ├── CommunityViewModel.swift
│   ├── EventViewModel.swift
│   ├── LearningViewModel.swift
│   ├── MileViewModel.swift
│   └── ShopViewModel.swift
├── Views/               # SwiftUIビュー
│   ├── Auth/           # 認証画面
│   ├── Home/           # ホーム画面
│   ├── Community/      # コミュニティ画面
│   ├── Event/          # イベント画面
│   ├── Learning/       # 学習画面
│   ├── Shop/           # ショップ画面
│   ├── Setting/        # 設定画面
│   ├── Profile/        # プロフィール画面
│   ├── Member/         # メンバーリスト画面
│   ├── About/          # アプリ紹介画面
│   ├── Admin/          # 管理者画面
│   ├── Menu/           # メニュー画面
│   └── MainTabView.swift
└── ECGCommunityApp.swift # メインアプリファイル
```

## 主な機能

### 認証
- ログイン
- サインアップ
- 自動ログイン（トークン保存）

### Home
- Mile残高表示
- 新着イベント表示
- 新着学習コンテンツ表示

### Community
- カテゴリ別チャンネル表示
- 投稿の作成・閲覧
- いいね・コメント機能
- ロールベースのアクセス制御

### Event
- イベント一覧表示
- イベント詳細表示
- 参加登録/キャンセル
- イベントカレンダー

### Learning
- カテゴリ別学習記事表示
- 記事完了とMile獲得
- 理解度評価

### Shop
- Mile残高表示
- ショップアイテム一覧
- アイテム購入

### Setting
- プッシュ通知設定
- FAQ
- 利用規約
- プライバシーポリシー
- ログアウト
- アカウント削除

### 基本機能
- プロフィール編集
- メンバーリスト（メンバーのみ）
- コミュニティ紹介
- イベントカレンダー

### 管理者機能
- ユーザー管理
- ロール管理
- カテゴリ/チャンネル管理
- イベント管理
- 学習コンテンツ管理
- ショップアイテム管理

## ビルドと実行

1. Xcodeでプロジェクトを開く
2. シミュレーターまたは実機を選択
3. ⌘+R でビルド・実行

## 初期ログイン情報

管理者アカウント:
- メールアドレス: `kairidaiho12@gmail.com`
- パスワード: `kairi0986`

## トラブルシューティング

### ネットワークエラー
- バックエンドサーバーが起動しているか確認
- `APIService.swift`の`baseURL`が正しいか確認
- Info.plistでHTTP通信が許可されているか確認

### ビルドエラー
- Xcodeのバージョンが15.0以上か確認
- プロジェクトのDeployment Targetが16.0以上に設定されているか確認

## 今後の実装予定

- [ ] プッシュ通知機能
- [ ] 画像アップロード機能
- [ ] Stripe決済連携
- [ ] オフライン対応
- [ ] ダークモード対応の改善

