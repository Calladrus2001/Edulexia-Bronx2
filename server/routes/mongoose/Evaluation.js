const express = require('express');
const router = express.Router();
const bodyParser = require("body-parser");
const History = require("../../models/History");
const {evaluateYourself} = require("../../hedera/contract");
const {sentences, urls} = require('../../models/Evaluation');

router.use(
  bodyParser.urlencoded({
    extended: true,
  })
);
router.use(bodyParser.json());

router.get("/eval", (req, res)=>{
  const userID = req.query.userID;
  const type = req.query.type;
  try {
    // evaluateYourself(userID);
    // addNewExpense(type, "Expense", 20, userID);
  }
  catch(e){
    console.log(e);
    return res.sendStatus(500);
  }
  if (type == "Reading"){
    const random = get3Random(sentences);
    return res.send({
    "sentences" : random
  });
  }
  else if (type == "Writing"){
    return res.send({
      "urls" : urls
    });
  }
  else {
    return res.sendStatus(404);
  }
});

function get3Random(array){
  const arr = [];
  var flag = 0;
  for (i = 0; i < 3; i++){
    var idx = Math.floor(Math.random() * array.length);
    for (j = 0; j < arr.length; j++){
      if (array[idx] == arr[j]){
        i -= 1;
        flag = 1;
        break;
      }
    }
    if (flag == 0) arr.push(array[idx]);
    flag = 0;
  }
  return arr;
}

async function addNewExpense(test, typeOf, amount, userID) {
  const amt = Number(amount);
  const historyInstance = await History.findOne({
    userID,
  });
  if (!historyInstance) {
    var newHistory = new History({
      "userID": userID,
      details: [
        {
          message: `Attempted ${test} test`,
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
      message: `Attempted ${test} test`,
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