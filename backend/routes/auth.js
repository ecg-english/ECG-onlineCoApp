const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Role = require('../models/Role');
const { authenticate } = require('../middleware/auth');

// サインアップ
router.post('/signup', async (req, res) => {
  try {
    const { email, password, username } = req.body;

    // 既存ユーザーチェック
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'このメールアドレスは既に登録されています' });
    }

    // ビジターロールを取得
    const visitorRole = await Role.findOne({ name: 'ビジター' });
    if (!visitorRole) {
      return res.status(500).json({ error: 'ビジターロールが見つかりません' });
    }

    // 新規ユーザー作成
    const user = new User({
      email,
      password,
      username,
      roles: [visitorRole._id]
    });

    await user.save();

    // JWTトークン生成
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    // パスワードを除外してユーザー情報を返す
    const userResponse = await User.findById(user._id)
      .select('-password')
      .populate('roles');

    res.status(201).json({
      message: 'アカウントが作成されました',
      token,
      user: userResponse
    });
  } catch (error) {
    console.error('サインアップエラー:', error);
    res.status(500).json({ error: 'サインアップに失敗しました' });
  }
});

// ログイン
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // ユーザー検索
    const user = await User.findOne({ email }).populate('roles');
    if (!user) {
      return res.status(401).json({ error: 'メールアドレスまたはパスワードが正しくありません' });
    }

    // パスワード検証
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'メールアドレスまたはパスワードが正しくありません' });
    }

    // 最終ログイン日時を更新
    user.lastLoginAt = new Date();
    await user.save();

    // JWTトークン生成
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    // パスワードを除外してユーザー情報を返す
    const userResponse = user.toObject();
    delete userResponse.password;

    res.json({
      message: 'ログインしました',
      token,
      user: userResponse
    });
  } catch (error) {
    console.error('ログインエラー:', error);
    res.status(500).json({ error: 'ログインに失敗しました' });
  }
});

// 現在のユーザー情報取得
router.get('/me', authenticate, async (req, res) => {
  try {
    const user = await User.findById(req.user._id)
      .select('-password')
      .populate('roles');
    
    res.json({ user });
  } catch (error) {
    console.error('ユーザー情報取得エラー:', error);
    res.status(500).json({ error: 'ユーザー情報の取得に失敗しました' });
  }
});

// トークン検証
router.post('/verify', authenticate, async (req, res) => {
  res.json({ valid: true, user: req.user });
});

module.exports = router;

