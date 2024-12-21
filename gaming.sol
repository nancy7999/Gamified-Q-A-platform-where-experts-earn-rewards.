// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToEarn {
    // Owner of the platform
    address public owner;

    // Structure to store details of an expert
    struct Expert {
        address wallet;
        uint256 totalRewards;
    }

    // Mapping to store registered experts
    mapping(address => Expert) public experts;

    // Event to log reward distributions
    event RewardDistributed(address indexed expert, uint256 reward);

    // Event to register a new expert
    event ExpertRegistered(address indexed expert);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyRegisteredExpert() {
        require(experts[msg.sender].wallet != address(0), "You must be a registered expert");
        _;
    }

    // Function to register an expert
    function registerExpert(address _wallet) external onlyOwner {
        require(experts[_wallet].wallet == address(0), "Expert already registered");

        experts[_wallet] = Expert({
            wallet: _wallet,
            totalRewards: 0
        });

        emit ExpertRegistered(_wallet);
    }

    // Function to distribute rewards to experts
    function distributeReward(address _expert, uint256 _reward) external onlyOwner {
        require(experts[_expert].wallet != address(0), "Expert not registered");

        experts[_expert].totalRewards += _reward;

        (bool sent, ) = _expert.call{value: _reward}("");
        require(sent, "Failed to send reward");

        emit RewardDistributed(_expert, _reward);
    }

    // Fallback function to receive Ether
    receive() external payable {}

    // Function to get expert details
    function getExpertDetails(address _expert) external view returns (address wallet, uint256 totalRewards) {
        require(experts[_expert].wallet != address(0), "Expert not registered");
        Expert memory expert = experts[_expert];
        return (expert.wallet, expert.totalRewards);
    }
}
