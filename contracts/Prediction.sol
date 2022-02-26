pragma solidity ^0.7.3;

contract Prediction {
    enum Side {
        Lee,
        Yoon,
        Ahn,
        Shim,
        Heo
    }
    Side public result;
    bool public electionFinished;

    mapping(Side => uint256) public bets;
    mapping(address => mapping(Side => uint256)) public betsPerGambler;

    address public oracle;
    uint256 public commissionPercentage;
    

    constructor(address _oracle,uint256 _commissionPercentage) {
        oracle = _oracle;
        commissionPercentage = _commissionPercentage;
    }

    function placeBet(Side _side) external payable {
        require(electionFinished == false, "election is finished");
        bets[_side] += msg.value;
        betsPerGambler[msg.sender][_side] += msg.value;
    }

    function withdrawGain() external {
        require(electionFinished == true, "election not finished");

        uint256 gamblerBet = betsPerGambler[msg.sender][result];
        require(
            gamblerBet > 0,
            "you do not have any winning bet, or you already have received the gain"
        );

        // gain calculation algorithm
        uint256 totalPrize = bets[Side.Lee] +
            bets[Side.Yoon] +
            bets[Side.Ahn] +
            bets[Side.Shim] +
            bets[Side.Heo];
        uint256 totalWinnerPrize = bets[result];
        uint256 gain = (totalPrize / totalWinnerPrize) *
            gamblerBet *
            (100 - commissionPercentage) /
            100;

        // prevent getting gain twice
        betsPerGambler[msg.sender][Side.Lee] = 0;
        betsPerGambler[msg.sender][Side.Yoon] = 0;
        betsPerGambler[msg.sender][Side.Ahn] = 0;
        betsPerGambler[msg.sender][Side.Shim] = 0;
        betsPerGambler[msg.sender][Side.Heo] = 0;

        msg.sender.transfer(gain);
    }

    function reportResult(Side _winner) external {
        require(oracle == msg.sender, "only oracle");
        require(electionFinished == false, "election is finished");
        result = _winner;
        electionFinished = true;

        uint256 oracle_gain = (bets[Side.Lee] + bets[Side.Yoon] + bets[Side.Ahn] + bets[Side.Shim] + bets[Side.Heo]) *
                commissionPercentage/ 
                100;

        // send oracle for profit
        msg.sender.transfer(
            oracle_gain
        );
    }
}
