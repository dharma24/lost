// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RainbowToken is ERC20, ERC20Burnable, Ownable {
    uint256 public constant MAX_SUPPLY = 1e24; // 1 million tokens with 18 decimals
    uint256 public taxRate = 5; // 5% tax on transactions
    uint256 public devMarketingTax = 2; // 2% for developer and marketing
    address public constant devMarketingAddress = 0x000000000000000000000000000000000000dEaD;

    mapping(address => bool) private _isTaxExempt;

    constructor() ERC20("RainbowToken", "RNBW") {
        _mint(msg.sender, MAX_SUPPLY);
        _isTaxExempt[msg.sender] = true;
    }

    function setTaxRate(uint256 newTaxRate) external onlyOwner {
        taxRate = newTaxRate;
    }

    function setDevMarketingTax(uint256 newDevMarketingTax) external onlyOwner {
        devMarketingTax = newDevMarketingTax;
    }

    function setTaxExempt(address account, bool exempt) external onlyOwner {
        _isTaxExempt[account] = exempt;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (_isTaxExempt[sender] || _isTaxExempt[recipient]) {
            super._transfer(sender, recipient, amount);
        } else {
            uint256 taxAmount = (amount * taxRate) / 100;
            uint256 devMarketingAmount = (amount * devMarketingTax) / 100;
            uint256 amountAfterTax = amount - taxAmount - devMarketingAmount;

            super._transfer(sender, devMarketingAddress, devMarketingAmount);
            super._transfer(sender, address(this), taxAmount); // Reflections
            super._transfer(sender, recipient, amountAfterTax);
        }
    }
}
