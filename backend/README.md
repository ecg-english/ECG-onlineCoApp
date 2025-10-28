# ECG Community Backend API

Node.js/Express + MongoDBを使用したバックエンドAPI

## セットアップ

### 1. 依存関係のインストール

```bash
npm install
```

### 2. 環境変数の設定

`.env`ファイルを作成し、以下の環境変数を設定してください:

```
PORT=3000
MONGODB_URI=mongodb://localhost:27017/ecg-community
JWT_SECRET=your-secret-key
CLOUDINARY_CLOUD_NAME=your-cloudinary-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

### 3. MongoDBの起動

ローカルでMongoDBを起動するか、MongoDB Atlasを使用してください。

### 4. サーバーの起動

```bash
# 本番環境
npm start

# 開発環境（nodemon使用）
npm run dev
```

## Renderへのデプロイ

1. Renderアカウントを作成
2. 新しいWeb Serviceを作成
3. GitHubリポジトリを接続
4. `backend`ディレクトリをルートディレクトリとして設定
5. 環境変数を設定:
   - `MONGODB_URI`: MongoDB Atlas接続文字列
   - `JWT_SECRET`: ランダムな秘密鍵
   - `CLOUDINARY_*`: Cloudinary認証情報（画像アップロード用）

## API エンドポイント

### 認証
- `POST /api/auth/signup` - サインアップ
- `POST /api/auth/login` - ログイン
- `GET /api/auth/me` - 現在のユーザー情報取得

### ユーザー
- `GET /api/users` - 全ユーザー取得（管理者のみ）
- `GET /api/users/members` - メンバーリスト取得
- `GET /api/users/:userId` - ユーザー詳細取得
- `PUT /api/users/profile` - プロフィール更新
- `DELETE /api/users/:userId` - ユーザー削除（管理者のみ）

### ロール
- `GET /api/roles` - 全ロール取得
- `POST /api/roles` - ロール作成（管理者のみ）
- `PUT /api/roles/:roleId` - ロール更新（管理者のみ）
- `DELETE /api/roles/:roleId` - ロール削除（管理者のみ）

### カテゴリ
- `GET /api/categories` - 全カテゴリ取得
- `POST /api/categories` - カテゴリ作成（管理者のみ）
- `PUT /api/categories/:categoryId` - カテゴリ更新（管理者のみ）
- `DELETE /api/categories/:categoryId` - カテゴリ削除（管理者のみ）

### チャンネル
- `GET /api/channels` - 閲覧可能なチャンネル一覧取得
- `GET /api/channels/all` - 全チャンネル取得（管理者のみ）
- `POST /api/channels` - チャンネル作成（管理者のみ）
- `PUT /api/channels/:channelId` - チャンネル更新（管理者のみ）
- `DELETE /api/channels/:channelId` - チャンネル削除（管理者のみ）

### 投稿
- `GET /api/posts/channel/:channelId` - チャンネルの投稿一覧取得
- `POST /api/posts` - 投稿作成
- `DELETE /api/posts/:postId` - 投稿削除
- `POST /api/posts/:postId/like` - いいね追加/削除
- `POST /api/posts/:postId/comment` - コメント追加
- `DELETE /api/posts/:postId/comment/:commentId` - コメント削除

### イベント
- `GET /api/events` - イベント一覧取得
- `GET /api/events/:eventId` - イベント詳細取得
- `POST /api/events` - イベント作成（管理者のみ）
- `PUT /api/events/:eventId` - イベント更新（管理者のみ）
- `DELETE /api/events/:eventId` - イベント削除（管理者のみ）
- `POST /api/events/:eventId/participate` - イベント参加登録/キャンセル

### 学習
- `GET /api/learning` - 学習記事一覧取得
- `GET /api/learning/:articleId` - 学習記事詳細取得
- `POST /api/learning` - 学習記事作成（管理者のみ）
- `PUT /api/learning/:articleId` - 学習記事更新（管理者のみ）
- `DELETE /api/learning/:articleId` - 学習記事削除（管理者のみ）
- `POST /api/learning/:articleId/complete` - 学習記事完了とMile獲得

### Mile
- `GET /api/miles/balance` - Mile残高取得
- `GET /api/miles/transactions` - Mile取引履歴取得
- `POST /api/miles/purchase` - Mile購入
- `POST /api/miles/spend` - Mile使用

### ショップ
- `GET /api/shop` - ショップアイテム一覧取得
- `GET /api/shop/all` - 全ショップアイテム取得（管理者のみ）
- `POST /api/shop` - ショップアイテム作成（管理者のみ）
- `PUT /api/shop/:itemId` - ショップアイテム更新（管理者のみ）
- `DELETE /api/shop/:itemId` - ショップアイテム削除（管理者のみ）
- `POST /api/shop/:itemId/purchase` - ショップアイテム購入

## 初期データ

サーバー起動時に以下の初期データが自動作成されます:

### ロール
- 管理者
- メンバー
- ビジター

### 初期管理者ユーザー
- メールアドレス: kairidaiho12@gmail.com
- パスワード: kairi0986
- ユーザー名: Kairi

### デフォルトカテゴリ・チャンネル
- お知らせ > 全体お知らせ
- 雑談 > 自由雑談
- 学習

