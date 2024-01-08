pragma solidity 0.8.0;
// SPDX-License-Identifier: MIT


contract Blockpedia
{
    bool public ativo = true; 
    address public autor; 
    uint256 public dataCriacao = block.timestamp;
    Pagina[] public paginas; 

    struct Pagina
    {
        bool ativo;
        address autor;
        uint256 dataCriacao;
        string titulo;
        Versao[] versoes ;
    }

    struct Versao
    {
        bool ativo;
        address autor;
        uint256 dataCriacao;
        string conteudo;
    }

    constructor()
    {
        autor = msg.sender;
        criarPagina("Inicio", "Bem vindo a Blockpeida, a enciclopedia na blockchain");
    }

    function criarPagina(string memory titulo, string memory conteudo) public
    {
        require(ativo, "A adicao de novas paginas so e permitida quando a Blockpedia esta ativa");
        require(!existeTituloAtivo(titulo), "Ja existe pagina ativa com este titulo");

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

    function existeTituloAtivo(string memory titulo) internal view returns (bool)
    {
        for (uint i = 0; i < paginas.length; i++)
        {
            if (paginas[i].ativo)
                if (comparaString(paginas[i].titulo, titulo))return true;
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
        revert("Nenhuma vercao ativa encontrada para esta pagina");
    }

    function adicionaNovaVercaoDesativadaAPaginaPorIndexPaginas(uint index, string memory conteudo) public
    {
        require(ativo, "A adicao de novas paginas so e permitida quando a Blockpedia esta ativa");
        require(index < paginas.length, "Indice fora do alcance");
        require(paginas[index].ativo, "A adicao de novas vercoes so e permitida quando a pagina esta ativa");
        
        paginas[index].versoes.push(Versao({
            ativo: false,
            autor: msg.sender,
            dataCriacao : block.timestamp,
            conteudo: conteudo
        }));
    }

    function ativaVersaoPorIndexVersoesEIndexPaginas(uint indexPagina, uint indexVersoes) public
    {
        require(ativo, "A adicao de novas paginas so e permitida quando a Blockpedia esta ativa");
        require(indexPagina < paginas.length, "Indice da pagina fora do alcance");
        require(paginas[indexPagina].ativo, "A alteracao de versao so e permitida quando a pagina esta ativa");
        require(indexVersoes < paginas[indexPagina].versoes.length, "Indice da versao fora do alcance");

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

    function desativaPaginaPorIndexPaginas(uint indexPagina)public
    {
        require(ativo, "A desativacao de paginas so e permitida quando a Blockpedia esta ativa");
        require(indexPagina < paginas.length, "Indice da pagina fora do alcance");
        if(!paginas[indexPagina].ativo) return;
        paginas[indexPagina].ativo=false;
    }

    function ativaPaginaPorIndexPaginas(uint indexPagina)public
    {
        require(ativo, "A ativacao de paginas so e permitida quando a Blockpedia esta ativa");
        require(indexPagina < paginas.length, "Indice da pagina fora do alcance");
        require(!existeTituloAtivo(paginas[indexPagina].titulo), "Ja existe pagina ativa com este titulo");

        if(paginas[indexPagina].ativo) return;
        paginas[indexPagina].ativo=true;
    }

    function getPaginasPorTitulo(string memory titulo) public view returns (uint[] memory)
    {
        uint[] memory indicesPaginasComTitulo = new uint[](paginas.length);
        uint contador = 0;

        for (uint i = 0; i < paginas.length; i++)
        {
            if (comparaString(paginas[i].titulo, titulo))
            {
                indicesPaginasComTitulo[contador] = i;
                contador++;
            }
        }

        // Criar um novo array com o tamanho exato
        uint[] memory indices = new uint[](contador);
        for (uint j = 0; j < contador; j++)
        {
            indices[j] = indicesPaginasComTitulo[j];
        }

        return indices;
    }

    function comparaString(string memory primeiraString, string memory segundaString)internal pure returns(bool)
    {
        //keccak256 é uma funcao hash, estou usando por conta que não tem comparacao de string em solidity
        //abi.encodePacked() serve para transformar a string em um "pacote" binario antes de transformar em hash
        return (keccak256(abi.encodePacked(primeiraString)) == keccak256(abi.encodePacked(segundaString))) ? true:false;
    }

}
