# デプロイメントガイド

## 本番環境へのデプロイ手順

### 1. バックエンド（Render）

#### 前提条件
- Renderアカウント
- MongoDB Atlasアカウント
- GitHubリポジトリ

#### 手順

1. **MongoDB Atlasの設定**
   ```
   - クラスターを作成
   - データベースユーザーを作成
   - ネットワークアクセスで 0.0.0.0/0 を許可
   - 接続文字列を取得
   ```

2. **Renderでのデプロイ**
   ```
   1. Render Dashboard > New > Web Service
   2. GitHubリポジトリを接続
   3. 設定:
      - Name: ecg-community-api
      - Root Directory: backend
      - Environment: Node
      - Build Command: npm install
      - Start Command: npm start
   4. 環境変数を設定:
      - MONGODB_URI: [MongoDB Atlas接続文字列]
      - JWT_SECRET: [ランダムな秘密鍵]
      - NODE_ENV: production
   5. Create Web Service
   ```

3. **デプロイ確認**
   ```bash
   curl https://your-app.onrender.com/health
   # 応答: {"status":"OK","message":"ECG Community API is running"}
   ```

#### 環境変数の設定

```env
PORT=3000
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/ecg-community
JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters
NODE_ENV=production
CLOUDINARY_CLOUD_NAME=your-cloudinary-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

#### 自動デプロイの設定

Renderは自動的にGitHubのmainブランチへのプッシュを検知してデプロイします。

### 2. iOSアプリ（App Store）

#### 前提条件
- Apple Developer Program アカウント（年間$99）
- Xcode 15以上
- 実機でのテスト完了

#### 手順

1. **App Store Connectでアプリ登録**
   ```
   1. App Store Connect にログイン
   2. マイApp > + ボタン > 新規App
   3. プラットフォーム: iOS
   4. 名前: ECG Community
   5. Bundle ID: com.ecg.ECGCommunityApp
   6. SKU: ecg-community-app
   7. ユーザーアクセス: フルアクセス
   ```

2. **Xcodeでアーカイブ作成**
   ```
   1. Xcodeでプロジェクトを開く
   2. Product > Scheme > Edit Scheme
   3. Run > Build Configuration を Release に変更
   4. Product > Archive
   5. アーカイブが完成したら Distribute App
   6. App Store Connect を選択
   7. Upload
   ```

3. **App Store Connectで審査申請**
   ```
   1. App Store Connect でアプリを開く
   2. バージョン情報を入力:
      - スクリーンショット（必須）
      - アプリ説明
      - キーワード
      - サポートURL
      - プライバシーポリシーURL
   3. 審査に提出
   ```

#### TestFlightでのベータテスト

```
1. Xcodeからアーカイブをアップロード
2. App Store Connect > TestFlight
3. 内部テスター/外部テスターを追加
4. テスターにメールが送信される
```

### 3. Webバージョン（GitHub Pages）

#### 前提条件
- GitHubアカウント
- カスタムドメイン（オプション）

#### 手順

1. **GitHubリポジトリの作成**
   ```bash
   # webディレクトリで実行
   cd web
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/your-username/ecg-community-web.git
   git push -u origin main
   ```

2. **GitHub Pagesの有効化**
   ```
   1. リポジトリの Settings > Pages
   2. Source: Deploy from a branch
   3. Branch: main / (root)
   4. Save
   ```

3. **カスタムドメインの設定（オプション）**
   ```
   1. Settings > Pages > Custom domain
   2. ドメイン名を入力（例: app.ecg-community.com）
   3. DNSプロバイダーでCNAMEレコードを設定:
      - Name: app
      - Value: your-username.github.io
   4. Enforce HTTPS にチェック
   ```

#### デプロイURL

- デフォルト: `https://your-username.github.io/ecg-community-web/`
- カスタムドメイン: `https://app.ecg-community.com/`

### 4. 環境別設定

#### 開発環境
```javascript
// iOS: Services/APIService.swift
private let baseURL = "http://localhost:3000/api"

// Web: web/app.js
const API_BASE_URL = 'http://localhost:3000/api';
```

#### 本番環境
```javascript
// iOS: Services/APIService.swift
private let baseURL = "https://ecg-community-api.onrender.com/api"

// Web: web/app.js
const API_BASE_URL = 'https://ecg-community-api.onrender.com/api';
```

### 5. デプロイ後の確認事項

#### バックエンド
- [ ] ヘルスチェックエンドポイントが応答する
- [ ] 初期管理者アカウントでログインできる
- [ ] データベース接続が正常
- [ ] CORS設定が正しい

#### iOSアプリ
- [ ] TestFlightでインストールできる
- [ ] ログイン/サインアップが動作する
- [ ] 全ての画面が正常に表示される
- [ ] プッシュ通知の設定が完了している

#### Webバージョン
- [ ] GitHub Pagesでアクセスできる
- [ ] ログイン/サインアップが動作する
- [ ] 全ての機能が正常に動作する
- [ ] レスポンシブデザインが正しく表示される

### 6. 継続的デプロイメント（CI/CD）

#### GitHub Actionsの設定例

`.github/workflows/deploy.yml`:
```yaml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  deploy-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to Render
        run: |
          curl -X POST ${{ secrets.RENDER_DEPLOY_HOOK }}

  deploy-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./web
```

### 7. モニタリングとログ

#### Renderでのログ確認
```
1. Render Dashboard > Service
2. Logs タブでリアルタイムログを確認
3. エラーが発生した場合はログを確認
```

#### エラートラッキング（Sentry）

```bash
# バックエンドにSentryを追加
npm install @sentry/node

# server.jsに追加
const Sentry = require("@sentry/node");
Sentry.init({ dsn: process.env.SENTRY_DSN });
```

### 8. バックアップとリストア

#### MongoDBのバックアップ

```bash
# MongoDB Atlasの場合、自動バックアップが有効
# 手動バックアップ
mongodump --uri="mongodb+srv://username:password@cluster.mongodb.net/ecg-community"

# リストア
mongorestore --uri="mongodb+srv://username:password@cluster.mongodb.net/ecg-community" dump/
```

### 9. スケーリング

#### Renderでのスケーリング

```
1. Render Dashboard > Service > Settings
2. Instance Type を変更（Starter, Standard, Pro）
3. Auto-scaling を有効化
```

#### データベースのスケーリング

```
1. MongoDB Atlas Dashboard
2. Cluster > Edit Configuration
3. Cluster Tier を変更（M0, M10, M20...）
```

### 10. セキュリティチェックリスト

- [ ] 環境変数に秘密情報を保存
- [ ] JWT_SECRETは強力なランダム文字列
- [ ] HTTPS通信を強制
- [ ] CORS設定が適切
- [ ] レート制限を実装
- [ ] 入力値のバリデーション
- [ ] SQLインジェクション対策
- [ ] XSS対策

---

デプロイに関する質問がある場合は、ecg_english@nauticalmile.jp までお問い合わせください。

