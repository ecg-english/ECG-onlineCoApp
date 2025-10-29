const express = require('express');
const router = express.Router();
const Channel = require('../models/Channel');
const Category = require('../models/Category');
const Role = require('../models/Role');
const { authenticate, requireAdmin } = require('../middleware/auth');

// チャンネル一覧取得
router.get('/', authenticate, async (req, res) => {
  try {
    const channels = await Channel.find()
      .populate('category', 'name description order')
      .populate('viewPermissions', 'name description')
      .populate('postPermissions', 'name description')
      .sort({ 'category.order': 1, order: 1 });
    
    res.json({ channels });
  } catch (error) {
    console.error('チャンネル一覧取得エラー:', error);
    res.status(500).json({ error: 'チャンネル一覧の取得に失敗しました' });
  }
});

// チャンネル作成（管理者のみ）
router.post('/', authenticate, requireAdmin, async (req, res) => {
  try {
    const { name, description, categoryId, viewPermissions, postPermissions, order } = req.body;

    if (!name || !categoryId) {
      return res.status(400).json({ error: 'チャンネル名とカテゴリIDは必須です' });
    }

    // カテゴリの存在確認
    const category = await Category.findById(categoryId);
    if (!category) {
      return res.status(404).json({ error: 'カテゴリが見つかりません' });
    }

    // ロールの存在確認
    const allRoleIds = [...(viewPermissions || []), ...(postPermissions || [])];
    const roles = await Role.find({ _id: { $in: allRoleIds } });
    if (roles.length !== allRoleIds.length) {
      return res.status(400).json({ error: '無効なロールIDが含まれています' });
    }

    const channel = await Channel.create({
      name,
      description: description || '',
      category: categoryId,
      viewPermissions: viewPermissions || [],
      postPermissions: postPermissions || [],
      order: order || 0
    });

    const populatedChannel = await Channel.findById(channel._id)
      .populate('category', 'name description order')
      .populate('viewPermissions', 'name description')
      .populate('postPermissions', 'name description');

    res.status(201).json({ message: 'チャンネルを作成しました', channel: populatedChannel });
  } catch (error) {
    console.error('チャンネル作成エラー:', error);
    res.status(500).json({ error: 'チャンネルの作成に失敗しました' });
  }
});

// チャンネル編集（管理者のみ）
router.put('/:channelId', authenticate, requireAdmin, async (req, res) => {
  try {
    const { name, description, categoryId, viewPermissions, postPermissions, order } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'チャンネル名は必須です' });
    }

    // カテゴリの存在確認（categoryIdが提供されている場合）
    if (categoryId) {
      const category = await Category.findById(categoryId);
      if (!category) {
        return res.status(404).json({ error: 'カテゴリが見つかりません' });
      }
    }

    // ロールの存在確認
    const allRoleIds = [...(viewPermissions || []), ...(postPermissions || [])];
    if (allRoleIds.length > 0) {
      const roles = await Role.find({ _id: { $in: allRoleIds } });
      if (roles.length !== allRoleIds.length) {
        return res.status(400).json({ error: '無効なロールIDが含まれています' });
      }
    }

    const updateData = { name, description, order };
    if (categoryId) updateData.category = categoryId;
    if (viewPermissions) updateData.viewPermissions = viewPermissions;
    if (postPermissions) updateData.postPermissions = postPermissions;

    const channel = await Channel.findByIdAndUpdate(
      req.params.channelId,
      updateData,
      { new: true }
    );

    if (!channel) {
      return res.status(404).json({ error: 'チャンネルが見つかりません' });
    }

    const populatedChannel = await Channel.findById(channel._id)
      .populate('category', 'name description order')
      .populate('viewPermissions', 'name description')
      .populate('postPermissions', 'name description');

    res.json({ message: 'チャンネルを編集しました', channel: populatedChannel });
  } catch (error) {
    console.error('チャンネル編集エラー:', error);
    res.status(500).json({ error: 'チャンネルの編集に失敗しました' });
  }
});

// チャンネル削除（管理者のみ）
router.delete('/:channelId', authenticate, requireAdmin, async (req, res) => {
  try {
    const channel = await Channel.findById(req.params.channelId);

    if (!channel) {
      return res.status(404).json({ error: 'チャンネルが見つかりません' });
    }

    // TODO: チャンネルに投稿があるかチェックして、投稿がある場合は警告を出す
    // const posts = await Post.find({ channel: req.params.channelId });
    // if (posts.length > 0) {
    //   return res.status(400).json({ 
    //     error: 'このチャンネルには投稿が含まれています。先に投稿を削除してください。' 
    //   });
    // }

    await Channel.findByIdAndDelete(req.params.channelId);
    res.json({ message: 'チャンネルを削除しました' });
  } catch (error) {
    console.error('チャンネル削除エラー:', error);
    res.status(500).json({ error: 'チャンネルの削除に失敗しました' });
  }
});

module.exports = router;