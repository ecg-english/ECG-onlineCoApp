const express = require('express');
const router = express.Router();
const MileTransaction = require('../models/MileTransaction');
const User = require('../models/User');
const { authenticate } = require('../middleware/auth');

// 自分のMile残高取得
router.get('/balance', authenticate, async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('miles');
    res.json({ miles: user.miles });
  } catch (error) {
    console.error('Mile残高取得エラー:', error);
    res.status(500).json({ error: 'Mile残高の取得に失敗しました' });
  }
});

// 自分のMile取引履歴取得
router.get('/transactions', authenticate, async (req, res) => {
  try {
    const transactions = await MileTransaction.find({ user: req.user._id })
      .sort({ createdAt: -1 })
      .limit(100);

    res.json({ transactions });
  } catch (error) {
    console.error('Mile取引履歴取得エラー:', error);
    res.status(500).json({ error: 'Mile取引履歴の取得に失敗しました' });
  }
});

// Mile購入（Stripe連携予定）
router.post('/purchase', authenticate, async (req, res) => {
  try {
    const { amount, paymentIntentId } = req.body;

    // TODO: Stripe Payment Intent検証

    // 仮実装: Mileを付与
    const user = await User.findById(req.user._id);
    user.miles += amount;
    await user.save();

    // 取引履歴を記録
    const transaction = new MileTransaction({
      user: req.user._id,
      amount,
      type: 'purchase',
      description: `Mile購入 (${amount}Mile)`,
      relatedType: 'other'
    });
    await transaction.save();

    res.json({ 
      message: 'Mileを購入しました',
      miles: user.miles
    });
  } catch (error) {
    console.error('Mile購入エラー:', error);
    res.status(500).json({ error: 'Mile購入に失敗しました' });
  }
});

// Mile使用
router.post('/spend', authenticate, async (req, res) => {
  try {
    const { amount, description, relatedId, relatedType } = req.body;

    const user = await User.findById(req.user._id);
    
    if (user.miles < amount) {
      return res.status(400).json({ error: 'Mileが不足しています' });
    }

    user.miles -= amount;
    await user.save();

    // 取引履歴を記録
    const transaction = new MileTransaction({
      user: req.user._id,
      amount,
      type: 'spend',
      description,
      relatedId,
      relatedType
    });
    await transaction.save();

    res.json({ 
      message: 'Mileを使用しました',
      miles: user.miles
    });
  } catch (error) {
    console.error('Mile使用エラー:', error);
    res.status(500).json({ error: 'Mile使用に失敗しました' });
  }
});

module.exports = router;

