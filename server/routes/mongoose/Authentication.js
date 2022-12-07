const express = require("express");
const router = express.Router();
const bodyParser = require("body-parser");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const User = require("../../models/User");
const { createNewUser } = require("../../hedera/contract");

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

router.post("/addUser", async (req, res) => {
  const userName = req.body.userName;
  const hashed = await bcrypt.hash(req.body.password, 7);

  const user = await User.findOne({ userName });
  if (user) return res.sendStatus(400);

  const newUser = new User({ userName: userName, password: hashed });

  newUser.save().catch((error) => {
    console.log(error);
    return res.send({
      error: "Some Error Occured",
    });
  });
  try {
    await createNewUser(newUser.id).then(() => {
      res.send({
        userID: newUser.id,
      });
    });
  } catch (e) {
    User.findByIdAndDelete(newUser.id);
    res.sendStatus(500);
  }
});

router.post("/login", async (req, res) => {
  const userName = req.body.userName;
  const password = req.body.password;

  const user = await User.findOne({ userName });
  if (!user) return res.sendStatus(404);
  else {
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.sendStatus(404);
  }
  res.send({
    userID: user.id,
  });
});

module.exports = router;
