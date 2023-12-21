pragma solidity 0.8.0;
// SPDX-License-Identifier: MIT

import "./pagina.sol";


contract Blockpedia {
    bool public ativo;
    address public autor;
    Pagina[] public paginas;

    constructor(){autor = msg.sender; ativo = true;}

   function criarPagina(string memory titulo, string memory conteudo) public {
        require(ativo == true, "A adicao de novas paginas so e permitida quando a Blockpedia esta ativa");
        
        Pagina storage novaPagina = paginas.push();
        novaPagina.autor = msg.sender;
        novaPagina.ativo = true;
        novaPagina.titulo = titulo;

        novaPagina.versoes.push(Versao(msg.sender, true, conteudo));
    }

    function ativaDesativaBlockpedia(bool _ativo) public
    {
        require(msg.sender == autor,"Somente o dono desta Blockpedia pode alterar o atributo ativo");
        ativo = _ativo;
    }
}
