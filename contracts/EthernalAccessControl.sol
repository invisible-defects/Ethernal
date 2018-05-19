pragma solidity ^0.4.17;

/// @title Package managing access controls for Ethernal
contract EthernalAccessControl {
    // Package controls asset control for Ethernal and has 3 roles:
    //
    //  - The CEO: can assign and unassign other roles and change smart
    //      contracts adresses. Assigned to contract creator by default.
    //
    //  - The Admin: can ban other players, sets minimal and maximal prices
    //      for trade market and ships artifacts, which are provided by
    //      organisation (not by players) to the trade market.
    //
    //  - The Gameserver: gives artifacts to players, sets & unsets Ethernal Lord,
    //      controls ladder PvP system and Citadel
    //


    /// @dev The addresses of acounts that can execute each roles' actions
    address public ceoAddress;
    address public gameserverAddress;
    mapping (address=>bool) public adminAddresses;

    // @dev If true, game is under maintenance and no actions can be
    // proceeded through the Gameserver
    bool public paused = false;

    // @dev Constructor sets contract creator to CEO
    constructor() public{
        ceoAddress = msg.sender;
    }

    // Modifiers

    /// @dev Access modifiers for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    /// @dev Access modifiers for gameserver-only functionality
    modifier onlyGameserver() {
        require(msg.sender == gameserverAddress);
        _;
    }

    /// @dev Access modifiers for admin-only functionality
    modifier onlyAdmin() {
        require(adminAddresses[msg.sender]);
        _;
    }


    // Role assigners

    /// @dev Assigns a new CEO
    /// @param _newCEO Address of the new CEO
    function setCEO(address _newCEO) public onlyCEO {
        require(_newCEO != address(0));
        ceoAddress = _newCEO;
    }

    /// @dev Assigns a new gameserver address
    /// @param _newGameserver Address of the new Gameserver
    function setGameserver(address _newGameserver) public onlyCEO {
        require(_newGameserver != address(0));
        gameserverAddress = _newGameserver;
    }

    /// @dev Assigns a new admin
    /// @param _adminAddress Address of the admin
    function assignAdmin(address _adminAddress) public onlyCEO {
        adminAddresses[_adminAddress] = true;
    }

    /// @dev Unssigns an admin
    /// @param _adminAddress Address of the admin
    function unassignAdmin(address _adminAddress) public onlyCEO {
        adminAddresses[_adminAddress] = false;
    }


    // Pausing functionality (adapted from CryproKitties)


    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused);
        _;
    }

    /// @dev Called by CEO to pause the contract, if the game
    /// is to go under maintenance
    function pause() public onlyCEO whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract, can only be called by the CEO.
    function unpause() public onlyCEO whenPaused {
        paused = false;
    }
}