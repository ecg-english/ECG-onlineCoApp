const mongoose = require('mongoose');

const channelSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    default: ''
  },
  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    required: true
  },
  viewPermissions: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Role'
  }],
  postPermissions: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Role'
  }],
  order: {
    type: Number,
    default: 0
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Channel', channelSchema);

