const {hederaRouter, createNewUser, createNewAudioFile, getBalance} = require('./hedera/contract');
const express = require('express');
const app = express();
const authRouter = require("./routes/mongoose/Authentication");
const historyRouter = require("./routes/mongoose/History");
const evalRouter = require("./routes/mongoose/Evaluation");
const pollyRouter = require("./routes/mongoose/Polly");

app.use(authRouter);
app.use(hederaRouter);
app.use(historyRouter);
app.use(evalRouter);
app.use(pollyRouter);

app.listen(3000, ()=>{
  console.log("Server started listening on port 3000");
});