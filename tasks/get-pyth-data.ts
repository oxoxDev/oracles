import { task } from "hardhat/config";
import { isAddress } from "ethers";
import { pythContracts } from "../utils/pyth";

task(`get-pyth-data`)
  .addParam("priceid")
  .setAction(async ({ priceid }, hre) => {
    const pythContract = pythContracts[hre.network.name] as `0x${string}`;

    if (!isAddress(pythContract)) {
      throw new Error("Invalid Pyth contract address");
    }

    console.log(`\n🔗 Network: ${hre.network.name}`);
    console.log(`📍 Pyth Contract: ${pythContract}`);

    // Get contract instance
    const pyth = await hre.ethers.getContractAt("IPyth", pythContract);

    const getPriceUnsafe = await pyth.getPriceUnsafe(priceid);
    console.log("Price unsafe:", getPriceUnsafe);

    const getPrice = await pyth.getPriceNoOlderThan(priceid, 86400); // 1 day in seconds
    console.log("Price no older than:", getPrice);
  });

