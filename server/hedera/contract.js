require("dotenv").config();
const express = require("express");
const hederaRouter = express.Router();
const bodyParser = require("body-parser");

hederaRouter.use(
  bodyParser.urlencoded({
    extended: true,
  })
);
hederaRouter.use(bodyParser.json());

var newCID = process.env.HEDERA_newCID;

const {
  AccountId,
  PrivateKey,
  Client,
  FileCreateTransaction,
  ContractCreateTransaction,
  ContractFunctionParameters,
  ContractExecuteTransaction,
  ContractCallQuery,
  Hbar,
  ContractCreateFlow,
} = require("@hashgraph/sdk");
const fs = require("fs");

// Configure accounts and client
const operatorId = AccountId.fromString(process.env.HEDERA_ACC_ID);
const operatorKey = PrivateKey.fromString(process.env.HEDERA_PVT_KEY);
const client = Client.forTestnet().setOperator(operatorId, operatorKey);

async function init() {
  // Import the compiled contract bytecode
  const contractBytecode = fs.readFileSync(
    "hedera/contract_sol_MyContract.bin"
  );

  // Instantiate the smart contract
  const contractInstantiateTx = new ContractCreateFlow()
    .setBytecode(contractBytecode)
    .setGas(100000)
    .setConstructorParameters();

  const contractInstantiateSubmit = await contractInstantiateTx.execute(client);
  const contractInstantiateRx = await contractInstantiateSubmit.getReceipt(
    client
  );
  const newContractId = contractInstantiateRx.contractId;
  newCID = newContractId;
  console.log("The smart contract ID is " + newCID);
}
// init();

async function createNewUser(uid) {
  const contractExecTx = new ContractExecuteTransaction()
    .setGas(100000)
    .setContractId(newCID)
    .setFunction(
      "createNewUser",
      new ContractFunctionParameters().addString(uid)
    );

  try {
    const submitExecTx = await contractExecTx.execute(client);
    const contractExecuteRx = await submitExecTx.getReceipt(client);
    console.log(contractExecuteRx.status);
  } catch (e) {
    console.log(e.message);
  }
}

async function createNewAudioFile(uid) {
  const contractExecTx = new ContractExecuteTransaction()
    .setGas(100000)
    .setContractId(newCID)
    .setFunction(
      "createNewAudioFile",
      new ContractFunctionParameters().addString(uid)
    );

  try {
    const submitExecTx = await contractExecTx.execute(client);
    const contractExecuteRx = await submitExecTx.getReceipt(client);
  } catch (e) {
    console.log(e.message);
  }
}

async function evaluateYourself(uid) {
  const contractExecTx = await new ContractExecuteTransaction()
    .setGas(100000)
    .setContractId(newCID)
    .setFunction(
      "evaluateYourself",
      new ContractFunctionParameters().addString(uid)
    );

  //Submit to a Hedera network
  const submitExecTx = await contractExecTx.execute(client);
  const receipt2 = await submitExecTx.getReceipt(client);
}

async function getBalance(uid) {
  const contractQuery = new ContractCallQuery()
    .setGas(100000)
    .setContractId(newCID)
    .setFunction("getBalance", new ContractFunctionParameters().addString(uid));

  const contractQuerySubmit1 = await contractQuery.execute(client);
  const contractQueryResult1 = contractQuerySubmit1.getUint256(0)["c"];
  return contractQueryResult1;
}

hederaRouter.get("/getBalance", async (req, res) => {
  const uid = req.query.userID;
  const balance = await getBalance(uid);
  res.send({
    balance: balance,
  });
});

module.exports = {
  hederaRouter,
  createNewUser,
  createNewAudioFile,
  getBalance,
  evaluateYourself
};
