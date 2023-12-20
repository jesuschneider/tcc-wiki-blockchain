pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

import "./pagina.sol";


contract Blockpedia {
    Pagina[] public paginas;
    


   
    function criarPagina(string memory titulo, string memory conteudo) public returns (uint) {
        Pagina memory novaPagina = Pagina(msg.sender, true, titulo, new Versao[](0));
        paginas.push(novaPagina);
        uint pageIndex = paginas.length - 1;

        Versao memory primeiraVersao = Versao(msg.sender, true, conteudo);
        paginas[pageIndex].versoes.push(primeiraVersao);

        return pageIndex; // Retorna o índice da página recém-criada
    }


    

    
}
