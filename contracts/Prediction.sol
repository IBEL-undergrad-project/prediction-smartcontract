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
    bool public oracleTookGain;

    mapping(Side => uint256) public bets;
    mapping(address => mapping(Side => uint256)) public betsPerGambler;
    address public oracle;

    constructor(address _oracle) {
        oracle = _oracle;
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
        uint256 totalPrize = bets[Lee] +
            bets[Yoon] +
            bets[Ahn] +
            bets[Shim] +
            bets[Heo];
        uint256 totalWinnerPrize = bets[result];
        uint256 gain = (totalPrize / totalWinnerPrize) * gamblerBet * 0.99;

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

        // send oracle for profit
        require(oracleTookGain == false, "oracle has already taken the gain");
        msg.sender.transfer(
            (bets[Lee] + bets[Yoon] + bets[Ahn] + bets[Shim] + bets[Heo]) * 0.01
        );
    }
}
