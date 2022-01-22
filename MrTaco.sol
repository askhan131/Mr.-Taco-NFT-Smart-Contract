// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract MrTaco is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  uint256 public cost = .05 ether;
  uint256 public maxSupply = 10000;
  uint256 public maxMintAmount = 100;
  uint256 public nftPerAddressLimit = 10;
  bool public paused = false;
  bool public onlyWhitelisted = true;
  address[] public whitelistedAddresses;
  mapping(address => uint256) public addressMintedBalance;

  constructor(
  ) ERC721("MrTaco", "MTT") {
    setBaseURI("ipfs://QmUnqnH9T7yKhp21QeCjH9YGKfsqWPGPKgg3K6qNJQqEvp/");
  }

  // internal functions
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public functions
  function mint(uint256 _mintAmount) public payable {
    // Function for mining our NFT
    require(!paused, "the contract is paused");
    uint256 supply = totalSupply();
    require(_mintAmount > 0, "need to mint at least 1 NFT");
    require(_mintAmount <= maxMintAmount, "max mint amount per session exceeded");
    require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

    if (msg.sender != owner()) {
        if(onlyWhitelisted == true) {
            require(isWhitelisted(msg.sender), "user is not whitelisted");
            uint256 ownerMintedCount = addressMintedBalance[msg.sender];
            require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");
        }
        require(msg.value >= cost * _mintAmount, "insufficient funds");
    }

    for (uint256 i = 1; i <= _mintAmount; i++) {
      addressMintedBalance[msg.sender]++;
      _safeMint(msg.sender, supply + i);
    }
  }
  
  function isWhitelisted(address _user) public view returns (bool) {
    for (uint i = 0; i < whitelistedAddresses.length; i++) {
      if (whitelistedAddresses[i] == _user) {
          return true;
      }
    }
    return false;
  }

  function walletOfOwner(address _owner) public view returns (uint256[] memory){
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);

    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(
      _exists(tokenId),
      "Token doesn't exist"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only for owner
  function setNftPerAddressLimit(uint256 _limit) public onlyOwner {
      //To set the limit for nft holders
    nftPerAddressLimit = _limit;
  }
  
  function setCost(uint256 _newCost) public onlyOwner {
      //To set the cost for new nft mining
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
      //To set the maximum amount of nft in one session mining
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
      // TO set the new base URI
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
      //To set the base extension
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
      // To pause the contract
    paused = _state;
  }
  
  function setOnlyWhitelisted(bool _state) public onlyOwner {
      // To set the prime members of our nft holders
    onlyWhitelisted = _state;
  }
  
  function whitelistUsers(address[] calldata _users) public onlyOwner {
      // To remove members from white listed users
    delete whitelistedAddresses;
    whitelistedAddresses = _users;
  }
 
  function withdraw() public payable onlyOwner {
    // To withdraw the contract balance.
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }
// =============================================================================
}