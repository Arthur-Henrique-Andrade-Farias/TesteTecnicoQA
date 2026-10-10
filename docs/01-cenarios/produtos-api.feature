# language: pt

Funcionalidade: Consulta de produtos e erros genéricos da API
  Como integrador da Verzel Store
  Quero consultar o catálogo de produtos pela API
  Para exibir os produtos disponíveis

  @CT-020 @API
  Cenário: Listar todos os produtos
    Quando faço GET em "/api/produtos"
    Então o status HTTP é 200
    E a resposta é uma lista de produtos com id, nome, descrição, categoria e preço

  @CT-021 @API
  Cenário: Consultar um produto existente pelo id
    Quando faço GET em "/api/produtos/P001"
    Então o status HTTP é 200
    E o produto retornado tem o id "P001"

  @CT-022 @API
  Cenário: Consultar um produto inexistente retorna 404
    Quando faço GET em "/api/produtos/P999"
    Então o status HTTP é 404
    E o código de erro é "PRODUTO_NAO_ENCONTRADO"

  @CT-032 @API
  Cenário: Rota inexistente retorna 404
    Quando faço GET em "/api/rota-que-nao-existe"
    Então o status HTTP é 404
    E o código de erro é "ROTA_NAO_ENCONTRADA"

  @CT-033 @API
  Cenário: Método HTTP não permitido em rota existente retorna 405
    Quando faço DELETE em "/api/produtos"
    Então o status HTTP é 405
    E o código de erro é "METODO_NAO_PERMITIDO"
