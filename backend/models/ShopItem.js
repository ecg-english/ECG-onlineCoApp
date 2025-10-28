const mongoose = require('mongoose');

const shopItemSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    default: ''
  },
  imageUrl: {
    type: String,
    default: ''
  },
  mileCost: {
    type: Number,
    required: true
  },
  type: {
    type: String,
    enum: ['discount_ticket', 'material', 'other'],
    required: true
  },
  discountValue: {
    type: Number,
    default: 0
  },
  stock: {
    type: Number,
    default: -1 // -1 = 無制限
  },
  active: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('ShopItem', shopItemSchema);

