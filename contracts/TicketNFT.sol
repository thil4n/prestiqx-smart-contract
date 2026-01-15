// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TicketNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;

    address public eventManager;

    constructor() ERC721("VIP Event Ticket", "VIPT") {}

    modifier onlyEventManager() {
        require(msg.sender == eventManager, "Not EventManager");
        _;
    }

    function setEventManager(address _manager) external onlyOwner {
        eventManager = _manager;
    }

    function mintTicket(
        address to,
        string memory tokenURI
    ) external onlyEventManager returns (uint256) {
        _tokenIds++;
        uint256 tokenId = _tokenIds;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);

        return tokenId;
    }
}
