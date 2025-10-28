const express = require('express');
const router = express.Router();
const LearningArticle = require('../models/LearningArticle');
const MileTransaction = require('../models/MileTransaction');
const User = require('../models/User');
const { authenticate, requireRole } = require('../middleware/auth');

// 学習記事一覧取得
router.get('/', authenticate, async (req, res) => {
  try {
    const { category } = req.query;
    
    let query = {};
    if (category && category !== 'すべて') {
      query.category = category;
    }

    const articles = await LearningArticle.find(query)
      .populate('createdBy', 'username')
      .sort({ createdAt: -1 });

    // 各記事に対して現在のユーザーが完了したかどうかを追加
    const articlesWithCompletion = articles.map(article => {
      const completion = article.completedBy.find(
        c => c.user.toString() === req.user._id.toString()
      );
      return {
        ...article.toObject(),
        isCompleted: !!completion,
        userRating: completion?.comprehensionRating
      };
    });

    res.json({ articles: articlesWithCompletion });
  } catch (error) {
    console.error('学習記事一覧取得エラー:', error);
    res.status(500).json({ error: '学習記事一覧の取得に失敗しました' });
  }
});

// 学習記事詳細取得
router.get('/:articleId', authenticate, async (req, res) => {
  try {
    const article = await LearningArticle.findById(req.params.articleId)
      .populate('createdBy', 'username');

    if (!article) {
      return res.status(404).json({ error: '学習記事が見つかりません' });
    }

    const completion = article.completedBy.find(
      c => c.user.toString() === req.user._id.toString()
    );

    res.json({ 
      article: {
        ...article.toObject(),
        isCompleted: !!completion,
        userRating: completion?.comprehensionRating
      }
    });
  } catch (error) {
    console.error('学習記事詳細取得エラー:', error);
    res.status(500).json({ error: '学習記事詳細の取得に失敗しました' });
  }
});

// 学習記事作成（管理者のみ）
router.post('/', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const { title, subtitle, coverImageUrl, category, contentUrl, milesReward } = req.body;

    const article = new LearningArticle({
      title,
      subtitle,
      coverImageUrl,
      category,
      contentUrl,
      milesReward: milesReward || 0,
      createdBy: req.user._id
    });

    await article.save();
    
    const populatedArticle = await LearningArticle.findById(article._id)
      .populate('createdBy', 'username');

    res.status(201).json({ message: '学習記事を作成しました', article: populatedArticle });
  } catch (error) {
    console.error('学習記事作成エラー:', error);
    res.status(500).json({ error: '学習記事の作成に失敗しました' });
  }
});

// 学習記事更新（管理者のみ）
router.put('/:articleId', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const { title, subtitle, coverImageUrl, category, contentUrl, milesReward } = req.body;
    
    const article = await LearningArticle.findByIdAndUpdate(
      req.params.articleId,
      { title, subtitle, coverImageUrl, category, contentUrl, milesReward },
      { new: true }
    ).populate('createdBy', 'username');

    if (!article) {
      return res.status(404).json({ error: '学習記事が見つかりません' });
    }

    res.json({ message: '学習記事を更新しました', article });
  } catch (error) {
    console.error('学習記事更新エラー:', error);
    res.status(500).json({ error: '学習記事の更新に失敗しました' });
  }
});

// 学習記事削除（管理者のみ）
router.delete('/:articleId', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const article = await LearningArticle.findByIdAndDelete(req.params.articleId);
    
    if (!article) {
      return res.status(404).json({ error: '学習記事が見つかりません' });
    }

    res.json({ message: '学習記事を削除しました' });
  } catch (error) {
    console.error('学習記事削除エラー:', error);
    res.status(500).json({ error: '学習記事の削除に失敗しました' });
  }
});

// 学習記事完了とMile獲得
router.post('/:articleId/complete', authenticate, async (req, res) => {
  try {
    const { comprehensionRating } = req.body;
    
    const article = await LearningArticle.findById(req.params.articleId);
    
    if (!article) {
      return res.status(404).json({ error: '学習記事が見つかりません' });
    }

    // 既に完了済みかチェック
    const alreadyCompleted = article.completedBy.some(
      c => c.user.toString() === req.user._id.toString()
    );

    if (alreadyCompleted) {
      return res.status(400).json({ error: 'この記事は既に完了済みです' });
    }

    // 完了記録を追加
    article.completedBy.push({
      user: req.user._id,
      comprehensionRating: comprehensionRating || 5
    });

    await article.save();

    // Mileを付与
    if (article.milesReward > 0) {
      const user = await User.findById(req.user._id);
      user.miles += article.milesReward;
      await user.save();

      // Mile取引履歴を記録
      const transaction = new MileTransaction({
        user: req.user._id,
        amount: article.milesReward,
        type: 'earn',
        description: `学習記事「${article.title}」を完了`,
        relatedId: article._id,
        relatedType: 'learning'
      });
      await transaction.save();
    }

    res.json({ 
      message: '学習記事を完了しました',
      milesEarned: article.milesReward
    });
  } catch (error) {
    console.error('学習記事完了エラー:', error);
    res.status(500).json({ error: '学習記事の完了処理に失敗しました' });
  }
});

module.exports = router;

