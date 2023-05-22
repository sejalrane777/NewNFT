// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract COC is ERC721, Ownable {

    using Strings for uint256;

    //State Variables
    uint public constant MAX_TOKENS = 10000;
    uint private constant TOKEN_RESERVED = 5;
    uint public price = 10000000000000000;      //0.01 ether
    uint public constant MAX_MINT_PER_TX = 10;

    bool public isSaleActive;
    uint256 public totalSupply;
    mapping (address => uint) private mintedPerWallet;

    string public baseUri;
    string public baseExtension = ".json";


    //Constructor
    constructor() ERC721("New NFT", "ABC") {
        baseUri = "ipfs://ipfs/QmTeCGj66YBb9W3sspXaL7RY8UdXtr1W4P259Lj5Fnc9L7?_gl=1*1d14l64*rs_ga*ZGRmYTIwMjEtYzQwMy00YTM2LTlkODEtODdjYzRhODE3Yjdl*rs_ga_5RMPXG14TE*MTY4NDc1MTUxNi4xMS4xLjE2ODQ3NTE1MjEuNTUuMC4w/";

        for(uint256 i=1; i <= TOKEN_RESERVED; i++){
            _safeMint(msg.sender, i);           //_safeMint(msg.sender, tokenId)//
        }

        totalSupply = TOKEN_RESERVED;
    }

    //Public Functions
    function mint(uint256 _numTokens) external payable {

        require(isSaleActive, "The Sale is NOT Live");
        require(_numTokens <= MAX_MINT_PER_TX, "Minter can not mint more than 10 NFTs in a Tx");
        require(mintedPerWallet[msg.sender] + _numTokens <= MAX_MINT_PER_TX, "You can not mint, have more than 10");
        require(msg.value >= price * _numTokens, "Please send minimum price");
        uint currTotalSupply = totalSupply;
        require(currTotalSupply + _numTokens <= MAX_TOKENS, "Exceed total supply");     //This will be helpfull when you are close of minting of that collection
        //9991 + 10 != 1000

        for(uint256 i=1; i <= _numTokens; i++){
            _safeMint(msg.sender, i);           //_safeMint(msg.sender, tokenId)//
        }

        mintedPerWallet[msg.sender] += _numTokens;
        totalSupply += _numTokens;
    }


    //Only Owner Functions for COC Contract
    function flipSaleState() external onlyOwner {
        isSaleActive = !isSaleActive;
    }

    function setBaseUri(string memory _baseUri) onlyOwner external {
        baseUri = _baseUri;
    }

    function setPrice(uint _price) onlyOwner external {
        price = _price;
    }

    function withdrawAllFunds (address recipient1, address recipient2) external payable onlyOwner {
        uint256 balance = address(this).balance;
        
        //divide funds to 2 addresses
        uint256 balance1 = balance * 70 / 100; 
        uint256 balance2 = balance * 30 / 100;

        //Recomended way to transfer ether
        (bool transfer1, ) = payable(recipient1).call{value: balance1}("");
        (bool transfer2, ) = payable(recipient2).call{value: balance2}("");

        require(transfer1 && transfer2, "Transfer Failed");

    }
}
