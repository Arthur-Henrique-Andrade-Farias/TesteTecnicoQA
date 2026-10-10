# language: pt

Funcionalidade: Frete grátis a partir de R$ 200,00
  Como cliente da Verzel Store
  Quero ganhar frete grátis em compras maiores
  Para pagar menos na minha compra

  Contexto:
    Dado que estou na loja Verzel Store com o carrinho vazio

  @CT-008 @CA06
  Cenário: Subtotal exatamente igual a R$ 200,00 tem frete grátis
    Dado que montei um carrinho com subtotal exato de "R$ 200,00"
    Quando visualizo o resumo do carrinho
    Então o frete exibido é "R$ 0,00"
    E a mensagem de frete grátis é exibida

  @CT-009 @CA06
  Cenário: Subtotal acima de R$ 200,00 tem frete grátis
    Dado que adicionei o produto "P007" com quantidade 1 ao carrinho
    Quando visualizo o resumo do carrinho
    Então o frete exibido é "R$ 0,00"

  @CT-010 @CA07
  Cenário: Subtotal abaixo de R$ 200,00 cobra frete fixo de R$ 19,90
    Dado que adicionei o produto "P003" com quantidade 1 ao carrinho
    Quando visualizo o resumo do carrinho
    Então o frete exibido é "R$ 19,90"

  @CT-011 @CA07
  Cenário: Carrinho abaixo do limite informa quanto falta para frete grátis
    Dado que adicionei o produto "P005" com quantidade 1 ao carrinho
    Quando visualizo o resumo do carrinho
    Então vejo o aviso de que faltam "R$ 100,00" para o frete grátis

  @CT-012 @CA08
  Cenário: Frete grátis considera o subtotal antes do desconto do cupom
    Dado que adicionei o produto "P005" com quantidade 2 ao carrinho
    E o subtotal dos produtos é "R$ 200,00"
    Quando aplico o cupom "BEMVINDO10"
    Então o frete exibido continua "R$ 0,00"
    E o total exibido é "R$ 180,00"

  @CT-013 @CA09
  Cenário: O desconto do cupom não incide sobre o valor do frete
    Dado que adicionei o produto "P003" com quantidade 1 ao carrinho
    Quando aplico o cupom "BEMVINDO10"
    Então o frete exibido é "R$ 19,90"
    E o total exibido é "R$ 190,81"
