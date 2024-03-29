/**
 *Submitted for verification at polygonscan.com on 2021-12-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

/******************************************/
/*     IUniswapV2Router01 starts here     */
/******************************************/

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

/******************************************/
/*     IUniswapV2Router02 starts here     */
/******************************************/

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

/******************************************/
/*        NerveToken starts here          */
/******************************************/

abstract contract NerveToken 
{
    function balanceOf(address owner) external virtual view returns (uint256);
    function transfer(address to, uint value) external virtual returns (bool);

    function mintNerve(address _to, uint256 _amount) external virtual;
    function burnNerve(address _from, uint256 _amount) external virtual;
}

/******************************************/
/*         TokenSwap starts here          */
/******************************************/

contract TokenSwap {
    address internal constant NERVESWAP_ROUTER_ADDRESS = 0x7C4EE503CcEC127279e9161d5B8F15803872797e;
    IUniswapV2Router02 public nerveRouter;

    address internal constant nerveToken = 0x6d48A7BF51fd6b387C2D225c28124a00c0894189;

    constructor() {
        nerveRouter = IUniswapV2Router02(NERVESWAP_ROUTER_ADDRESS);
    }

    function getEstimatedNerveForMatic(uint256 maticAmount) public view returns (uint256) {
        return nerveRouter.getAmountsOut(maticAmount, getPathForMaticToNerve())[1];
    }

    function convertMaticToNerve(uint256 nerveAmount, uint256 timestamp) public payable {
        uint256 deadline = timestamp + 60;
        nerveRouter.swapExactETHForTokens{ value: address(this).balance }(nerveAmount, getPathForMaticToNerve(), address(this), deadline);
    }

    function getPathForMaticToNerve() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = nerveRouter.WETH(); // wrapped MATIC
        path[1] = nerveToken;           // Nerve token
    
        return path;
    }

    // important to receive ETH
    receive() payable external {}
}

/******************************************/
/*         NerveSwap starts here          */
/******************************************/

contract NexusBurn is TokenSwap {

    NerveToken NERVE = NerveToken(nerveToken);

    function initiateBuyBack(uint256 timestamp) public 
    {
        uint256 nerveAmount = getEstimatedNerveForMatic(address(this).balance);
        convertMaticToNerve(nerveAmount - (nerveAmount / 10), timestamp);

        uint256 incentiveFee = NERVE.balanceOf(address(this)) / 1000;
        NERVE.burnNerve(address(this), NERVE.balanceOf(address(this)) - incentiveFee);
        NERVE.transfer(msg.sender, incentiveFee);
    }
}
