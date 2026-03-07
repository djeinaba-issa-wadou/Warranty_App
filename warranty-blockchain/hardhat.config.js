require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",

  networks: {
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: [
        "0x63158d0d9f4606941fda012044c090094575c95d867ec0752cfb60743809d4f4"
      ]
    }
  }
};
