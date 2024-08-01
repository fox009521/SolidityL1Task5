// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract CrowdFunding {
    address public immutable beneficiary; // 受益人
    uint256 public immutable fundingGoal; // 筹集资金目标数量
    uint256 public fundingAmount; // 当前金额
    mapping(address=>uint256) public funders;
    mapping(address=>bool) private fundersInserted; // 捐款人是否已经新增
    address[] public fundersKey;
    bool public AVAILABLED = true;// 状态
    // 部署的时候，写入受益人+筹集目标数量
    constructor(address beneficiary_, uint256 goal_) {
        beneficiary = beneficiary_;
        fundingGoal = goal_;
    }

    // 资助
    // 可用的时候才可以调用
    // 合约关闭之后，就不能再操作了
    function contribute() external payable {
        require(AVAILABLED, "CrowdFunding is closed");
        // 检查捐赠金额是否会超过目标金额
        uint256 potentialFundingAmount = fundingAmount + msg.value;
        // 退款金额
        uint256 refundAmount = 0;

        if (potentialFundingAmount > fundingGoal) {
            // 超出的金额 需要退款
            refundAmount = potentialFundingAmount - fundingGoal;
            // 捐赠金额 - 退款金额
            funders[msg.sender] += (msg.value - refundAmount);
            // 当前金额 - 退款金额
            fundingAmount += (msg.value - refundAmount);
        } else {
            funders[msg.sender] += msg.value;
            fundingAmount += msg.value;
        }

        // 更新捐赠者信息
        if (!fundersInserted[msg.sender]) {
            fundersInserted[msg.sender] = true;
            fundersKey.push(msg.sender);
        }

        // 退还多余的金额
        if (refundAmount > 0) {
            payable(msg.sender).transfer(refundAmount);
        }
    }

    // 关闭
    function close() external returns(bool){
        // 检查
        if (fundingAmount < fundingGoal) {
            return false;
        }

        uint256 amount = fundingAmount;

        // 修改
        fundingAmount = 0;
        AVAILABLED = false;

        // 操作
        payable(beneficiary).transfer(amount);
        return true;
    }

    function fundersLength() public view returns(uint256) {
        return fundersKey.length;
    }
}