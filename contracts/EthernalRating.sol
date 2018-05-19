pragma solidity ^0.4.17;

import "./ArtifactOwnership.sol";

/// @title Contract handling Ethernal PvP ratings
contract EthernalRating is EthernalAccessControl{
    // The whole rating\ladder system is split up into two parts:
    // 1. Regular Ladder
    // (for all players)
    // 2. Citadel Ladder
    // (for previous season's best players)
    // They follow the same exact rules.
    //
    // The rating system is based on ELO system.
    //
    // Best 50 players of each month are moved
    // to Citadel, Citadel's worst 25% are moved back
    // to regular ladder.
    // Citadel's best player of month becomes the Ether Lord.

    /// @dev A mapping defining if a player is in citadel
    mapping(address => bool) public isInCitadel;

    /// @dev Amount of games played by player
    /// @notice Used for calibration games
    mapping(address => uint16) public gamesPlayed;

    /// @dev Players' ELO rating (both regular and Citadel)
    /// @notice Player's address => Season number => Score
    mapping(address => mapping(uint8 => uint16)) public ratings;

    /// @dev PvP ladder subscription
    mapping(address => uint) public subscriptions;

    /// @dev Current subscription price
    uint public subscriptionPrice;

    /// @dev Current PvP season (month)
    uint8 public season;

    /// @dev Current Ether Lord
    address public etherLord;

    /// @dev Sets initial Lord to msg.sender and season to 0
    constructor() public{
        etherLord = msg.sender;
        season = 0;
        subscriptionPrice = 23225 szabo;
    }

    /// @dev Updates players' ratings based on match played
    /// @param _A Player 1 address
    /// @param _B Player 2 address
    /// @param _A_pts Player 1 points:
    /// Player 1 won - 2
    /// Draw - 1
    /// Player 2 won - 0
    /// @notice TODO: optimise gas cost for this function
    function updateRating(address _A, address _B, uint8 _A_pts) public onlyGameserver{
        // Ratings of player 1 and 2
        int32 _ratingA = ratings[_A][season];
        int32 _ratingB = ratings[_B][season];

        if(_ratingA == 0)
            _ratingA = 50;
        if(_ratingB == 0)
            _ratingB = 50;

        /// @dev Rating increase coefficeint
        /// @notice We need a bit of boost for new players (calibration)
        uint8 _kA = (gamesPlayed[_A] < 10 ? 40 : 20);
        uint8 _kB = (gamesPlayed[_B] < 10 ? 40 : 20);

        // Let's go deeper in this thing.
        // NewRating = CurrentRating + K * (Points - ExpectedPoints)
        // Points (A) = _A_pts / 2 (because we need 1 / 0.5 / 0)
        // Points (B) = 1 - _A_pts / 2
        // ExpectedPoints (A) = 1 / (1 + 10*(RatingA - RatingB)/400))
        // ExpectedPoints (B) = 1 / (1 + 10*(RatingB - RatingA)/400))
        // All the magic numbers, like 10, 400, etc. come
        // from ELO rating formula
        _ratingA = int32(
            _ratingA + _kA*(_A_pts/2 - 1/(1+10*(_ratingB - _ratingA)/400))
            );
        _ratingB = int32(
            _ratingB + _kB*((1 - _A_pts/2) - 1/(1+10*(_ratingA - _ratingB)/400))
            );

        ratings[_A][season] = (_ratingA >= 5 ? uint16(_ratingA) : 5);
        ratings[_B][season] = (_ratingB >= 5 ? uint16(_ratingB) : 5);

        // Increasing games played by 1
        gamesPlayed[_A]++;
        gamesPlayed[_B]++;
    }

    function getCurrentSeasonScore(address _A) public view returns (uint16 rating){
        rating = ratings[_A][season];
    }

    // It's quite expensive computationally
    // to process top-50 and top-1 by sorting scores
    // so gameServer is going to do it
    // (ratings are still publically availible
    // and we do not loose a lot of transparency)
    function sendToCitadel(address _A) public onlyGameserver{
        isInCitadel[_A] = true;
    }
    function removeFromCitadel(address _A) public onlyGameserver{
        isInCitadel[_A] = false;
    }
    function setEtherLord(address _A) public onlyGameserver{
        etherLord = _A;
    }

    /// @dev Function to clear ladders and begin new season
    function startNewSeason() public onlyGameserver{
        season++;
    }

    /// @dev Set new subscription price
    function setSubscriptionPrice(uint newPrice) public onlyGameserver{
        subscriptionPrice = newPrice;
    }

    /// @dev Buy subscription
    function buySubscription() public payable{
        require(msg.value == subscriptionPrice);
        subscriptions[msg.sender] = now;
    }
}