const express = require('express');
const router = express.Router();
const Category = require('../models/Category');
const { authenticate, requireRole } = require('../middleware/auth');

// 全カテゴリ取得
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
router.post('/', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const { name, description, order } = req.body;

    const category = new Category({
      name,
      description,
      order: order || 0
    });

    await category.save();
    res.status(201).json({ message: 'カテゴリを作成しました', category });
  } catch (error) {
    console.error('カテゴリ作成エラー:', error);
    res.status(500).json({ error: 'カテゴリの作成に失敗しました' });
  }
});

// カテゴリ更新（管理者のみ）
router.put('/:categoryId', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const { name, description, order } = req.body;
    
    const category = await Category.findByIdAndUpdate(
      req.params.categoryId,
      { name, description, order },
      { new: true }
    );

    if (!category) {
      return res.status(404).json({ error: 'カテゴリが見つかりません' });
    }

    res.json({ message: 'カテゴリを更新しました', category });
  } catch (error) {
    console.error('カテゴリ更新エラー:', error);
    res.status(500).json({ error: 'カテゴリの更新に失敗しました' });
  }
});

// カテゴリ削除（管理者のみ）
router.delete('/:categoryId', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const category = await Category.findByIdAndDelete(req.params.categoryId);
    
    if (!category) {
      return res.status(404).json({ error: 'カテゴリが見つかりません' });
    }

    // このカテゴリに属するチャンネルも削除
    const Channel = require('../models/Channel');
    await Channel.deleteMany({ category: req.params.categoryId });

    res.json({ message: 'カテゴリを削除しました' });
  } catch (error) {
    console.error('カテゴリ削除エラー:', error);
    res.status(500).json({ error: 'カテゴリの削除に失敗しました' });
  }
});

module.exports = router;

