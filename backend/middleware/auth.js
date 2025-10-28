const jwt = require('jsonwebtoken');
const User = require('../models/User');

// JWT認証ミドルウェア
exports.authenticate = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ error: '認証が必要です' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId).populate('roles');
    
    if (!user) {
      return res.status(401).json({ error: 'ユーザーが見つかりません' });
    }

    req.user = user;
    req.token = token;
    next();
  } catch (error) {
    res.status(401).json({ error: '認証に失敗しました' });
  }
};

// ロール確認ミドルウェア
exports.requireRole = (requiredRoles) => {
  return async (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({ error: '認証が必要です' });
      }

      const userRoleNames = req.user.roles.map(role => role.name);
      const hasRequiredRole = requiredRoles.some(role => userRoleNames.includes(role));

      if (!hasRequiredRole) {
        return res.status(403).json({ error: 'アクセス権限がありません' });
      }

      next();
    } catch (error) {
      res.status(500).json({ error: 'ロール確認エラー' });
    }
  };
};

// チャンネル閲覧権限確認
exports.canViewChannel = async (req, res, next) => {
  try {
    const Channel = require('../models/Channel');
    const channel = await Channel.findById(req.params.channelId).populate('viewPermissions');
    
    if (!channel) {
      return res.status(404).json({ error: 'チャンネルが見つかりません' });
    }

    const userRoleIds = req.user.roles.map(role => role._id.toString());
    const canView = channel.viewPermissions.some(role => 
      userRoleIds.includes(role._id.toString())
    );

    if (!canView) {
      return res.status(403).json({ error: 'このチャンネルを閲覧する権限がありません' });
    }

    req.channel = channel;
    next();
  } catch (error) {
    res.status(500).json({ error: 'チャンネル権限確認エラー' });
  }
};

// チャンネル投稿権限確認
exports.canPostToChannel = async (req, res, next) => {
  try {
    const Channel = require('../models/Channel');
    const channel = await Channel.findById(req.params.channelId || req.body.channel)
      .populate('postPermissions');
    
    if (!channel) {
      return res.status(404).json({ error: 'チャンネルが見つかりません' });
    }

    const userRoleIds = req.user.roles.map(role => role._id.toString());
    const canPost = channel.postPermissions.some(role => 
      userRoleIds.includes(role._id.toString())
    );

    if (!canPost) {
      return res.status(403).json({ error: 'このチャンネルに投稿する権限がありません' });
    }

    req.channel = channel;
    next();
  } catch (error) {
    res.status(500).json({ error: 'チャンネル権限確認エラー' });
  }
};

