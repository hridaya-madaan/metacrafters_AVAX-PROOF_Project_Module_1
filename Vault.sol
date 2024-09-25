// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Vault {
    IERC20 public immutable token;
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    constructor(address _token) {
        token = IERC20(_token);
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, "Vault: deposit amount must be greater than zero");

        uint256 balanceBefore = token.balanceOf(address(this));
        require(token.transferFrom(msg.sender, address(this), _amount), "Vault: transfer failed");
        uint256 balanceAfter = token.balanceOf(address(this));
        uint256 shares = (balanceAfter - balanceBefore) > 0 ? (balanceAfter - balanceBefore) : _amount;

        balanceOf[msg.sender] += shares;
        totalSupply += shares;

        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _shares) external {
        require(_shares > 0, "Vault: withdraw shares must be greater than zero");
        require(balanceOf[msg.sender] >= _shares, "Vault: insufficient balance");

        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 amount = (tokenBalance * _shares) / totalSupply;

        balanceOf[msg.sender] -= _shares;
        totalSupply -= _shares;

        require(token.transfer(msg.sender, amount), "Vault: transfer failed");

        emit Withdrawal(msg.sender, amount);
    }
}
