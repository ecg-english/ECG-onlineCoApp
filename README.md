# ECG Community App

ECGコミュニティメンバー向けの交流・学習プラットフォーム

## 📱 プロジェクト構成

このプロジェクトは3つの主要コンポーネントで構成されています:

- **backend/**: Node.js/Express バックエンドAPI (Render)
- **ECGCommunityApp/**: iOS SwiftUIネイティブアプリ
- **web/**: Webバージョン (GitHub Pages)

## ✨ 機能概要

### 認証・権限管理
- ユーザー登録・ログイン・自動ログイン
- ロールベースのアクセス制御（管理者、メンバー、ビジター）
- 管理者画面でのユーザー・ロール管理

### メイン機能

#### 🏠 Home
- Mile残高表示
- 新着イベント表示
- 新着学習コンテンツ表示

#### 💬 Community
- カテゴリ別チャンネル
- 投稿の作成・閲覧
- いいね・コメント機能
- ロールベースの閲覧・投稿権限

#### 📅 Event
- イベント一覧・詳細表示
- イベント参加登録/キャンセル
- イベントカレンダー
- プッシュ通知（前日20時・当日9時）

#### 📚 Learning
- カテゴリ別学習記事
- 記事完了とMile獲得
- 理解度評価

#### 🛒 Shop
- Mile残高表示
- ショップアイテム一覧
- Mileでのアイテム購入
- Mile購入（Stripe連携予定）

#### ⚙️ Setting
- プッシュ通知設定
- FAQ・お問い合わせ
- 利用規約・プライバシーポリシー
- ログアウト・アカウント削除

### 基本機能
- プロフィール編集（アイコン、自己紹介、Instagram連携など）
- メンバーリスト（メンバーのみ閲覧可能）
- コミュニティ紹介
- イベントカレンダー

### 管理者機能
- ユーザー管理（閲覧・削除・ロール付与）
- ロール管理（作成・編集・削除）
- カテゴリ/チャンネル管理
- イベント管理
- 学習コンテンツ管理
- ショップアイテム管理

## 🚀 クイックスタート

### 前提条件
- Node.js 18以上
- MongoDB Atlas アカウント
- Xcode 15以上（iOSアプリ開発の場合）

### 1. バックエンドのセットアップ

```bash
cd backend
npm install
cp .env.example .env
# .envファイルを編集してMongoDB接続情報を設定
npm start
```

サーバーが http://localhost:3000 で起動します。

### 2. iOSアプリのセットアップ

1. Xcodeで新しいプロジェクトを作成
2. `ECGCommunityApp`ディレクトリ内のファイルをプロジェクトに追加
3. `Services/APIService.swift`でAPIエンドポイントを設定
4. ⌘+R でビルド・実行

### 3. Webバージョンのセットアップ

```bash
cd web
python -m http.server 8000
```

ブラウザで http://localhost:8000 にアクセス

## 📖 詳細ドキュメント

- [セットアップガイド](SETUP_GUIDE.md) - 完全なセットアップ手順
- [デプロイメントガイド](DEPLOYMENT.md) - 本番環境へのデプロイ手順
- [バックエンドAPI](backend/README.md) - API仕様とエンドポイント
- [iOSアプリ](ECGCommunityApp/README.md) - iOSアプリの詳細
- [Webバージョン](web/README.md) - Webアプリの詳細

## 🔐 初期管理者アカウント

- メールアドレス: `kairidaiho12@gmail.com`
- パスワード: `kairi0986`
- ユーザー名: `Kairi`
- ロール: 管理者、メンバー

## 🛠️ 技術スタック

### バックエンド
- Node.js + Express
- MongoDB + Mongoose
- JWT認証
- Cloudinary（画像管理）

### iOSアプリ
- Swift 5.9
- SwiftUI
- Async/Await
- URLSession

### Webアプリ
- HTML5 + CSS3
- Vanilla JavaScript
- Fetch API
- レスポンシブデザイン

## 📂 プロジェクト構造

```
ECG-onlineCoApp/
├── backend/
│   ├── models/          # Mongooseモデル
│   ├── routes/          # APIルート
│   ├── middleware/      # 認証・権限ミドルウェア
│   ├── utils/           # ユーティリティ
│   └── server.js        # エントリーポイント
├── ECGCommunityApp/
│   ├── Models/          # データモデル
│   ├── Services/        # APIサービス
│   ├── ViewModels/      # ビューモデル
│   ├── Views/           # SwiftUIビュー
│   └── ECGCommunityApp.swift
├── web/
│   ├── index.html       # メインHTML
│   ├── styles.css       # スタイルシート
│   └── app.js           # JavaScriptアプリ
├── SETUP_GUIDE.md       # セットアップガイド
├── DEPLOYMENT.md        # デプロイメントガイド
└── README.md            # このファイル
```

## 🌐 デプロイ

### バックエンド（Render）
```bash
# Renderに自動デプロイ
git push origin main
```

### iOSアプリ（App Store）
1. Xcodeでアーカイブ作成
2. App Store Connectにアップロード
3. 審査申請

### Webバージョン（GitHub Pages）
```bash
cd web
git push origin main
# GitHub Pagesで自動デプロイ
```

## 🔄 今後の実装予定

- [ ] プッシュ通知機能
- [ ] 画像アップロード（Cloudinary連携）
- [ ] Stripe決済連携
- [ ] 管理者画面の完全実装
- [ ] PWA対応
- [ ] オフライン対応
- [ ] ダークモード対応

## 🤝 コントリビューション

プルリクエストを歓迎します!大きな変更の場合は、まずissueを開いて変更内容を議論してください。

## 📝 ライセンス

MIT License

## 📧 サポート

質問や問題がある場合は、以下にお問い合わせください:
- Email: ecg_english@nauticalmile.jp
- GitHub Issues: [Issues](https://github.com/your-username/ECG-onlineCoApp/issues)

---

Made with ❤️ by ECG Team

