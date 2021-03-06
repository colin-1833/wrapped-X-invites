// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IInviteContract {
    function redeem(address receiver) external;
}

contract InviteContract is IInviteContract {
    IERC20 X_token_contract;
    address creator;

    constructor(address X_token_address) {
        creator = msg.sender;
        X_token_contract = IERC20(X_token_address);
    }

    /**
    * @dev Throws if anyone but the creator contract calls
    */
    modifier onlyCreator() {
        require(msg.sender == creator, "Only the creator contract can do that");
        _;
    }

    /**
    * @dev Sends the .01 $X to any specified address
    */
    function redeem(address receiver) external override onlyCreator() {
        X_token_contract.transfer(receiver, X_token_contract.balanceOf(address(this)));
    }
}

abstract contract IX {
    mapping(address => bool) public allowlist;
    mapping(address => bool) public invitationSpent;
}

contract WrappedXInvites is ERC721 {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private token_ids;
    address payable dev_fee_collector;
    uint256 dev_fee = .05 ether;
    address uri_admin;
    string custom_uri_base;
    mapping(uint256 => address) invite_holding_addresses;
    IERC20 X_token_contract;
    address X_token_address;

    constructor(address _X_token_address, string memory _custom_uri_base) ERC721("Wrapped $X", "wX") {
        X_token_contract = IERC20(_X_token_address);
        X_token_address = _X_token_address;
        uri_admin = msg.sender;
        dev_fee_collector = payable(msg.sender);
        custom_uri_base = _custom_uri_base;
    }

    /// Events

    event UpdateDevFee(uint256 _dev_fee);
    event ChangedDevFeeCollector(address _dev_fee_collector);
    event UpdatedURIBase(string _uri_base);
    event ChangedURIAdmin(address _uri_admin);
    event LockedURI(string _final_uri_base);
    event MintedInvite(address _minter, uint256 _token_id, address _invite_holding_address);
    event UsedInvite(address _user, uint256 _token_id);

    /// Access Control Modifiers

    /**
    * @dev Throws if msg.sender never doesn't have at least .01 $X
    */
    modifier onlyWhenBalanceIsSufficient() {
        require(X_token_contract.balanceOf(msg.sender) >= 1, "You need at least .01 $X");
        _;
    }

    /**
    * @dev Throws if msg.sender never set the minimum allowance
    */
    modifier onlyWhenAllowed() {
        require(X_token_contract.allowance(msg.sender, address(this)) >= 1, "This contract is not approved to transfer .01 $X");
        _;
    }

    /**
    * @dev Throws if msg.sender doesn't own the NFT specified with token_id
    */
    modifier onlyValidNFTOwner(uint256 token_id) {
        require(_exists(token_id), "That NFT no longer exists");
        require(ownerOf(token_id) == msg.sender, "You do not own this NFT");
        _;
    }

    /**
    * @dev Throws if msg.sender isn't allowed to change the URI base
    */
    modifier onlyURIAdmin() {
        require(msg.sender == uri_admin, "You must be the uri_admin to do that");
        _;
    }

    /**
    * @dev Throws if msg.sender is not the dev fee collector
    */
    modifier onlyDevFeeCollector() {
        require(msg.sender == dev_fee_collector, "You must be the dev fee collector");
        _;
    }
    
    /// Public Methods

    /**
    * @dev Changes fee for minting or using an invite NFT.
    */
    function updateDevFee(uint256 _dev_fee) external onlyDevFeeCollector() {
        require(_dev_fee >= 0, "Dev fee must not be negative");
        dev_fee = _dev_fee;

        emit UpdateDevFee(dev_fee);
    }

    /**
    * @dev Changes the address that recieves the dev fees
    */
    function updateDevFeeCollector(address payable _dev_fee_collector) external onlyDevFeeCollector() {
        require(_dev_fee_collector != address(0), "You cannot change the dev_fee_collector to an empty address");
        dev_fee_collector = _dev_fee_collector;

        emit ChangedDevFeeCollector(uri_admin);
    }

    /**
    * @dev Changes the URI base. EX: moving visual assets to a new server and maybe new domain
    */
    function updateURIBase(string memory _custom_uri_base) external onlyURIAdmin() {
        custom_uri_base = _custom_uri_base;

        emit UpdatedURIBase(custom_uri_base);
    }

    /**
    * @dev Changes the address responsible for managing the URI base
    */
    function updateURIAdmin(address _uri_admin) external onlyURIAdmin() {
        require(_uri_admin != address(0), "You cannot change the uri_admin to an empty address");
        uri_admin = _uri_admin;

        emit ChangedURIAdmin(uri_admin);
    }

    /**
    * @dev Changes the uri admin to an empty address, preventing further changes to the URI
    */
    function lockURI() external onlyURIAdmin() {
        uri_admin = address(0);

        emit LockedURI(custom_uri_base);
    }

    function _mintInvite() internal returns(uint256) {
        require(IX(X_token_address).invitationSpent(msg.sender) == false, "You already spent your invite and cannot mint a new NFT");
        
        // increment the counter and mint an nft representing 1 invite and .01 $x
        token_ids.increment();
        uint256 token_id = token_ids.current();
        _mint(msg.sender, token_id);

        // store the address holding the $X
        invite_holding_addresses[token_id] = address(new InviteContract(address(X_token_contract)));

        // send .01 $X tokens to the contract created above
        X_token_contract.transferFrom(msg.sender, invite_holding_addresses[token_id], 1);
        emit MintedInvite(msg.sender, token_id, invite_holding_addresses[token_id]);

        return token_id;
    }

    /**
    * @dev Mints an NFT that represents .01 $X and exactly one invite. Easy to list on OpenSea
    */
    function mintInviteNFT() payable public onlyWhenAllowed() onlyWhenBalanceIsSufficient() returns(uint256 _nft_id) {
        // ensure the correct amount is paid to the dev fee collector
        require(msg.value == dev_fee, "Invalid dev fee supplied");
        
        (uint256 _next_nft_id) = _mintInvite();

        // send the dev fee to the dev fee collector 
        (bool sent,) = dev_fee_collector.call{ value: msg.value }("");
        require(sent, "Failed to send fees to dev_fee_collector");

        return _next_nft_id;
    }

    /**
    * @dev Destroys NFT, sends .01 $X to msg.sender, moves .01 into a new invite holding address, issues msg.sender a new NFT representing one $X invite
    */
    function useAndGenerateInviteNFT(uint256 token_id) payable public onlyValidNFTOwner(token_id) onlyWhenAllowed() returns(uint256 _next_nft_id) {
        // ensure the correct amount is paid to the dev fee collector
        require(msg.value == dev_fee, "Invalid dev fee supplied");
        
        // we don't want to waste invites, so only accounts that have not already been invited can call this
        // if you bought an invite but have no use for it, you can transfer for it someone else, or list it for sale
        // this allows people to speculate on invites???
        // high demand for invite NFTs is good because it reduces the risk of not being able to re-list the NFT after it's use
        // in this case speculation = good
        require(IX(X_token_address).allowlist(msg.sender) == false, "You already spent your invite. You need to sell this NFT instead");

        // the holding contract sends the .01 $X to msg.sender
        // NOTE: this automatically invites msg.sender if they have not been invited yet!
        IInviteContract(invite_holding_addresses[token_id]).redeem(msg.sender);

        emit UsedInvite(msg.sender, token_id);

        // redeposit the .01 $ now that msg.sender is invited and mint msg.sender a new NFT with the same functionality as the previous one
        (uint256 next_nft_id) = _mintInvite();

        // destroy this NFT so it can't be traded further
        _burn(token_id);

        // send the dev fee to the dev fee collector 
        (bool sent,) = dev_fee_collector.call{ value: msg.value }("");
        require(sent, "Failed to send fees to dev_fee_collector");

        return next_nft_id;
    }

    /**
    * @dev Getter to discover the $X holding address of a particular NFT
    */
    function getInviteHoldingAddress(uint256 token_id) external view returns(address) {
        return invite_holding_addresses[token_id];
    }
    
    /**
    * @dev A custom URI that will hopefully point towards generative artwork in the future?
    */
    function tokenURI(uint256 token_id) public view override returns(string memory _uri) {
        require(_exists(token_id), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(
            custom_uri_base,
            token_id.toString()
        ));
    }
}