# language: pt

Funcionalidade: Cálculo do total do pedido
  Como cliente da Verzel Store
  Quero ver o total correto do meu pedido
  Para saber exatamente quanto vou pagar

  Contexto:
    Dado que estou na loja Verzel Store com o carrinho vazio

  @CT-017 @CA11
  Cenário: Valores da API são arredondados para 2 casas decimais
    Dado que adicionei o produto "P002" com quantidade 3 ao carrinho
    Quando calculo o carrinho pela API
    Então o campo "subtotal" é exatamente "419.7"
    E o campo "subtotal" não contém mais de 2 casas decimais

  @CT-018 @FormulaTotal
  Cenário: Total sem cupom segue a fórmula subtotal - desconto + frete
    Dado que adicionei o produto "P008" com quantidade 3 ao carrinho
    E adicionei o produto "P004" com quantidade 1 ao carrinho
    Quando visualizo o resumo do carrinho
    Então o subtotal exibido é "R$ 199,90"
    E o desconto exibido é "R$ 0,00"
    E o frete exibido é "R$ 19,90"
    E o total exibido é "R$ 219,80"

  @CT-019 @FormulaTotal
  Cenário: Total com cupom e frete pago segue a fórmula subtotal - desconto + frete
    Dado que adicionei o produto "P006" com quantidade 3 ao carrinho
    Quando aplico o cupom "BEMVINDO10"
    Então o subtotal exibido é "R$ 89,70"
    E o desconto exibido é "R$ 8,97"
    E o frete exibido é "R$ 19,90"
    E o total exibido é "R$ 100,63"
