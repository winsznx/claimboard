// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ClaimBoard {
    struct Claim {
        address claimant;
        bytes32 policyId;
        uint256 amount;
        string evidence;
        uint256 approvals;
        bool settled;
    }

    mapping(uint256 => Claim) public claims;
    mapping(uint256 => mapping(address => bool)) public approvers;
    mapping(address => bool) public adjusters;
    uint256 public claimCount;
    uint256 public approvalThreshold = 2;

    event ClaimFiled(uint256 indexed claimId, address indexed claimant, bytes32 policyId);
    event ClaimApproved(uint256 indexed claimId, address indexed adjuster);
    event ClaimSettled(uint256 indexed claimId);

    error NotAdjuster();
    error AlreadyApproved();

    function fileClaim(bytes32 policyId, uint256 amount, string memory evidence) external returns (uint256) {
        uint256 claimId = claimCount++;
        claims[claimId] = Claim({
            claimant: msg.sender,
            policyId: policyId,
            amount: amount,
            evidence: evidence,
            approvals: 0,
            settled: false
        });
        emit ClaimFiled(claimId, msg.sender, policyId);
        return claimId;
    }

    function approveClaim(uint256 claimId) external {
        if (!adjusters[msg.sender]) revert NotAdjuster();
        if (approvers[claimId][msg.sender]) revert AlreadyApproved();
        approvers[claimId][msg.sender] = true;
        claims[claimId].approvals++;
        emit ClaimApproved(claimId, msg.sender);
        if (claims[claimId].approvals >= approvalThreshold) {
            claims[claimId].settled = true;
            emit ClaimSettled(claimId);
        }
    }

    function addAdjuster(address adjuster) external {
        adjusters[adjuster] = true;
    }
}
