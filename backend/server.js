require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// MongoDB接続
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ecg-community', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('MongoDB接続成功'))
.catch(err => console.error('MongoDB接続エラー:', err));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', require('./routes/users'));
app.use('/api/roles', require('./routes/roles'));
app.use('/api/categories', require('./routes/categories'));
app.use('/api/channels', require('./routes/channels'));
app.use('/api/posts', require('./routes/posts'));
app.use('/api/events', require('./routes/events'));
app.use('/api/learning', require('./routes/learning'));
app.use('/api/miles', require('./routes/miles'));
app.use('/api/shop', require('./routes/shop'));

// ヘルスチェック
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'ECG Community API is running' });
});

// エラーハンドリング
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'サーバーエラーが発生しました' });
});

// 初期データのセットアップ
const initializeDatabase = require('./utils/initialize');
initializeDatabase();

app.listen(PORT, () => {
  console.log(`サーバーがポート${PORT}で起動しました`);
});

