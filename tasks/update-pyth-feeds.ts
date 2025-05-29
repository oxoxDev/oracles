import { task } from "hardhat/config";
import { isAddress } from "ethers";
import { pythContracts } from "../utils/pyth";
import { EvmPriceServiceConnection } from "@pythnetwork/pyth-evm-js";

task("update-pyth-feeds")
    .setAction(async (_, hre) => {
        const pythContract = pythContracts[hre.network.name] as `0x${string}`;

        if (!isAddress(pythContract)) {
            throw new Error("Invalid Pyth contract address");
        }

        console.log(`🔗 Network: ${hre.network.name}`);
        console.log(`📍 Pyth Contract: ${pythContract}`);

        // Price IDs to update
        const priceIds = [
            "0xc9d8b075a5c69303365ae23633d4e085199bf5c520a3b90fed1322a0342ffc33", // wbtc/usd
            "0x56a3121958b01f99fdc4e1fd01e81050602c7ace3a571918bb55c6a96657cca9", // tbtc/usd
        ];

        // Get contract instance
        const pyth = await hre.ethers.getContractAt("IPyth", pythContract);

        // Get connection to the Pyth network
        const connection = new EvmPriceServiceConnection(
            "https://hermes.pyth.network"
        ); // See Hermes endpoints section below for other endpoints
        
        // Get price update data in bytes format
        const priceUpdateData = (await connection.getPriceFeedsUpdateData(
            priceIds
        )) as any;

        // Get update fee. For one price id, the value of fee is 1
        const fee = await pyth.getUpdateFee(priceUpdateData);
        console.log("Update fee:", fee.toString());

        // Update price feeds
        // const tx = await pyth.updatePriceFeeds(priceUpdateData, { value: fee });
        // await tx.wait();
        // console.log("Tx hash:", tx.hash);
    });
