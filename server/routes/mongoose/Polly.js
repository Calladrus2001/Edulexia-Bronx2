const {StartSpeechSynthesisTaskCommand} = require("@aws-sdk/client-polly");
const pollyClient = require("../../models/pollyClient");
const express = require("express");
const router = express.Router();
const bodyParser = require("body-parser");
const mongoose = require("mongoose");

const Audio = require("../../models/Audio");
const History = require("../../models/History");
const { createNewAudioFile } = require("../../hedera/contract");

router.use(
  bodyParser.urlencoded({
    extended: true,
  })
);
router.use(bodyParser.json());

var params = {
  Engine: "standard",
  // LanguageCode: hindi
  LanguageCode: "en-US",
  OutputFormat: "mp3",
  OutputS3BucketName: "vishesh-code-star",
  SampleRate: "22050",
  Text: "This will be replaced by text in the request body",
  TextType: "text",
  VoiceId: "Joanna",
};

mongoose.connect("mongodb://127.0.0.1:27017/CodeStar", {
  useNewUrlParser: true,
  autoIndex: true,
});

router.post("/synthAudio", async (req, res) => {
  const userID = req.body.userID;
  const name = req.body.name;
  const time = req.body.time;
  params.Text = req.body.text;

  await pollyClient
    .send(new StartSpeechSynthesisTaskCommand(params))
    .then((response) => {
      const downloadUrl = response.SynthesisTask.OutputUri;
      addAudio(userID, name, time, downloadUrl);
    })
    .catch((err) => {
      console.log(err);
      return res.sendStatus(500);
    });

  res.sendStatus(200);
});

router.get("/getAudio", async (req, res) => {
  const userID = req.query.userID;
  const audiofiles = await Audio.findOne({ userID });
  if (!audiofiles)
    return res.send({
      message: "No files found",
    });
  else {
    res.send({
      audioFiles: audiofiles.audioDetails,
    });
  }
});

async function addAudio(_userID, _name, _time, _url) {
  var audioID;
  const audiofile = await Audio.findOne({ userID: _userID });
  if (!audiofile) {
    var audioFile = new Audio({
      userID: _userID,
      audioDetails: [
        {
          name: _name,
          downloadUrl: _url,
          time: _time,
        },
      ],
    });
    audioFile
      .save()
      .then(() => {
        audioID = audioFile.id;
      })
      .catch((error) => {
        console.log(error + "line 65");
      });
    try {
      await createNewAudioFile(_userID);
      await addNewExpense(_name, "Expense", 50, _userID);
    } catch (e) {
      console.log(e.message + "line 72");
    }
  } else {
    audiofile.audioDetails.push({
      name: _name,
      downloadUrl: _url,
      time: _time,
    });
    audiofile
      .save()
      .then(() => {
        audioID = audiofile.id;
      })
      .catch((e) => {
        console.log(e.message);
      });
    try {
      await createNewAudioFile(_userID);
      await addNewExpense(_name, "Expense", 50, _userID);
    } catch (e) {
      console.log(e.message);
    }
  }
}

async function addNewExpense(name, typeOf, amount, userID) {
  const amt = Number(amount);
  const historyInstance = await History.findOne({
    userID,
  });
  if (!historyInstance) {
    var newHistory = new History({
      userID: userID,
      details: [
        {
          message: `Created new Audiobook: ${name}`,
          type: typeOf,
          time: Date.now().toLocaleString("en-us", {
            timeZone: "IST",
          }),
          cost: amt,
        },
      ],
    });
    newHistory.save();
  } else {
    historyInstance.details.push({
      message: `Created new Audiobook: ${name}`,
      type: typeOf,
      time: Date.now().toLocaleString("en-us", {
        timeZone: "IST",
      }),
      cost: amt,
    });
    historyInstance.save();
  }
}

module.exports = router;