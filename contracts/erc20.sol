// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20{

    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns(bool success);
    function approve(address _spender, uint256 _value) external returns (bool  success);
    function allowance(address _owner, address _speneder) external returns(uint256 remaining);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Zhuzhuxia_Token is IERC20{

    uint256 constant private MAX_UINT256 = 2 ** 256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping(address => uint256)) public allowed;
    uint256 public totalSupply;

    string public name;
    uint8 public decimals;
    string public symbol;

    constructor(uint256 _initialAmount, string memory _name, uint8 _decimalUnits, string memory _tokenSymbol){
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
        name = _name;
        symbol = _tokenSymbol;
        decimals = _decimalUnits;
    }

    function transfer(address _to, uint256 _value) external override returns (bool success){
        require(balances[msg.sender] >= _value, "token balance is lower than the value requested");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external override returns(bool success){
        uint256 allowanceCnt = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowanceCnt >= _value, "token balance is lower than the value requested");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) external view override returns(uint256 balance){
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) external override returns(bool success){
        allowed[msg.sender][_spender];
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view override returns (uint256 remaining){
        return allowed[_owner][_spender];
    }

}