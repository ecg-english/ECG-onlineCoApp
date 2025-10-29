const express = require('express');
const router = express.Router();
const Category = require('../models/Category');
const Channel = require('../models/Channel');
const { authenticate, requireAdmin } = require('../middleware/auth');

// カテゴリ一覧取得
router.get('/', authenticate, async (req, res) => {
  try {
    const categories = await Category.find().sort({ order: 1 });
    res.json({ categories });
  } catch (error) {
    console.error('カテゴリ一覧取得エラー:', error);
    res.status(500).json({ error: 'カテゴリ一覧の取得に失敗しました' });
  }
});

// カテゴリ作成（管理者のみ）
router.post('/', authenticate, requireAdmin, async (req, res) => {
  try {
    const { name, description, order } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'カテゴリ名は必須です' });
    }

    const category = await Category.create({
      name,
      description: description || '',
      order: order || 0
    });

    res.status(201).json({ message: 'カテゴリを作成しました', category });
  } catch (error) {
    console.error('カテゴリ作成エラー:', error);
    res.status(500).json({ error: 'カテゴリの作成に失敗しました' });
  }
});

// カテゴリ編集（管理者のみ）
router.put('/:categoryId', authenticate, requireAdmin, async (req, res) => {
  try {
    const { name, description, order } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'カテゴリ名は必須です' });
    }

    const category = await Category.findByIdAndUpdate(
      req.params.categoryId,
      { name, description, order },
      { new: true }
    );

    if (!category) {
      return res.status(404).json({ error: 'カテゴリが見つかりません' });
    }

    res.json({ message: 'カテゴリを編集しました', category });
  } catch (error) {
    console.error('カテゴリ編集エラー:', error);
    res.status(500).json({ error: 'カテゴリの編集に失敗しました' });
  }
});

// カテゴリ削除（管理者のみ）
router.delete('/:categoryId', authenticate, requireAdmin, async (req, res) => {
  try {
    const category = await Category.findById(req.params.categoryId);

    if (!category) {
      return res.status(404).json({ error: 'カテゴリが見つかりません' });
    }

    // カテゴリに属するチャンネルがあるかチェック
    const channels = await Channel.find({ category: req.params.categoryId });
    if (channels.length > 0) {
      return res.status(400).json({ 
        error: 'このカテゴリにはチャンネルが含まれています。先にチャンネルを削除してください。' 
      });
    }

    await Category.findByIdAndDelete(req.params.categoryId);
    res.json({ message: 'カテゴリを削除しました' });
  } catch (error) {
    console.error('カテゴリ削除エラー:', error);
    res.status(500).json({ error: 'カテゴリの削除に失敗しました' });
  }
});

module.exports = router;