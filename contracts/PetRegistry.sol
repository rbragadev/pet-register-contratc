// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PetRegistry {
    
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
    //in prod we use wei
    uint256 public registrationFee = 0.01 ether;
    address public owner;

    constructor (){
        counter = 0;
        owner = msg.sender;
    }

    event PetRegistered(uint256 indexed petId, address indexed owner, string name);

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner of contract can execute this function.");
        _;
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
        require(msg.value >= registrationFee, "not enough funds");
        _createPet(_name, _species, _breed, _color, _birthDate, _weight);
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}