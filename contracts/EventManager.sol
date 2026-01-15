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

    uint256[] public allEvents;
    mapping(address => uint256[]) public organizerEvents;

    mapping(uint256 => uint256[]) public eventTickets; // ticket IDs per event
    mapping(uint256 => uint256) public ticketToEvent; // tokenId => eventId

    mapping(address => uint256) public pendingWithdrawals;

    uint256 public platformFeeBps = 500; // 5%
    address public platformTreasury;

    constructor(address _ticketNFT, address _platformTreasury) {
        ticketNFT = TicketNFT(_ticketNFT);
        platformTreasury = _platformTreasury;
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
    ) external {
        require(ticketPrice > 0, "PRICE_ZERO");
        require(totalTickets > 0, "NO_TICKETS");

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
            published: true,
            ended: false
        });

        organizerEvents[msg.sender].push(eventId);
        allEvents.push(eventId);
    }

    // ------------------------
    // Buy Ticket
    // ------------------------
    function buyTicket(
        uint256 eventId,
        string memory tokenURI
    ) external payable nonReentrant {
        Event storage e = events[eventId];

        require(!e.ended, "EVENT_ENDED");
        require(e.ticketsSold < e.totalTickets, "SOLD_OUT");
        require(msg.value == e.ticketPrice, "BAD_PRICE");

        // Mint NFT directly to buyer
        ticketNFT.mintTicket(msg.sender, tokenURI);

        // ---- Payment split ----
        uint256 fee = (msg.value * platformFeeBps) / 10_000;
        uint256 organizerAmount = msg.value - fee;

        pendingWithdrawals[e.organizer] += organizerAmount;
        pendingWithdrawals[platformTreasury] += fee;

        e.ticketsSold++;
    }

    function withdraw() external nonReentrant {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "NO_FUNDS");

        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
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
