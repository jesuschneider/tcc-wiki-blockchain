pragma solidity 0.8.0;
// SPDX-License-Identifier: MIT

import "./pagina.sol";


contract Blockpedia {
    Pagina[] public paginas;
    
   function criarPagina(string memory titulo, string memory conteudo) public {
        Pagina storage novaPagina = paginas.push();
        novaPagina.autor = msg.sender;
        novaPagina.ativo = true;
        novaPagina.titulo = titulo;

        novaPagina.versoes.push(Versao(msg.sender, true, conteudo));
    }


}
