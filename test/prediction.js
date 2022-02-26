const Prediction = artifacts.require("Prediction.sol");

const SIDE = {
  
  LEE: 0,
  YOON: 1,
  AHN :2,
  SIM:3,
  HEO:4,
  
};

const commission = 10;


contract("Prediction", (addresses) => {
  const [admin, oracle, gambler1, gambler2, gambler3, gambler4,gambler5,gambler6,_] = addresses;

  it("should work", async () => {
    const prediction = await Prediction.new(oracle,commission);

    await prediction.placeBet(SIDE.LEE, {
      from: gambler1,
      value: web3.utils.toWei("1"),
    });
    await prediction.placeBet(SIDE.LEE, {
      from: gambler2,
      value: web3.utils.toWei("1"),
    });
    await prediction.placeBet(SIDE.YOON, {
      from: gambler3,
      value: web3.utils.toWei("2"),
    });
    await prediction.placeBet(SIDE.AHN, {
      from: gambler4,
      value: web3.utils.toWei("4"),
    });
    await prediction.placeBet(SIDE.SIM, {
      from: gambler5,
      value: web3.utils.toWei("4"),
    });
    await prediction.placeBet(SIDE.HEO, {
      from: gambler6,
      value: web3.utils.toWei("4"),
    });
    

    await prediction.reportResult(
      SIDE.LEE,
      { from: oracle }
      );

      
      await Promise.all(
        [gambler1,gambler2].map((gambler) =>
          prediction.withdrawGain({ from: gambler })
        )
      );
  
    
      /* await Promise.all(
        [gambler1,gambler2].map((gambler) =>
          prediction.withdrawGain({ from: gambler })
        )
      ); */

     /*  await Promise.all(
        [gambler3,gambler4].map((gambler) =>
          prediction.withdrawGain({ from: gambler })
        )
      ); */


      console.log(oracle);

      
  
     
    

  });
});
