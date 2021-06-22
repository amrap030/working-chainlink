pragma solidity >=0.6.0;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract RepToken is ChainlinkClient {
    using SafeMath for uint256;

    constructor() public {
        owner = payable(msg.sender);
        setPublicChainlinkToken();
        oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40;
        jobId = "187bb80e5ee74a139734cac7475f3c6e";
        fee = 0.01 * 10**18; // 0.01 LINK
    }

    address payable public owner;
    address private oracle;

    uint256 private fee;
    uint256 public volume;

    bytes32 private jobId;

    function evaluatePredictions() external {
        requestStockPrice(address(this), this.fulfillEvaluation.selector);
    }

    function requestStockPrice(address _cbContract, bytes4 _cbFunction)
        private
        returns (bytes32 requestId)
    {
        Chainlink.Request memory request =
            buildChainlinkRequest(jobId, _cbContract, _cbFunction);
        request.add(
            "get",
            "https://api.twelvedata.com/time_series?symbol=DAI&exchange=XETR&start_date=2021-06-17 17:28&end_date=2021-06-17 17:28&interval=1min&apikey=d8f072b5b5314d29b71c1ff807cf4109"
        );
        request.add("path", "values.0.close");
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    function parseInt(string memory _a, uint256 _b)
        private
        pure
        returns (uint256)
    {
        bytes memory bresult = bytes(_a);
        uint256 mintt;
        bool decimals_;
        for (uint256 i = 0; i < bresult.length; i = i.add(1)) {
            if ((uint8(bresult[i]) >= 48) && (uint8(bresult[i]) <= 57)) {
                if (decimals_) {
                    if (_b == 0) break;
                    else _b = _b.sub(1);
                }
                mintt = mintt.mul(10);
                mintt = mintt.add(uint8(bresult[i]) - 48);
            } else if (uint8(bresult[i]) == 46) decimals_ = true;
        }
        if (_b > 0) mintt = mintt.mul(10**_b);
        return mintt;
    }

    function fulfillEvaluation(bytes32 _requestId, bytes32 _close)
        public
        recordChainlinkFulfillment(_requestId)
    {
        uint256 i;
        while (i < 32 && _close[i] != 0) {
            i = i.add(1);
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _close[i] != 0; i = i.add(1)) {
            bytesArray[i] = _close[i];
        }
        uint256 close = parseInt(string(bytesArray), 5);
        volume = close;
    }

    function kill() public {
        require(msg.sender == owner, "Not the contract creator.");
        selfdestruct(owner);
    }

    function withdrawLink() external {
        LinkTokenInterface linkToken =
            LinkTokenInterface(chainlinkTokenAddress());
        require(
            linkToken.transfer(msg.sender, linkToken.balanceOf(address(this))),
            "Unable to transfer."
        );
    }
}
