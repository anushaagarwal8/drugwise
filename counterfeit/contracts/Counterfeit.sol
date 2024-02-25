// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Counterfeit {

    //vint256 private numtransactions;
    address public manufacturer;
    address public pharmacy;
    //array that holds all transactions
    mapping (address => uint) public numTransactions;
    mapping (address => bool) public verifiedTokens;
    address[] public verifiedTokensList;
    
    constructor() {
        manufacturer = msg.sender;
        numTransactions[address(this)] = 100;
    }

    struct Transaction {
        address sender;
        address receiver;
        uint256 amount;
        string message;
    }

    event TransactionCompleted (
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        string message
    );

    modifier onlyManufacturer () {
        require(msg.sender==manufacturer, "Manufacturer only.");
        _;
    }

    modifier onlyVerifiedToken(address _token){
        require(verifiedTokens[_token], "Token is not verified.");
        _;
    }

    function addVerifyToken(address _token) public onlyManufacturer{
        verifiedTokens[_token]=true;
        verifiedTokensList.push(_token);
    }

    function removeVerifiedToken(address _token) public onlyManufacturer {
        require(verifiedTokens[_token]==true, "Token is not verified.");
        verifiedTokens[_token]=false;

        for (uint256 i=0; i<verifiedTokensList.length; i++) {
            if (verifiedTokensList[i] ==_token) {
                verifiedTokensList[i] = verifiedTokensList[verifiedTokensList.length-1];
                verifiedTokensList.pop();
                break;
            }
        }
    }

    function getVerifiedTokens() public view returns (address[] memory){
        return verifiedTokensList;
    }


    function verify() public view returns (uint){
        return numTransactions[address(this)];
    }

    function getTransactionNumber() public view returns (uint){
        return numTransactions[address(this)];
    }

    function addTransaction() public {
        require((msg.sender==manufacturer || msg.sender==pharmacy), "Unauthorized transaction");
        numTransactions[address(this)] += 1;
    }

}