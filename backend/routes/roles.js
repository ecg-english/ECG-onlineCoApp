const express = require('express');
const router = express.Router();
const Role = require('../models/Role');
const { authenticate, requireRole } = require('../middleware/auth');

// 全ロール取得
router.get('/', authenticate, async (req, res) => {
  try {
    const roles = await Role.find().sort({ createdAt: 1 });
    res.json({ roles });
  } catch (error) {
    console.error('ロール一覧取得エラー:', error);
    res.status(500).json({ error: 'ロール一覧の取得に失敗しました' });
  }
});

// ロール作成（管理者のみ）
router.post('/', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const { name, description, permissions } = req.body;

    const existingRole = await Role.findOne({ name });
    if (existingRole) {
      return res.status(400).json({ error: 'このロール名は既に存在します' });
    }

    const role = new Role({
      name,
      description,
      permissions: permissions || []
    });

    await role.save();
    res.status(201).json({ message: 'ロールを作成しました', role });
  } catch (error) {
    console.error('ロール作成エラー:', error);
    res.status(500).json({ error: 'ロールの作成に失敗しました' });
  }
});

// ロール更新（管理者のみ）
router.put('/:roleId', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const { name, description, permissions } = req.body;
    
    const role = await Role.findByIdAndUpdate(
      req.params.roleId,
      { name, description, permissions },
      { new: true }
    );

    if (!role) {
      return res.status(404).json({ error: 'ロールが見つかりません' });
    }

    res.json({ message: 'ロールを更新しました', role });
  } catch (error) {
    console.error('ロール更新エラー:', error);
    res.status(500).json({ error: 'ロールの更新に失敗しました' });
  }
});

// ロール削除（管理者のみ）
router.delete('/:roleId', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const role = await Role.findByIdAndDelete(req.params.roleId);
    
    if (!role) {
      return res.status(404).json({ error: 'ロールが見つかりません' });
    }

    // このロールを持つユーザーからロールを削除
    const User = require('../models/User');
    await User.updateMany(
      { roles: req.params.roleId },
      { $pull: { roles: req.params.roleId } }
    );

    res.json({ message: 'ロールを削除しました' });
  } catch (error) {
    console.error('ロール削除エラー:', error);
    res.status(500).json({ error: 'ロールの削除に失敗しました' });
  }
});

module.exports = router;

