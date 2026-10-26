require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",

  networks: {
    ganache: {
      // Values come from warranty-blockchain/.env (never committed to Git).
      // See .env.example for the keys needed.
      url: process.env.GANACHE_URL || "http://127.0.0.1:7545",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    }
  }
};
