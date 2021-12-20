// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.3 <0.7.0;
pragma experimental ABIEncoderV2;

import "./EllipticCurve.sol";
/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract GetToken {
    address payable public HealthCareProvider;
    address payable CustomerAddress;

    struct Customer {
        uint identifier;
        uint256 c_x1;
        uint256 c_y1;
        uint256 c_x2;
        uint256 c_y2; 
        uint256 sum;
        uint256 key;
    }

    Customer customer;
    uint reward;
    
    
    enum State {Inactive,Wait4Key}

    State public state;

    modifier onlyHealthCareProvider() { // Modifier
        require(
            msg.sender == HealthCareProvider,
            "Only HealthCareProvider can call this function."
        );
        _;
    }

    modifier inState(State _state) {
        require(
            state == _state,
            "Invalid state."
        );
        _;
    }

    constructor() public payable {
        HealthCareProvider =payable(msg.sender);
        state=State.Inactive;
    }

    /**
     * @dev Healthcare providers submit checking values
     * 
     */
    function Audition(uint _identifier,
                    uint256 _C_add_x1, uint256 _C_add_y1, 
                    uint256 _C_add_x2, uint256 _C_add_y2,
                    uint256 _sum) public onlyHealthCareProvider inState(State.Inactive) {
        customer.identifier=_identifier;
        customer.c_x1=_C_add_x1;
        customer.c_y1=_C_add_y1;
        customer.c_x2=_C_add_x2;
        customer.c_y2=_C_add_y2;
        customer.sum=_sum;
        reward=20;
        state=State.Wait4Key;
    }
    
    function ReceiveKey(uint256 _key) public payable inState(State.Wait4Key) {
        CustomerAddress=payable(msg.sender);
        uint256 m_x;
        uint256 m_y;
        uint256 sum_x;
        uint256 sum_y;
        (m_x,m_y)=EllipticCurve.ecMul(customer.key,customer.c_x2,customer.c_y2);
        (m_x,m_y)=EllipticCurve.ecSub(customer.c_x1,customer.c_y1,m_x,m_y);
        (sum_x,sum_y)=EllipticCurve.ecMul(customer.sum,EllipticCurve.GX,EllipticCurve.GY);
        require(sum_x == m_x,"IER Detection fail");
        require(sum_y == m_y,"IER Detection fail");
        CustomerAddress.transfer(reward);
    }
    
}