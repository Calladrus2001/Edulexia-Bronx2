const mongoose = require("mongoose");
const History = require("../../models/History");
const express = require("express");
const router = express.Router();
const bodyParser = require("body-parser");

router.use(
  bodyParser.urlencoded({
    extended: true,
  })
);
router.use(bodyParser.json());

mongoose.connect("mongodb://127.0.0.1:27017/CodeStar", {
  useNewUrlParser: true,
  autoIndex: true,
});

router.get("/getHistory", async (req, res) => {
  const userID = req.query.userID;
  const historyInstance = await History.findOne({
    userID
  });
  if (!historyInstance) {
    console.log("No Expense History found");
    return res.sendStatus(404);
  } else {
    res.send({
      "History": historyInstance.details,
    });
  }
});

module.exports = router;
