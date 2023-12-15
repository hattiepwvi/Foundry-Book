// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

abstract contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approve(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    string public name;
    string public symbol;
    uint8 public immutable decimals;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // 遗漏了这些
    uint256 internal immutable INITIAL_CHAIN_ID;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;
    mapping(address => uint256) public nonces;



    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INTIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    function approve(address spender, uint256 amount) public virtual returns(bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns(bool) {
        balanceOf[msg.sender] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }
        
        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns(bool){
        uint256 allowed = allowance[from][msg.sender];

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        unchecked{
            balanceOf[to] += amount;
        }
        
        emit transfer(from, to, amount);

        return true;
    }




    function permit(
        address from, 
        address spender, 
        uint256 value, 
        uint256 deadline, 
        uint8 v,
        bytes32 r,
        bytes32 s
        ) public virtual {

        require (deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        unchecked{
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner, address spender, uint256 value, uint256 nonce, uint256 deadline)", 
                                ),
                                owner, 
                                spender, 
                                value, 
                                nonces[owner]++, 
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s  
            );
            
            require(recoveredAddress == from && recoveredAddress != owner, "ERC20: signature verification failed");
            
        }



    }


    function mint(address _to, uint256 _amount) public {
        balances[_to] += _amount;
        transfer(_to, _amount);
        emit transfer(address(this), _to, _amount);
    }

    function burn(address _from, uint256 _amount) public {
        balances[_from] -= _amount;
        transfer(_from, _amount);
        emit transfer(_from, address(this), _amount);
    }

    function create_new_domain_separator(string _name, string _symbol, uint8 _chainID, address _verifiedContract) public view returns (bytes32) {
        if DOMAIN_SEPARATOR ? DOMAIN_SEPARATOR : create_new_domain_separator();

        return keccak256(abi.encodePacked(
            keccak256(_name),
            keccak256(1),
            keccak256(_symbol),
            keccak256(address(this)),
        ))
    }
}
