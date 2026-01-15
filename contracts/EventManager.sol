// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./TicketNFT.sol";

contract EventManager is Ownable, ReentrancyGuard {
    TicketNFT public ticketNFT;
    uint256 public nextEventId;

    struct Event {
        uint256 id;
        address organizer;
        string title;
        string date;
        string venue;
        string description;
        string category;
        string image;
        uint256 ticketPrice;
        uint256 totalTickets;
        uint256 ticketsSold;
        bool published;
        bool ended;
    }

    mapping(uint256 => Event) public events;
    mapping(uint256 => uint256[]) public eventTickets; // ticket IDs per event
    mapping(uint256 => uint256) public ticketToEvent; // tokenId => eventId

    constructor(address _ticketNFT) {
        ticketNFT = TicketNFT(_ticketNFT);
    }

    // ------------------------
    // Create Event
    // ------------------------
    function createEvent(
        string memory title,
        string memory date,
        string memory venue,
        string memory description,
        string memory category,
        string memory image,
        uint256 ticketPrice,
        uint256 totalTickets
    ) external onlyOwner {
        uint256 eventId = nextEventId++;
        events[eventId] = Event({
            id: eventId,
            organizer: msg.sender,
            title: title,
            date: date,
            venue: venue,
            description: description,
            category: category,
            image: image,
            ticketPrice: ticketPrice,
            totalTickets: totalTickets,
            ticketsSold: 0,
            published: false,
            ended: false
        });

        // Mint NFT tickets to EventManager contract
        for (uint256 i = 0; i < totalTickets; i++) {
            uint256 tokenId = ticketNFT.mintTicket(address(this), "");
            eventTickets[eventId].push(tokenId);
            ticketToEvent[tokenId] = eventId;
        }
    }

    // ------------------------
    // Buy Ticket
    // ------------------------
    function buyTicket(
        uint256 eventId,
        string memory tokenURI
    ) external payable nonReentrant {
        Event storage e = events[eventId];
        require(!e.ended, "Event ended");
        require(e.ticketsSold < e.totalTickets, "Sold out");
        require(msg.value == e.ticketPrice, "Incorrect ETH");

        // Transfer next available ticket to buyer
        uint256 ticketId = eventTickets[eventId][e.ticketsSold];
        ticketNFT.mintTicket(msg.sender, tokenURI); // optional: update metadata
        ticketNFT.safeTransferFrom(address(this), msg.sender, ticketId);

        e.ticketsSold++;
    }

    function getOrganizerEvents(
        address organizer
    ) external view returns (uint256[] memory) {
        return organizerEvents[organizer];
    }
    function getAllEvents() external view returns (uint256[] memory) {
        return allEvents;
    }

    function getEvent(uint256 eventId) external view returns (Event memory) {
        return events[eventId];
    }

    // ------------------------
    // Admin Functions
    // ------------------------
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function endEvent(uint256 eventId) external onlyOwner {
        events[eventId].ended = true;
    }
}
