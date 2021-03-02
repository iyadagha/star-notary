// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {

    
    struct Star {
        string name;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;

    //call the costructor of ERC721 giving the token a name and a symbol
    constructor() ERC721("StarTrack", "STRT") public { }

    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Star you don't owned");
        starsForSale[_tokenId] = _price;
    }


    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }

    function buyStar(uint256 _tokenId) public  payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        _transfer(ownerAddress, msg.sender, _tokenId); // We can't use _addTokenTo or_removeTokenFrom functions, now we have to use _transferFrom
        address payable ownerAddressPayable = _make_payable(ownerAddress); // We need to make this conversion to be able to use transfer() function to transfer ethers
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }
    }

    // looks up the stars using the Token ID and returns the name of the star
    function lookUptokenIdToStarInfo(uint256 _tokenId) public view returns (string memory){
        return tokenIdToStarInfo[_tokenId].name;
    }
    
    // exchange tokens bentwen 2 users.  
    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        address ownerOfToken1 = ownerOf(_tokenId1);
        address ownerOfToken2 = ownerOf(_tokenId2);
        //checks if the sender owns one of the tokens
        require(msg.sender == ownerOfToken1 || msg.sender == ownerOfToken2, "caller is not an owner of a token");

        _transfer(ownerOfToken1, ownerOfToken2, _tokenId1);
        _transfer(ownerOfToken2, ownerOfToken1, _tokenId2);
    }

    // transfer a star from the address of the caller
    function transferStar(address toAddress, uint256 _tokenId) public {
        address owner = ownerOf(_tokenId);
        require(msg.sender == owner, "caller is not the owner of the star");
        _transfer(owner, toAddress, _tokenId);
    
    }

}