const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { authenticate, requireRole } = require('../middleware/auth');

// 全ユーザー取得（管理者のみ）
router.get('/', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const users = await User.find()
      .select('-password')
      .populate('roles')
      .sort({ registeredAt: -1 });
    
    res.json({ users });
  } catch (error) {
    console.error('ユーザー一覧取得エラー:', error);
    res.status(500).json({ error: 'ユーザー一覧の取得に失敗しました' });
  }
});

// メンバーリスト取得（ビジター以外）
router.get('/members', authenticate, async (req, res) => {
  try {
    // ビジターロールのIDを取得
    const Role = require('../models/Role');
    const visitorRole = await Role.findOne({ name: 'ビジター' });
    
    // 現在のユーザーがビジターかチェック
    const userRoleNames = req.user.roles.map(role => role.name);
    if (userRoleNames.includes('ビジター') && userRoleNames.length === 1) {
      return res.status(403).json({ error: 'メンバーリストを閲覧する権限がありません' });
    }

    // ビジターロールのみを持つユーザーを除外
    const members = await User.find()
      .select('username profile.avatarUrl registeredAt')
      .populate('roles');
    
    const filteredMembers = members.filter(member => {
      const roleNames = member.roles.map(role => role.name);
      return !(roleNames.includes('ビジター') && roleNames.length === 1);
    });

    res.json({ members: filteredMembers });
  } catch (error) {
    console.error('メンバーリスト取得エラー:', error);
    res.status(500).json({ error: 'メンバーリストの取得に失敗しました' });
  }
});

// 特定ユーザーの詳細取得
router.get('/:userId', authenticate, async (req, res) => {
  try {
    const user = await User.findById(req.params.userId)
      .select('-password')
      .populate('roles');
    
    if (!user) {
      return res.status(404).json({ error: 'ユーザーが見つかりません' });
    }

    res.json({ user });
  } catch (error) {
    console.error('ユーザー詳細取得エラー:', error);
    res.status(500).json({ error: 'ユーザー詳細の取得に失敗しました' });
  }
});

// プロフィール更新
router.put('/profile', authenticate, async (req, res) => {
  try {
    const { username, profile } = req.body;
    
    const updateData = {};
    if (username) updateData.username = username;
    if (profile) updateData.profile = { ...req.user.profile, ...profile };

    const user = await User.findByIdAndUpdate(
      req.user._id,
      updateData,
      { new: true }
    ).select('-password').populate('roles');

    res.json({ message: 'プロフィールを更新しました', user });
  } catch (error) {
    console.error('プロフィール更新エラー:', error);
    res.status(500).json({ error: 'プロフィールの更新に失敗しました' });
  }
});

// ユーザー削除（管理者のみ）
router.delete('/:userId', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.userId);
    
    if (!user) {
      return res.status(404).json({ error: 'ユーザーが見つかりません' });
    }

    res.json({ message: 'ユーザーを削除しました' });
  } catch (error) {
    console.error('ユーザー削除エラー:', error);
    res.status(500).json({ error: 'ユーザーの削除に失敗しました' });
  }
});

// 自分のアカウント削除
router.delete('/me/account', authenticate, async (req, res) => {
  try {
    await User.findByIdAndDelete(req.user._id);
    res.json({ message: 'アカウントを削除しました' });
  } catch (error) {
    console.error('アカウント削除エラー:', error);
    res.status(500).json({ error: 'アカウントの削除に失敗しました' });
  }
});

// ユーザーにロールを付与（管理者のみ）
router.post('/:userId/roles', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const { roleId } = req.body;
    
    const user = await User.findById(req.params.userId);
    if (!user) {
      return res.status(404).json({ error: 'ユーザーが見つかりません' });
    }

    if (!user.roles.includes(roleId)) {
      user.roles.push(roleId);
      await user.save();
    }

    const updatedUser = await User.findById(user._id)
      .select('-password')
      .populate('roles');

    res.json({ message: 'ロールを付与しました', user: updatedUser });
  } catch (error) {
    console.error('ロール付与エラー:', error);
    res.status(500).json({ error: 'ロールの付与に失敗しました' });
  }
});

// ユーザーからロールを剥奪（管理者のみ）
router.delete('/:userId/roles/:roleId', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) {
      return res.status(404).json({ error: 'ユーザーが見つかりません' });
    }

    user.roles = user.roles.filter(role => role.toString() !== req.params.roleId);
    await user.save();

    const updatedUser = await User.findById(user._id)
      .select('-password')
      .populate('roles');

    res.json({ message: 'ロールを剥奪しました', user: updatedUser });
  } catch (error) {
    console.error('ロール剥奪エラー:', error);
    res.status(500).json({ error: 'ロールの剥奪に失敗しました' });
  }
});

// プッシュ通知設定更新
router.put('/settings/notifications', authenticate, async (req, res) => {
  try {
    const { pushNotificationSettings } = req.body;
    
    const user = await User.findByIdAndUpdate(
      req.user._id,
      { pushNotificationSettings },
      { new: true }
    ).select('-password').populate('roles');

    res.json({ message: '通知設定を更新しました', user });
  } catch (error) {
    console.error('通知設定更新エラー:', error);
    res.status(500).json({ error: '通知設定の更新に失敗しました' });
  }
});

module.exports = router;

