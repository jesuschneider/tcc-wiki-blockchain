pragma solidity 0.8.0;
// SPDX-License-Identifier: MIT

import "./versao.sol";

struct Pagina {
    bool ativo;
    address autor;
    uint256 dataCriacao;
    string titulo;
    Versao[] versoes ;
}