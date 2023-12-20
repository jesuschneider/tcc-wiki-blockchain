pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

import "./versao.sol";

struct Pagina {
    address  autor;
    bool ativo;
    string titulo;
    Versao[] versoes ;
}