// SPDX-License-Identifier: unlicensed
/*
  .:////:--:////:.        _____       _           _ _     _                      
`////////////+++++/`     / ____|     | |         | (_)   | |                     
://////////++++++++/    | (___   __ _| | ___  ___| |_ ___| |_   __ _ _ __  _ __  
/////////+++++++++o+     \___ \ / _` | |/ _ \/ __| | / __| __| / _` | '_ \| '_ \ 
.//////+++++++++ooo-     ____) | (_| | |  __/\__ \ | \__ \ |_ | (_| | |_) | |_) |
 .///+++++++++oooo-     |_____/ \__,_|_|\___||___/_|_|___/\__(_)__,_| .__/| .__/ 
  `-/+++++++oooo:`                                                  | |   | |    
    `-/+++ooo+-`        (C) https://saleslist.app/                  |_|   |_|    
       `:++:.    
*/
pragma solidity >0.8.6;
// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
}
// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
abstract contract ERC20Interface {
    function name() virtual public view returns (string memory);
    function symbol() virtual public view returns (string memory);
    function decimals() virtual public view returns (uint8);
    function getOwner() virtual public view returns (address);
    function totalSupply() virtual public view returns (uint);
    function balanceOf(address tokenOwner) virtual public view returns (uint balance);
    function transfer(address to, uint tokens) virtual public returns (bool success);
    function transferFrom(address from, address to, uint tokens) virtual public returns (bool success);
    function allowance(address tokenOwner, address spender) virtual public view returns (uint remaining);
    function approve(address spender, uint tokens) virtual public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals
// assisted token transfers
// ----------------------------------------------------------------------------
contract SaleslistToken is ERC20Interface, SafeMath {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint private _totalSupply;
    address private _owner;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    address private _DEAD = 0x000000000000000000000000000000000000dEaD;
    modifier onlyOwner() {
        require(_owner == payable(msg.sender), "Ownable: caller is not the owner");
        _;
    }
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() {
        _name = "Saleslist Token";
        _symbol = "SALE";
        _decimals = 8;
        _totalSupply = 10000000000000000;
        _owner = msg.sender;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    // ------------------------------------------------------------------------
    // Name
    // ------------------------------------------------------------------------
    function name() public override view returns (string memory) { 
        return _name;
    }
    // ------------------------------------------------------------------------
    // Symbol
    // ------------------------------------------------------------------------
    function symbol() public override view returns (string memory) {
        return _symbol;
    }
    // ------------------------------------------------------------------------
    // Decimals
    // ------------------------------------------------------------------------
    function decimals() public override view returns (uint8) {
        return _decimals;
    }
    // ------------------------------------------------------------------------
    // Owner
    // ------------------------------------------------------------------------
    function getOwner() public override view returns (address) {
        return _owner;
    }
    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public override view returns (uint) {
        return _totalSupply - balances[address(0)];
    }
    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public override view returns (uint balance) {
        return balances[tokenOwner];
    }
    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to receiver account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address receiver, uint tokens) public override returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[receiver] = safeAdd(balances[receiver], tokens);
        emit Transfer(msg.sender, receiver, tokens);
        return true;
    }
    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    // ------------------------------------------------------------------------
    // Transfer tokens from sender account to receiver account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from sender account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address sender, address receiver, uint tokens) public override returns (bool success) {
        balances[sender] = safeSub(balances[sender], tokens);
        allowed[sender][msg.sender] = safeSub(allowed[sender][msg.sender], tokens);
        balances[receiver] = safeAdd(balances[receiver], tokens);
        emit Transfer(sender, receiver, tokens);
        return true;
    }
    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    // ------------------------------------------------------------------------
    // Transfer token ownership from sender account to receiver account
    // ------------------------------------------------------------------------
    function transferOwner(address newOwner) external onlyOwner() {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != _DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
        
    }
}
