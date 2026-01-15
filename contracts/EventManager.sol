// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract EventManager {
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
    mapping(uint256 => Event) public events;
    mapping(address => uint256[]) public organizerEvents;

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
    }

    function getOrganizerEvents(
        address organizer
    ) external view returns (uint256[] memory) {
        return organizerEvents[organizer];
    }

    function getEvent(uint256 eventId) external view returns (Event memory) {
        return events[eventId];
    }
}
