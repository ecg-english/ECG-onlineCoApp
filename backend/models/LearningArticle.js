const mongoose = require('mongoose');

const learningArticleSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  subtitle: {
    type: String,
    default: ''
  },
  coverImageUrl: {
    type: String,
    default: ''
  },
  category: {
    type: String,
    enum: ['英語学習', 'コミュニケーション', '異文化理解', '他言語', 'モチベーション'],
    required: true
  },
  contentUrl: {
    type: String,
    required: true
  },
  milesReward: {
    type: Number,
    default: 0
  },
  completedBy: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    completedAt: {
      type: Date,
      default: Date.now
    },
    comprehensionRating: {
      type: Number,
      min: 1,
      max: 5
    }
  }],
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('LearningArticle', learningArticleSchema);

