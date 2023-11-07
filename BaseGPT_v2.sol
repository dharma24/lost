// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/eip/interface/IERC20.sol";

contract CustomToken is IERC20 {
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Burn(address indexed burner, uint256 value);
    event Airdrop(address indexed recipient, uint256 value);

    constructor(string memory name, string memory symbol, uint256 initialSupply) {
        _name = name;
        _symbol = symbol;
        _totalSupply = initialSupply;
        _balances[msg.sender] = initialSupply;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(amount <= _balances[msg.sender], "Insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(amount <= _balances[sender], "Insufficient balance");
        require(amount <= _allowances[sender][msg.sender], "Insufficient allowance");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burn(uint256 amount) external {
        require(amount <= _balances[msg.sender], "Insufficient balance");
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        emit Burn(msg.sender, amount);
    }

    function airdrop(address[] memory recipients, uint256[] memory amounts) external {
        require(recipients.length == amounts.length, "Invalid input lengths");
        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            uint256 amount = amounts[i];
            require(amount <= _balances[msg.sender], "Insufficient balance");
            _balances[msg.sender] -= amount;
            _balances[recipient] += amount;
            emit Transfer(msg.sender, recipient, amount);
            emit Airdrop(recipient, amount);
        }
    }
}
