const mongoose = require("mongoose");

const Audio = mongoose.model("Audio", {
  userID: {
    type: String,
    required: true,
    trim: true,
  },
  audioDetails: [
    {
      name: {
        type: String,
        required: true,
      },
      downloadUrl: {
        type: String,
        required: true,
        trim: true,
      },
      time: {
        type: String,
      },
    },
  ],
});

module.exports = Audio;
