const express = require('express');
const router = express.Router();
const Event = require('../models/Event');
const { authenticate, requireRole } = require('../middleware/auth');

// イベント一覧取得
router.get('/', authenticate, async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    let query = {};
    if (startDate && endDate) {
      query.date = {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      };
    }

    const events = await Event.find(query)
      .populate('createdBy', 'username')
      .populate('participants.user', 'username profile.avatarUrl')
      .sort({ date: 1 });

    res.json({ events });
  } catch (error) {
    console.error('イベント一覧取得エラー:', error);
    res.status(500).json({ error: 'イベント一覧の取得に失敗しました' });
  }
});

// イベント詳細取得
router.get('/:eventId', authenticate, async (req, res) => {
  try {
    const event = await Event.findById(req.params.eventId)
      .populate('createdBy', 'username')
      .populate('participants.user', 'username profile.avatarUrl');

    if (!event) {
      return res.status(404).json({ error: 'イベントが見つかりません' });
    }

    // 現在のユーザーが参加登録しているかチェック
    const isParticipating = event.participants.some(
      p => p.user._id.toString() === req.user._id.toString()
    );

    res.json({ 
      event: {
        ...event.toObject(),
        isParticipating
      }
    });
  } catch (error) {
    console.error('イベント詳細取得エラー:', error);
    res.status(500).json({ error: 'イベント詳細の取得に失敗しました' });
  }
});

// イベント作成（管理者のみ）
router.post('/', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const { title, description, flyerImageUrl, date, venue, pricing } = req.body;

    const event = new Event({
      title,
      description,
      flyerImageUrl,
      date,
      venue,
      pricing,
      createdBy: req.user._id
    });

    await event.save();
    
    const populatedEvent = await Event.findById(event._id)
      .populate('createdBy', 'username')
      .populate('participants.user', 'username profile.avatarUrl');

    res.status(201).json({ message: 'イベントを作成しました', event: populatedEvent });
  } catch (error) {
    console.error('イベント作成エラー:', error);
    res.status(500).json({ error: 'イベントの作成に失敗しました' });
  }
});

// イベント更新（管理者のみ）
router.put('/:eventId', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const { title, description, flyerImageUrl, date, venue, pricing } = req.body;
    
    const event = await Event.findByIdAndUpdate(
      req.params.eventId,
      { title, description, flyerImageUrl, date, venue, pricing },
      { new: true }
    )
    .populate('createdBy', 'username')
    .populate('participants.user', 'username profile.avatarUrl');

    if (!event) {
      return res.status(404).json({ error: 'イベントが見つかりません' });
    }

    res.json({ message: 'イベントを更新しました', event });
  } catch (error) {
    console.error('イベント更新エラー:', error);
    res.status(500).json({ error: 'イベントの更新に失敗しました' });
  }
});

// イベント削除（管理者のみ）
router.delete('/:eventId', authenticate, requireRole(['管理者']), async (req, res) => {
  try {
    const event = await Event.findByIdAndDelete(req.params.eventId);
    
    if (!event) {
      return res.status(404).json({ error: 'イベントが見つかりません' });
    }

    res.json({ message: 'イベントを削除しました' });
  } catch (error) {
    console.error('イベント削除エラー:', error);
    res.status(500).json({ error: 'イベントの削除に失敗しました' });
  }
});

// イベント参加登録/キャンセル
router.post('/:eventId/participate', authenticate, async (req, res) => {
  try {
    const event = await Event.findById(req.params.eventId);
    
    if (!event) {
      return res.status(404).json({ error: 'イベントが見つかりません' });
    }

    const participantIndex = event.participants.findIndex(
      p => p.user.toString() === req.user._id.toString()
    );

    if (participantIndex > -1) {
      // 既に参加登録している場合はキャンセル
      event.participants.splice(participantIndex, 1);
    } else {
      // 参加登録
      event.participants.push({
        user: req.user._id
      });
    }

    await event.save();
    
    const updatedEvent = await Event.findById(event._id)
      .populate('createdBy', 'username')
      .populate('participants.user', 'username profile.avatarUrl');

    const isParticipating = updatedEvent.participants.some(
      p => p.user._id.toString() === req.user._id.toString()
    );

    res.json({ 
      message: isParticipating ? 'イベントに参加登録しました' : '参加をキャンセルしました',
      event: {
        ...updatedEvent.toObject(),
        isParticipating
      }
    });
  } catch (error) {
    console.error('参加登録エラー:', error);
    res.status(500).json({ error: '参加登録の処理に失敗しました' });
  }
});

module.exports = router;

