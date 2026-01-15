// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EventManager is ERC721, Ownable {
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

    uint256 public nextEventId;
    uint256 public nextTicketId;

    mapping(uint256 => Event) public events;

    uint256[] public allEvents;
    mapping(address => uint256[]) public organizerEvents;
    mapping(address => uint256[]) public eventTickets;

    mapping(uint256 => uint256) public ticketToEvent;

    constructor() ERC721("EventTicket", "ETICKET") Ownable(msg.sender) {
        // Initialization if needed
    }

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

        organizerEvents[msg.sender].push(eventId);
        allEvents.push(eventId);
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

    function buyTicket(uint256 eventId) external payable {
        Event storage e = events[eventId];
        require(e.id == eventId, "Event does not exist");
        require(!e.ended, "Event ended");
        require(e.ticketsSold < e.totalTickets, "Sold out");
        require(msg.value >= e.ticketPrice, "Not enough ETH sent");

        // Mint NFT ticket
        uint256 ticketId = nextTicketId++;
        _mint(msg.sender, ticketId);
        ticketToEvent[ticketId] = eventId;

        e.ticketsSold++;
    }
}
