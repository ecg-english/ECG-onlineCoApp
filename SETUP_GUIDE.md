# ECG Community App セットアップガイド

このガイドでは、ECGコミュニティアプリの完全なセットアップ手順を説明します。

## プロジェクト構成

```
ECG-onlineCoApp/
├── backend/              # Node.js/Express バックエンドAPI
├── ECGCommunityApp/      # iOS SwiftUIアプリ
├── web/                  # Webバージョン
└── README.md
```

## 1. バックエンドのセットアップ

### 1.1 MongoDB Atlasのセットアップ

1. [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)にアクセス
2. 無料アカウントを作成
3. 新しいクラスターを作成（無料のM0 Sandboxを選択）
4. Database Access で新しいユーザーを作成
5. Network Access で接続元IPアドレスを追加（0.0.0.0/0 で全てのIPを許可）
6. Connect > Connect your application で接続文字列を取得

### 1.2 バックエンドのローカル実行

```bash
cd backend
npm install
```

`.env`ファイルを編集:
```
PORT=3000
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/ecg-community?retryWrites=true&w=majority
JWT_SECRET=your-super-secret-jwt-key-change-this
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
```

サーバーを起動:
```bash
npm start
```

ブラウザで http://localhost:3000/health にアクセスして動作確認

### 1.3 Renderへのデプロイ

1. [Render](https://render.com/)にアクセスしてアカウント作成
2. New > Web Service を選択
3. GitHubリポジトリを接続
4. 以下の設定:
   - Name: `ecg-community-api`
   - Root Directory: `backend`
   - Build Command: `npm install`
   - Start Command: `npm start`
5. Environment Variables を設定:
   - `MONGODB_URI`: MongoDB Atlas接続文字列
   - `JWT_SECRET`: ランダムな秘密鍵
   - `NODE_ENV`: `production`
6. Create Web Service をクリック

デプロイ完了後、URLをメモしておく（例: `https://ecg-community-api.onrender.com`）

## 2. iOSアプリのセットアップ

### 2.1 Xcodeプロジェクトの作成

1. Xcodeを開く
2. "Create a new Xcode project"を選択
3. "iOS" > "App"を選択
4. 以下の設定:
   - Product Name: `ECGCommunityApp`
   - Team: あなたの開発チーム
   - Organization Identifier: `com.ecg`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: `None`
5. 保存先: `/Users/kairidaiho/ECG-onlineCoApp/ECGCommunityApp`

### 2.2 ソースファイルの追加

Xcodeプロジェクトに以下のフォルダを追加:
- `Models/`
- `Services/`
- `ViewModels/`
- `Views/`
- `ECGCommunityApp.swift`
- `Info.plist`

### 2.3 APIエンドポイントの設定

`Services/APIService.swift`を開き、`baseURL`を変更:

```swift
// ローカル開発時
private let baseURL = "http://localhost:3000/api"

// 本番環境（Renderデプロイ後）
private let baseURL = "https://ecg-community-api.onrender.com/api"
```

### 2.4 ビルドと実行

1. Xcodeでプロジェクトを開く
2. シミュレーターを選択（iPhone 15 Proなど）
3. ⌘+R でビルド・実行

### 2.5 実機テスト

1. iPhoneをMacに接続
2. Xcodeで接続したデバイスを選択
3. Signing & Capabilities でチームを選択
4. ⌘+R でビルド・実行

## 3. Webバージョンのセットアップ

### 3.1 APIエンドポイントの設定

`web/app.js`を開き、`API_BASE_URL`を変更:

```javascript
// ローカル開発時
const API_BASE_URL = 'http://localhost:3000/api';

// 本番環境（Renderデプロイ後）
const API_BASE_URL = 'https://ecg-community-api.onrender.com/api';
```

### 3.2 ローカルテスト

```bash
cd web
python -m http.server 8000
```

ブラウザで http://localhost:8000 にアクセス

### 3.3 GitHub Pagesへのデプロイ

1. GitHubで新しいリポジトリを作成
2. `web`ディレクトリの内容をリポジトリにプッシュ:

```bash
cd web
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/your-username/ecg-community-web.git
git push -u origin main
```

3. リポジトリの Settings > Pages
4. Source を "main" ブランチの "/" (root) に設定
5. Save をクリック

数分後、`https://your-username.github.io/ecg-community-web/` でアクセス可能

### 3.4 CORS設定

バックエンドの`server.js`でCORS設定を更新:

```javascript
app.use(cors({
  origin: [
    'http://localhost:8000',
    'https://your-username.github.io'
  ],
  credentials: true
}));
```

## 4. 初期ログイン

全てのプラットフォームで以下の管理者アカウントでログイン可能:

- メールアドレス: `kairidaiho12@gmail.com`
- パスワード: `kairi0986`

## 5. トラブルシューティング

### バックエンドが起動しない

- MongoDBの接続文字列が正しいか確認
- `.env`ファイルが正しく設定されているか確認
- `npm install`を実行してパッケージをインストール

### iOSアプリでネットワークエラー

- バックエンドが起動しているか確認
- `Info.plist`で`NSAppTransportSecurity`が設定されているか確認
- シミュレーターの場合、`localhost`ではなく`127.0.0.1`を使用

### Webバージョンでログインできない

- バックエンドのCORS設定が正しいか確認
- ブラウザのコンソールでエラーメッセージを確認
- APIエンドポイントのURLが正しいか確認

### Renderでデプロイエラー

- `package.json`が正しいか確認
- 環境変数が全て設定されているか確認
- ビルドログを確認してエラーメッセージを確認

## 6. 次のステップ

### 実装予定の機能

- [ ] プッシュ通知機能
- [ ] 画像アップロード（Cloudinary連携）
- [ ] Stripe決済連携
- [ ] 管理者画面の完全実装
- [ ] PWA対応
- [ ] オフライン対応

### 推奨される追加設定

1. **セキュリティ**
   - JWT_SECRETを強力なランダム文字列に変更
   - HTTPS通信の強制
   - レート制限の実装

2. **パフォーマンス**
   - Redis キャッシュの追加
   - CDNの使用
   - 画像最適化

3. **監視**
   - Sentryでエラートラッキング
   - Google Analyticsでアクセス解析
   - アップタイム監視

## 7. サポート

問題が発生した場合:

1. READMEファイルを確認
2. エラーメッセージをGoogle検索
3. GitHubのIssuesで質問
4. ecg_english@nauticalmile.jp にお問い合わせ

## 8. ライセンス

MIT License

---

開発を楽しんでください! 🚀

