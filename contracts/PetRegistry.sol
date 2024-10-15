// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PetRegistry is ERC721 {

    AggregatorV3Interface internal priceFeed;

    address public priceFeedAddress;
    
    enum Species {Dog, Cat, Bird, Other}

    struct Pet {
        uint256 petId;
        string name;
        Species species;
        string breed;
        string color;
        uint256 birthDate;
        uint256 weight;
        address owner;
    }

    mapping(uint256 => Pet) public pets;

    uint256 public counter;
    uint256 public usdRegistrationFee;
    address public owner;

    constructor () ERC721("PetNFT", "PET") {
        counter = 0;
        owner = msg.sender;
        usdRegistrationFee = 10;
        priceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    event PetRegistered(uint256 indexed petId, address indexed owner, string name);

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner of contract can execute this function.");
        _;
    }

    function getEthPriceInUsd() public view returns (uint256){
        (
            /* uint80 roundID */,
            int256 price,
            /* uint startedAt */,
            /* uint timeStamp */,
            /* uint80 answeredInRound */
        ) = priceFeed.latestRoundData();
        
        return uint256(price / 10 ** 8);
    }

    function getEthRegistrationFeeInWei() public view returns (uint256) {
        uint256 ethPrice = getEthPriceInUsd();
        uint256 feeInWei = (usdRegistrationFee * 10 ** 18) / ethPrice;
        return feeInWei;
    }

    function updateRegistrationFee(uint256 _newFee) public onlyOwner {
        usdRegistrationFee = _newFee;
    }

    function _generatePetId() internal returns (uint256){
        uint256 petId = counter + 1;
        counter++;
        return petId;
    }

    function _createPet(
        string memory _name,
        Species _species,
        string memory _breed,
        string memory _color,
        uint256 _birthDate,
        uint256 _weight
    ) internal {
        uint256 petId = _generatePetId();
        pets[petId] = Pet(petId, _name, _species, _breed, _color, _birthDate, _weight, msg.sender);
        _mint(msg.sender, petId);
        emit PetRegistered(petId, msg.sender, _name);
    }

    function registerPet(
        string memory _name,
        Species _species,
        string memory _breed,
        string memory _color,
        uint256 _birthDate,
        uint256 _weight
    ) public payable  {
        uint256 requiredFee = getEthRegistrationFeeInWei(); 
        require(msg.value >= requiredFee, "not enough funds");
        _createPet(_name, _species, _breed, _color, _birthDate, _weight);
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}