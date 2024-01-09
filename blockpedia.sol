pragma solidity 0.8.0;
// SPDX-License-Identifier: MIT


contract Blockpedia
{
    bool public ativo = true; 
    address public immutable autor; 
    uint256 public immutable dataCriacao;
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
        dataCriacao = block.timestamp;
        criarPagina("Inicio", "Bem vindo a Blockpeida, a enciclopedia na blockchain");
    }

    function criarPagina(string memory _titulo, string memory _conteudo) public somenteSeAtivo 
    {
        require(!existeTituloAtivo(_titulo), "Ja existe pagina ativa com este titulo");

        Pagina storage novaPagina = paginas.push();
        novaPagina.ativo = true;
        novaPagina.autor = msg.sender;
        novaPagina.dataCriacao = block.timestamp;
        novaPagina.titulo = _titulo;
        novaPagina.versoes.push(Versao(true, msg.sender, block.timestamp, _conteudo));
    }

    function ativaDesativaBlockpedia(bool _ativo) public
    {
        require(msg.sender == autor,"Somente o dono desta Blockpedia pode alterar o atributo ativo");
        ativo = _ativo;
    }

    function existeTituloAtivo(string memory _titulo) internal view returns (bool)
    {
        for (uint i = 0; i < paginas.length; i++)
        {
            if (paginas[i].ativo)
                if (comparaString(paginas[i].titulo, _titulo))
                    return true;
        }
        return false;
    }

    function getConteudoVersaoValidaPorIndexPaginas(uint _indice) public view returns (string memory)
    {
        require(_indice < paginas.length, "Indice fora do alcance");

        return getVersaoValidaDeUmaPagina(paginas[_indice]).conteudo;
    }

    function getVersaoValidaDeUmaPagina(Pagina memory _pagina)internal pure returns (Versao memory)
    {
        for(uint i = 0; i < _pagina.versoes.length; i++)
        {
            if(_pagina.versoes[i].ativo)
                return _pagina.versoes[i];
        }
        revert("Nenhuma vercao ativa encontrada para esta pagina");
    }

    function adicionaNovaVercaoDesativadaAPaginaPorIndexPaginas(uint _index, string memory _conteudo) public somenteSeAtivo
    {
        require(_index < paginas.length, "Indice fora do alcance");
        require(paginas[_index].ativo, "A adicao de novas vercoes so e permitida quando a pagina esta ativa");
        
        paginas[_index].versoes.push(Versao({
            ativo: false,
            autor: msg.sender,
            dataCriacao : block.timestamp,
            conteudo: _conteudo
        }));
    }

    function ativaVersaoPorIndexVersoesEIndexPaginas(uint _indexPagina, uint _indexVersoes) public somenteSeAtivo
    {
        require(_indexPagina < paginas.length, "Indice da pagina fora do alcance");
        require(paginas[_indexPagina].ativo, "A alteracao de versao so e permitida quando a pagina esta ativa");
        require(_indexVersoes < paginas[_indexPagina].versoes.length, "Indice da versao fora do alcance");

        if(paginas[_indexPagina].versoes[_indexVersoes].ativo)
            return;

        for (uint i = paginas[_indexPagina].versoes.length; i > 0; i--)
        {
            uint indexAtual = i - 1;
            if (paginas[_indexPagina].versoes[indexAtual].ativo)
            {
                paginas[_indexPagina].versoes[indexAtual].ativo = false;
                break;
            }
        }

        paginas[_indexPagina].versoes[_indexVersoes].ativo = true;
    }

    function desativaPaginaPorIndexPaginas(uint _indexPagina)public somenteSeAtivo
    {
        require(_indexPagina < paginas.length, "Indice da pagina fora do alcance");

        if(!paginas[_indexPagina].ativo)
            return;

        paginas[_indexPagina].ativo=false;
    }

    function ativaPaginaPorIndexPaginas(uint _indexPagina)public somenteSeAtivo
    {
        require(_indexPagina < paginas.length, "Indice da pagina fora do alcance");
        require(!existeTituloAtivo(paginas[_indexPagina].titulo), "Ja existe pagina ativa com este titulo");

        if(paginas[_indexPagina].ativo)
            return;
            
        paginas[_indexPagina].ativo=true;
    }

    function getPaginasPorTitulo(string memory _titulo) public view returns (uint[] memory)
    {
        uint[] memory indicesPaginasComTitulo = new uint[](paginas.length);
        uint contador = 0;

        for (uint i = 0; i < paginas.length; i++)
        {
            if (comparaString(paginas[i].titulo, _titulo))
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

    function comparaString(string memory _primeiraString, string memory _segundaString)internal pure returns(bool)
    {
        //keccak256 é uma funcao hash, estou usando por conta que não tem comparacao de string em solidity
        //abi.encodePacked() serve para transformar a string em um "pacote" binario antes de transformar em hash
        return (keccak256(abi.encodePacked(_primeiraString)) == keccak256(abi.encodePacked(_segundaString))) ? true:false;
    }

    modifier somenteSeAtivo
    {
        require(ativo, "A acao so e permitida quando a Blockpedia esta ativa");
        _;
    }

    receive() external payable
    {
        revert();
    }

    fallback() external payable
    {
        revert();
    }

}