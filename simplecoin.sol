pragma solidity ^0.4.20;

contract owned {
    address public owner;
    
    function owned() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
 }

contract MyToken is owned {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FrozenFunds(address target, bool frozen);
    
    mapping (address => uint256) public balanceOf;
    mapping (address => bool) public approveAccount;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public sellPrice;
    uint256 public buyPrice;
    
    function MyToken(
        uint256 _initialSupply,
        string _tokenName,
        string _tokenSymbol,
        uint8 _decimalUnits,
        address centralMinter
        ) public {
            if (centralMinter != 0) owner = centralMinter;
            if (_initialSupply == 0) _initialSupply = 10000;
            
            totalSupply = _initialSupply;
            balanceOf[owner] = _initialSupply;
            name = _tokenName;
            symbol = _tokenSymbol;
            decimals = _decimalUnits;
    }

    function transfer(address _to, uint256 _value) public {
        require(approveAccount[msg.sender]);
        require(balanceOf[msg.sender] >= _value && balanceOf[_to] + _value >= balanceOf[_to]);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
    }
    
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(0, owner, mintedAmount);
        emit Transfer(owner, target, mintedAmount);
    }
    
    function freezeAccount(address target, bool freeze) onlyOwner public {
        approveAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
    
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
    
    function buy() public payable returns (uint amount) {
        amount = msg.value / buyPrice;
        require(balanceOf[this] >= amount);
        balanceOf[msg.sender] += amount;
        balanceOf[this] -= amount;
        emit Transfer(this, msg.sender, amount);
        
        return amount;
    }
    
    function sell(uint amount) public returns (uint revenue) {
        require(balanceOf[msg.sender] >= amount);
        balanceOf[this] += amount;
        balanceOf[msg.sender] -= amount;
        revenue = amount * sellPrice;
        msg.sender.transfer(revenue);
        emit Transfer(msg.sender, this, amount);
        
        return revenue;
    }
}
