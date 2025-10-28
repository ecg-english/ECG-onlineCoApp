const express = require('express');
const router = express.Router();
const ShopItem = require('../models/ShopItem');
const { authenticate, requireRole } = require('../middleware/auth');

// ショップアイテム一覧取得
router.get('/', authenticate, async (req, res) => {
  try {
    const items = await ShopItem.find({ active: true })
      .sort({ createdAt: -1 });

    res.json({ items });
  } catch (error) {
    console.error('ショップアイテム一覧取得エラー:', error);
    res.status(500).json({ error: 'ショップアイテム一覧の取得に失敗しました' });
  }
});

// 全ショップアイテム取得（管理者のみ）
router.get('/all', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const items = await ShopItem.find().sort({ createdAt: -1 });
    res.json({ items });
  } catch (error) {
    console.error('全ショップアイテム取得エラー:', error);
    res.status(500).json({ error: '全ショップアイテムの取得に失敗しました' });
  }
});

// ショップアイテム作成（管理者のみ）
router.post('/', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const { name, description, imageUrl, mileCost, type, discountValue, stock } = req.body;

    const item = new ShopItem({
      name,
      description,
      imageUrl,
      mileCost,
      type,
      discountValue: discountValue || 0,
      stock: stock !== undefined ? stock : -1
    });

    await item.save();
    res.status(201).json({ message: 'ショップアイテムを作成しました', item });
  } catch (error) {
    console.error('ショップアイテム作成エラー:', error);
    res.status(500).json({ error: 'ショップアイテムの作成に失敗しました' });
  }
});

// ショップアイテム更新（管理者のみ）
router.put('/:itemId', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const { name, description, imageUrl, mileCost, type, discountValue, stock, active } = req.body;
    
    const item = await ShopItem.findByIdAndUpdate(
      req.params.itemId,
      { name, description, imageUrl, mileCost, type, discountValue, stock, active },
      { new: true }
    );

    if (!item) {
      return res.status(404).json({ error: 'ショップアイテムが見つかりません' });
    }

    res.json({ message: 'ショップアイテムを更新しました', item });
  } catch (error) {
    console.error('ショップアイテム更新エラー:', error);
    res.status(500).json({ error: 'ショップアイテムの更新に失敗しました' });
  }
});

// ショップアイテム削除（管理者のみ）
router.delete('/:itemId', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const item = await ShopItem.findByIdAndDelete(req.params.itemId);
    
    if (!item) {
      return res.status(404).json({ error: 'ショップアイテムが見つかりません' });
    }

    res.json({ message: 'ショップアイテムを削除しました' });
  } catch (error) {
    console.error('ショップアイテム削除エラー:', error);
    res.status(500).json({ error: 'ショップアイテムの削除に失敗しました' });
  }
});

// ショップアイテム購入
router.post('/:itemId/purchase', authenticate, async (req, res) => {
  try {
    const item = await ShopItem.findById(req.params.itemId);
    
    if (!item) {
      return res.status(404).json({ error: 'ショップアイテムが見つかりません' });
    }

    if (!item.active) {
      return res.status(400).json({ error: 'このアイテムは現在購入できません' });
    }

    if (item.stock === 0) {
      return res.status(400).json({ error: 'このアイテムは在庫切れです' });
    }

    const User = require('../models/User');
    const user = await User.findById(req.user._id);

    if (user.miles < item.mileCost) {
      return res.status(400).json({ error: 'Mileが不足しています' });
    }

    // Mileを消費
    user.miles -= item.mileCost;
    await user.save();

    // 在庫を減らす（無制限でない場合）
    if (item.stock > 0) {
      item.stock -= 1;
      await item.save();
    }

    // Mile取引履歴を記録
    const MileTransaction = require('../models/MileTransaction');
    const transaction = new MileTransaction({
      user: req.user._id,
      amount: item.mileCost,
      type: 'spend',
      description: `「${item.name}」を購入`,
      relatedId: item._id,
      relatedType: 'shop'
    });
    await transaction.save();

    res.json({ 
      message: 'アイテムを購入しました',
      item,
      remainingMiles: user.miles
    });
  } catch (error) {
    console.error('アイテム購入エラー:', error);
    res.status(500).json({ error: 'アイテムの購入に失敗しました' });
  }
});

module.exports = router;

