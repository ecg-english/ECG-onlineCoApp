# ECG Community Web Version

GitHub Pagesでホストされるウェブバージョン

## 特徴

- iOSアプリと同じバックエンドAPIを使用
- レスポンシブデザイン
- PWA対応（今後実装予定）

## セットアップ

### 1. APIエンドポイントの設定

`app.js`の`API_BASE_URL`を実際のバックエンドURLに変更してください:

```javascript
const API_BASE_URL = 'https://your-render-app.onrender.com/api';
```

### 2. GitHub Pagesへのデプロイ

1. GitHubリポジトリを作成
2. `web`ディレクトリの内容をリポジトリにプッシュ
3. リポジトリの Settings > Pages で GitHub Pages を有効化
4. Source を "main" ブランチの "/" (root) に設定

## ファイル構成

```
web/
├── index.html      # メインHTMLファイル
├── styles.css      # スタイルシート
├── app.js          # JavaScriptアプリケーション
└── README.md       # このファイル
```

## 機能

### 実装済み
- ログイン/サインアップ
- Homeタブ（Mile表示、新着情報）
- Communityタブ（チャンネル一覧）
- Eventタブ（イベント一覧）
- Learningタブ（学習記事一覧）
- Shopタブ（Mile残高、アイテム一覧）
- Settingタブ（各種設定）

### 今後実装予定
- チャンネル詳細画面
- 投稿作成・いいね・コメント機能
- イベント詳細・参加登録
- 学習記事完了・Mile獲得
- プロフィール編集
- メンバーリスト
- 管理者画面
- PWA対応
- オフライン対応

## ローカル開発

ローカルでテストする場合は、HTTPサーバーを起動してください:

```bash
# Pythonの場合
python -m http.server 8000

# Node.jsの場合
npx http-server -p 8000
```

その後、ブラウザで `http://localhost:8000` にアクセスしてください。

## CORS設定

バックエンドAPIで以下のCORS設定が必要です:

```javascript
app.use(cors({
  origin: 'https://your-github-username.github.io',
  credentials: true
}));
```

ローカル開発時は:

```javascript
app.use(cors({
  origin: 'http://localhost:8000',
  credentials: true
}));
```

## ブラウザ対応

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## セキュリティ

- JWTトークンはlocalStorageに保存
- HTTPS通信を推奨
- XSS対策として入力値のサニタイズを実装予定

## ライセンス

MIT

