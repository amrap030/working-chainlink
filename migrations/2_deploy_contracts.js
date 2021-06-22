const RepToken = artifacts.require("RepToken");

module.exports = async function (deployer) {
  await deployer.deploy(RepToken);
  const repToken = await RepToken.deployed();
};
