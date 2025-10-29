const express = require('express');
const router = express.Router();
const Post = require('../models/Post');
const { authenticate, canViewChannel, canPostToChannel } = require('../middleware/auth');

// チャンネルの投稿一覧取得
router.get('/channel/:channelId', authenticate, canViewChannel, async (req, res) => {
  try {
    const posts = await Post.find({ channel: req.params.channelId })
      .populate('author', 'username email profile roles miles registeredAt lastLoginAt pushNotificationSettings')
      .populate('likes', 'username profile.avatarUrl')
      .populate('comments.user', 'username profile.avatarUrl')
      .sort({ createdAt: -1 });

    res.json({ posts });
  } catch (error) {
    console.error('投稿一覧取得エラー:', error);
    res.status(500).json({ error: '投稿一覧の取得に失敗しました' });
  }
});

// 投稿作成
router.post('/', authenticate, canPostToChannel, async (req, res) => {
  try {
    const { channel, content, images } = req.body;

    const post = new Post({
      channel,
      author: req.user._id,
      content,
      images: images || []
    });

    await post.save();
    
    const populatedPost = await Post.findById(post._id)
      .populate('author', 'username profile.avatarUrl')
      .populate('likes', 'username profile.avatarUrl')
      .populate('comments.user', 'username profile.avatarUrl');

    res.status(201).json({ message: '投稿しました', post: populatedPost });
  } catch (error) {
    console.error('投稿作成エラー:', error);
    res.status(500).json({ error: '投稿の作成に失敗しました' });
  }
});

// 投稿編集（自分の投稿または管理者のみ）
router.put('/:postId', authenticate, async (req, res) => {
  try {
    const { content, images } = req.body;
    const post = await Post.findById(req.params.postId);
    
    if (!post) {
      return res.status(404).json({ error: '投稿が見つかりません' });
    }

    // 自分の投稿か管理者かチェック
    const isAuthor = post.author.toString() === req.user._id.toString();
    const isAdmin = req.user.roles.some(role => role.name === '管理者');

    if (!isAuthor && !isAdmin) {
      return res.status(403).json({ error: 'この投稿を編集する権限がありません' });
    }

    // 投稿を更新
    post.content = content;
    post.images = images || post.images;
    await post.save();
    
    const updatedPost = await Post.findById(post._id)
      .populate('author', 'username profile.avatarUrl')
      .populate('likes', 'username profile.avatarUrl')
      .populate('comments.user', 'username profile.avatarUrl');

    res.json({ message: '投稿を編集しました', post: updatedPost });
  } catch (error) {
    console.error('投稿編集エラー:', error);
    res.status(500).json({ error: '投稿の編集に失敗しました' });
  }
});

// 投稿削除（自分の投稿または管理者のみ）
router.delete('/:postId', authenticate, async (req, res) => {
  try {
    const post = await Post.findById(req.params.postId);
    
    if (!post) {
      return res.status(404).json({ error: '投稿が見つかりません' });
    }

    // 自分の投稿か管理者かチェック
    const isAuthor = post.author.toString() === req.user._id.toString();
    const isAdmin = req.user.roles.some(role => role.name === '管理者');

    if (!isAuthor && !isAdmin) {
      return res.status(403).json({ error: 'この投稿を削除する権限がありません' });
    }

    await Post.findByIdAndDelete(req.params.postId);
    res.json({ message: '投稿を削除しました' });
  } catch (error) {
    console.error('投稿削除エラー:', error);
    res.status(500).json({ error: '投稿の削除に失敗しました' });
  }
});

// いいね追加/削除
router.post('/:postId/like', authenticate, async (req, res) => {
  try {
    const post = await Post.findById(req.params.postId);
    
    if (!post) {
      return res.status(404).json({ error: '投稿が見つかりません' });
    }

    const likeIndex = post.likes.findIndex(
      userId => userId.toString() === req.user._id.toString()
    );

    if (likeIndex > -1) {
      // 既にいいねしている場合は削除
      post.likes.splice(likeIndex, 1);
    } else {
      // いいねを追加
      post.likes.push(req.user._id);
    }

    await post.save();
    
    const updatedPost = await Post.findById(post._id)
      .populate('author', 'username profile.avatarUrl')
      .populate('likes', 'username profile.avatarUrl')
      .populate('comments.user', 'username profile.avatarUrl');

    res.json({ message: 'いいねを更新しました', post: updatedPost });
  } catch (error) {
    console.error('いいね更新エラー:', error);
    res.status(500).json({ error: 'いいねの更新に失敗しました' });
  }
});

// コメント追加
router.post('/:postId/comment', authenticate, async (req, res) => {
  try {
    const { content } = req.body;
    
    const post = await Post.findById(req.params.postId);
    
    if (!post) {
      return res.status(404).json({ error: '投稿が見つかりません' });
    }

    post.comments.push({
      user: req.user._id,
      content
    });

    await post.save();
    
    const updatedPost = await Post.findById(post._id)
      .populate('author', 'username profile.avatarUrl')
      .populate('likes', 'username profile.avatarUrl')
      .populate('comments.user', 'username profile.avatarUrl');

    res.json({ message: 'コメントを追加しました', post: updatedPost });
  } catch (error) {
    console.error('コメント追加エラー:', error);
    res.status(500).json({ error: 'コメントの追加に失敗しました' });
  }
});

// コメント削除（自分のコメントまたは管理者のみ）
router.delete('/:postId/comment/:commentId', authenticate, async (req, res) => {
  try {
    const post = await Post.findById(req.params.postId);
    
    if (!post) {
      return res.status(404).json({ error: '投稿が見つかりません' });
    }

    const comment = post.comments.id(req.params.commentId);
    
    if (!comment) {
      return res.status(404).json({ error: 'コメントが見つかりません' });
    }

    // 自分のコメントか管理者かチェック
    const isAuthor = comment.user.toString() === req.user._id.toString();
    const isAdmin = req.user.roles.some(role => role.name === '管理者');

    if (!isAuthor && !isAdmin) {
      return res.status(403).json({ error: 'このコメントを削除する権限がありません' });
    }

    comment.remove();
    await post.save();
    
    const updatedPost = await Post.findById(post._id)
      .populate('author', 'username profile.avatarUrl')
      .populate('likes', 'username profile.avatarUrl')
      .populate('comments.user', 'username profile.avatarUrl');

    res.json({ message: 'コメントを削除しました', post: updatedPost });
  } catch (error) {
    console.error('コメント削除エラー:', error);
    res.status(500).json({ error: 'コメントの削除に失敗しました' });
  }
});

module.exports = router;

