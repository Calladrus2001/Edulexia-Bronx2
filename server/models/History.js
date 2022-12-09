const mongoose = require("mongoose");

const History = mongoose.model("History", {
  userID: {
    type: String,
    required: true,
    trim: true,
  },
  details: [
    {
      message: {
        type: String,
        required: true,
      },
      type: {
        type: String,
        required: true,
      },
      time: {
        type: String,
        required: true
      },
      cost: {
        type: Number,
        required: true
      }
    },
  ],
});

module.exports = History;
