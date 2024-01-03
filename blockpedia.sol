pragma solidity 0.8.0;
// SPDX-License-Identifier: MIT

import "./pagina.sol";

contract Blockpedia
{
    bool public ativo = true; 
    address public autor; 
    uint256 public dataCriacao = block.timestamp;
    Pagina[] public paginas; 

    constructor()
    {
        autor = msg.sender;
    }

    function criarPagina(string memory titulo, string memory conteudo) public
    {
        require(ativo == true, "A adicao de novas paginas so e permitida quando a Blockpedia esta ativa");
        require(!tituloExiste(titulo), "Uma pagina com este titulo ja existe");

        Pagina storage novaPagina = paginas.push();
        novaPagina.ativo = true;
        novaPagina.autor = msg.sender;
        novaPagina.dataCriacao = block.timestamp;
        novaPagina.titulo = titulo;
        novaPagina.versoes.push(Versao(true, msg.sender, block.timestamp, conteudo));
    }

    function ativaDesativaBlockpedia(bool _ativo) public
    {
        require(msg.sender == autor,"Somente o dono desta Blockpedia pode alterar o atributo ativo");
        ativo = _ativo;
    }

    function tituloExiste(string memory titulo) internal view returns (bool)
    {
        //keccak256 é uma funcao hash, estou usando por conta que não tem comparacao de string em solidity
        //abi.encodePacked() serve para transformar a string em um "pacote" binario antes de transformar em hash
        for (uint i = 0; i < paginas.length; i++)
        {
            if (keccak256(abi.encodePacked(paginas[i].titulo)) == keccak256(abi.encodePacked(titulo))) return true;
        }
        return false;
    }

    function getConteudoVersaoValidaPorIndexPaginas(uint indice) public view returns (string memory)
    {
        require(indice < paginas.length, "Indice fora do alcance");

        return getVersaoValidaDeUmaPagina(paginas[indice]).conteudo;
    }

    function getVersaoValidaDeUmaPagina(Pagina memory pagina)internal pure returns (Versao memory)
    {
        for(uint i = 0; i < pagina.versoes.length; i++)
        {
            if(pagina.versoes[i].ativo) return pagina.versoes[i];
        }
        revert("Nenhuma versao valida encontrada");
    }

    function adicionaNovaVercaoDesativadaAPaginaPorIndexPaginas(uint index, string memory conteudo) public
    {
        require(ativo == true, "A adicao de novas paginas so e permitida quando a Blockpedia esta ativa");
        require(index < paginas.length, "Indice fora do alcance");
        
        Pagina storage pagina = paginas[index];
        require(pagina.ativo == true, "A adicao de novas vercoes so e permitida quando a pagina esta ativa");
        
        pagina.versoes.push(Versao({
            ativo: false,
            autor: msg.sender,
            dataCriacao : block.timestamp,
            conteudo: conteudo
        }));
    }

    function ativaVersaoPorIndexVersoesEIndexPaginas(uint indexPagina, uint indexVersoes) public
    {
        require(ativo == true, "A adicao de novas paginas so e permitida quando a Blockpedia esta ativa");
        require(indexPagina < paginas.length, "Indice da pagina invalido.");
        require(indexVersoes < paginas[indexPagina].versoes.length, "Indice da versao invalido.");

        if(paginas[indexPagina].versoes[indexVersoes].ativo) return;

        for (uint i = paginas[indexPagina].versoes.length; i > 0; i--)
        {
            uint indexAtual = i - 1;
            if (paginas[indexPagina].versoes[indexAtual].ativo)
            {
                paginas[indexPagina].versoes[indexAtual].ativo = false;
                break;
            }
        }

        paginas[indexPagina].versoes[indexVersoes].ativo = true;
    }

}
