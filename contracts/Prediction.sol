pragma solidity ^0.7.3;

contract Prediction {
    enum Side {
        Lee,
        Yoon,
        Ahn,
        Shim,
        Heo
    }

    address public oracle;
    uint256 public commissionPercentage;
    uint256 public electionStartDate;

    Side public result;
    bool public resultReported;

    mapping(Side => uint256) public bets;
    mapping(address => mapping(Side => uint256)) public betsPerGambler;

    constructor(
        address _oracle,
        uint256 _commissionPercentage,
        uint256 _electionStartDate
    ) {
        oracle = _oracle;
        commissionPercentage = _commissionPercentage;
        electionStartDate = _electionStartDate;
    }

    function placeBet(Side _side) external payable {
        require(resultReported == false, "result is already reported");
        require(
            electionStartDate > block.timestamp,
            "election has already started"
        );

        bets[_side] += msg.value;
        betsPerGambler[msg.sender][_side] += msg.value;
    }

    function withdrawGain() external {
        require(resultReported == true, "result is not reported yet");
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
        uint256 gain = ((totalPrize / totalWinnerPrize) *
            gamblerBet *
            (100 - commissionPercentage)) / 100;

        // prevent getting gain twice
        betsPerGambler[msg.sender][Side.Lee] = 0;
        betsPerGambler[msg.sender][Side.Yoon] = 0;
        betsPerGambler[msg.sender][Side.Ahn] = 0;
        betsPerGambler[msg.sender][Side.Shim] = 0;
        betsPerGambler[msg.sender][Side.Heo] = 0;

        msg.sender.transfer(gain);
    }

    function reportResult(Side _winner) external {
        require(
            oracle == msg.sender,
            "only oracle is allowed to report result"
        );
        require(resultReported == false, "election result is already reported");
        require(
            electionStartDate <= block.timestamp,
            "election has not started yet"
        );

        result = _winner;
        resultReported = true;

        uint256 oracle_gain = ((bets[Side.Lee] +
            bets[Side.Yoon] +
            bets[Side.Ahn] +
            bets[Side.Shim] +
            bets[Side.Heo]) * commissionPercentage) / 100;

        // send oracle for profit
        msg.sender.transfer(oracle_gain);
    }
}
