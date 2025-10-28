const express = require('express');
const router = express.Router();
const Channel = require('../models/Channel');
const { authenticate, requireRole } = require('../middleware/auth');

// ユーザーが閲覧可能なチャンネル一覧取得
router.get('/', authenticate, async (req, res) => {
  try {
    const userRoleIds = req.user.roles.map(role => role._id.toString());
    
    const channels = await Channel.find()
      .populate('category')
      .populate('viewPermissions')
      .populate('postPermissions')
      .sort({ order: 1 });

    // ユーザーが閲覧権限を持つチャンネルのみフィルタリング
    const accessibleChannels = channels.filter(channel => {
      return channel.viewPermissions.some(role => 
        userRoleIds.includes(role._id.toString())
      );
    });

    // チャンネルごとに投稿権限があるかどうかを追加
    const channelsWithPermissions = accessibleChannels.map(channel => {
      const canPost = channel.postPermissions.some(role => 
        userRoleIds.includes(role._id.toString())
      );
      return {
        ...channel.toObject(),
        canPost
      };
    });

    res.json({ channels: channelsWithPermissions });
  } catch (error) {
    console.error('チャンネル一覧取得エラー:', error);
    res.status(500).json({ error: 'チャンネル一覧の取得に失敗しました' });
  }
});

// 全チャンネル取得（管理者のみ）
router.get('/all', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const channels = await Channel.find()
      .populate('category')
      .populate('viewPermissions')
      .populate('postPermissions')
      .sort({ order: 1 });

    res.json({ channels });
  } catch (error) {
    console.error('全チャンネル取得エラー:', error);
    res.status(500).json({ error: '全チャンネルの取得に失敗しました' });
  }
});

// チャンネル作成（管理者のみ）
router.post('/', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const { name, description, category, viewPermissions, postPermissions, order } = req.body;

    const channel = new Channel({
      name,
      description,
      category,
      viewPermissions: viewPermissions || [],
      postPermissions: postPermissions || [],
      order: order || 0
    });

    await channel.save();
    
    const populatedChannel = await Channel.findById(channel._id)
      .populate('category')
      .populate('viewPermissions')
      .populate('postPermissions');

    res.status(201).json({ message: 'チャンネルを作成しました', channel: populatedChannel });
  } catch (error) {
    console.error('チャンネル作成エラー:', error);
    res.status(500).json({ error: 'チャンネルの作成に失敗しました' });
  }
});

// チャンネル更新（管理者のみ）
router.put('/:channelId', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const { name, description, category, viewPermissions, postPermissions, order } = req.body;
    
    const channel = await Channel.findByIdAndUpdate(
      req.params.channelId,
      { name, description, category, viewPermissions, postPermissions, order },
      { new: true }
    )
    .populate('category')
    .populate('viewPermissions')
    .populate('postPermissions');

    if (!channel) {
      return res.status(404).json({ error: 'チャンネルが見つかりません' });
    }

    res.json({ message: 'チャンネルを更新しました', channel });
  } catch (error) {
    console.error('チャンネル更新エラー:', error);
    res.status(500).json({ error: 'チャンネルの更新に失敗しました' });
  }
});

// チャンネル削除（管理者のみ）
router.delete('/:channelId', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const channel = await Channel.findByIdAndDelete(req.params.channelId);
    
    if (!channel) {
      return res.status(404).json({ error: 'チャンネルが見つかりません' });
    }

    // このチャンネルの投稿も削除
    const Post = require('../models/Post');
    await Post.deleteMany({ channel: req.params.channelId });

    res.json({ message: 'チャンネルを削除しました' });
  } catch (error) {
    console.error('チャンネル削除エラー:', error);
    res.status(500).json({ error: 'チャンネルの削除に失敗しました' });
  }
});

module.exports = router;

