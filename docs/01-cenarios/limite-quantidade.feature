# language: pt

Funcionalidade: Limite máximo de unidades por produto
  Como loja Verzel Store
  Quero limitar a quantidade de cada produto por pedido
  Para manter a regra de negócio consistente entre interface e API

  @CT-014 @CA10
  Cenário: Interface impede adicionar mais de 5 unidades do mesmo produto
    Dado que adicionei um produto ao carrinho
    Quando clico no botão de aumentar quantidade repetidamente
    Então o botão de aumentar quantidade fica desabilitado ao atingir 5 unidades
    E a mensagem "Limite de 5 unidades por produto." é exibida

  @CT-015 @CA10
  Cenário: API recusa quantidade acima de 5 unidades no cálculo do carrinho
    Dado que monto uma requisição para "/api/carrinho/calcular"
    Quando envio o item "P001" com quantidade 6
    Então a API responde com o código de erro "QUANTIDADE_MAXIMA_EXCEDIDA"
    E o status HTTP é 422

  @CT-016 @CA10
  Cenário: API recusa quantidade acima de 5 unidades na confirmação do pedido
    Dado que monto uma requisição para "/api/pedidos" com dados de cliente válidos
    Quando envio o item "P001" com quantidade 6
    Então a API responde com o código de erro "QUANTIDADE_MAXIMA_EXCEDIDA"
    E o status HTTP é 422

  @CT-016b @CA10
  Cenário: Mesmo produto enviado em dois itens distintos é rejeitado como duplicado
    Dado que monto uma requisição para "/api/carrinho/calcular"
    Quando envio o item "P001" com quantidade 3 e novamente o item "P001" com quantidade 4
    Então a API responde com o código de erro "ITEM_DUPLICADO"
    E o status HTTP é 422
