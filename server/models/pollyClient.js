const { PollyClient } = require("@aws-sdk/client-polly");

const REGION = "ap-south-1";
const pollyClient = new PollyClient({ region: REGION });

module.exports = pollyClient;
