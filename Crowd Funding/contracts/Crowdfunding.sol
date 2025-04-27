// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    struct Campaign {
        address payable creator;
        string title;
        string description;
        uint256 goal;
        uint256 amountRaised;
        bool completed;
    }

    Campaign[] public campaigns;

    event CampaignCreated(uint256 campaignId, address creator, string title, uint256 goal);
    event ContributionReceived(uint256 campaignId, address contributor, uint256 amount);
    event CampaignCompleted(uint256 campaignId, address creator, uint256 amountRaised);

    function createCampaign(string memory _title, string memory _description, uint256 _goal) public {
        campaigns.push(Campaign({
            creator: payable(msg.sender),
            title: _title,
            description: _description,
            goal: _goal,
            amountRaised: 0,
            completed: false
        }));

        emit CampaignCreated(campaigns.length - 1, msg.sender, _title, _goal);
    }

    function getCampaign(uint256 _campaignId) public view returns (
        address, string memory, string memory, uint256, uint256, bool
    ) {
        Campaign storage campaign = campaigns[_campaignId];
        return (
            campaign.creator,
            campaign.title,
            campaign.description,
            campaign.goal,
            campaign.amountRaised,
            campaign.completed
        );
    }

    function contributeCampaign(uint256 _campaignId) public payable {
        require(_campaignId < campaigns.length, "Campaign does not exist");
        Campaign storage campaign = campaigns[_campaignId];
        require(!campaign.completed, "Campaign is already completed");

        campaign.amountRaised += msg.value;

        emit ContributionReceived(_campaignId, msg.sender, msg.value);

        // If goal is met, disburse funds and mark campaign as completed
        if (campaign.amountRaised >= campaign.goal) {
            campaign.creator.transfer(campaign.amountRaised);
            campaign.completed = true;
            emit CampaignCompleted(_campaignId, campaign.creator, campaign.amountRaised);
        }
    }

    function getCampaignCount() public view returns (uint256) {
        return campaigns.length;
    }
}
