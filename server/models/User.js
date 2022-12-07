const mongoose = require('mongoose');

const User = mongoose.model('User',{
  userName: {
    type: String,
    required: true,
    trim: true
  },
  password: {
    type: String,
    required: true,
    trim: true
  }
});

module.exports = User;