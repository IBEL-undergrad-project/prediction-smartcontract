const Prediction = artifacts.require("Prediction.sol");

const SIDE = {
  YOON: 0,
  LEE: 1,
};
contract("Prediction", (addresses) => {
  const [admin, oracle, gambler1, gambler2, gambler3, gambler4, _] = addresses;

  it("should work", async () => {
    const prediction = await Prediction.new(oracle);

    await prediction.placeBet(SIDE.LEE, {
      from: gambler1,
      value: web3.utils.toWei("1"),
    });
    await prediction.placeBet(SIDE.LEE, {
      from: gambler2,
      value: web3.utils.toWei("1"),
    });
    await prediction.placeBet(SIDE.LEE, {
      from: gambler3,
      value: web3.utils.toWei("2"),
    });
    await prediction.placeBet(SIDE.YOON, {
      from: gambler4,
      value: web3.utils.toWei("4"),
    });

    await prediction.reportResult(SIDE.LEE, SIDE.YOON, { from: oracle });

    const balancesBefore = (
      await Promise.all(
        [gambler1, gambler2, gambler3, gambler4].map((gambler) =>
          web3.eth.getBalance(gambler)
        )
      )
    ).map((balance) => web3.utils.toBN(balance));

    await Promise.all(
      [gambler1, gambler2, gambler3].map((gambler) =>
        prediction.withdrawGain({ from: gambler })
      )
    );

    const balancesAfter = (
      await Promise.all(
        [gambler1, gambler2, gambler3, gambler4].map((gambler) =>
          web3.eth.getBalance(gambler)
        )
      )
    ).map((balance) => web3.utils.toBN(balance));

    assert(
      balancesAfter[0].sub(balancesBefore[0]).toString().slice(0, 3) === "199"
    );
    assert(
      balancesAfter[1].sub(balancesBefore[1]).toString().slice(0, 3) === "199"
    );
    assert(
      balancesAfter[2].sub(balancesBefore[2]).toString().slice(0, 3) === "399"
    );
    assert(balancesAfter[3].sub(balancesBefore[3]).isZero());
  });
});
