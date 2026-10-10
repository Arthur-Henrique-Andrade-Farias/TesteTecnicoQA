# language: pt

Funcionalidade: Aplicação de cupom de desconto
  Como cliente da Verzel Store
  Quero aplicar um cupom de desconto no carrinho
  Para pagar menos na minha compra

  Contexto:
    Dado que estou na loja Verzel Store com o carrinho vazio

  @CT-001 @CA01
  Cenário: Aplicar cupom válido concede 10% de desconto sobre o subtotal
    Dado que adicionei o produto "P002" com quantidade 1 ao carrinho
    E adicionei o produto "P004" com quantidade 2 ao carrinho
    Quando aplico o cupom "BEMVINDO10"
    Então o subtotal exibido é "R$ 239,70"
    E o desconto exibido é "R$ 23,97"
    E o total exibido é "R$ 215,73"

  @CT-002 @CA02
  Cenário: Código do cupom em minúsculas é aceito
    Dado que adicionei o produto "P001" com quantidade 1 ao carrinho
    Quando aplico o cupom "bemvindo10"
    Então o cupom "BEMVINDO10" é aplicado com sucesso

  @CT-003 @CA02
  Cenário: Código do cupom com espaços nas pontas é aparado e aceito
    Dado que adicionei o produto "P001" com quantidade 1 ao carrinho
    Quando aplico o cupom "  BEMVINDO10  "
    Então o cupom "BEMVINDO10" é aplicado com sucesso

  @CT-004 @CA03
  Cenário: Cupom inexistente exibe mensagem de cupom inválido
    Dado que adicionei o produto "P001" com quantidade 1 ao carrinho
    Quando aplico o cupom "NAOEXISTE"
    Então vejo a mensagem "Cupom inválido."
    E nenhum desconto é aplicado ao subtotal

  @CT-005 @CA04
  Cenário: Cupom fora da validade exibe mensagem de cupom expirado
    Dado que adicionei o produto "P001" com quantidade 1 ao carrinho
    Quando aplico o cupom "VERAO2026"
    Então vejo a mensagem "Cupom expirado."
    E nenhum desconto é aplicado ao subtotal

  @CT-006 @CA05
  Cenário: Não é possível aplicar um segundo cupom sem remover o atual
    Dado que adicionei o produto "P001" com quantidade 1 ao carrinho
    E apliquei o cupom "BEMVINDO10"
    Quando tento aplicar o cupom "VERAO2026" sem remover o cupom atual
    Então o cupom aplicado continua sendo "BEMVINDO10"

  @CT-007 @CA05
  Cenário: Remover o cupom atual e aplicar outro com sucesso
    Dado que adicionei o produto "P001" com quantidade 1 ao carrinho
    E apliquei o cupom "BEMVINDO10"
    Quando removo o cupom atual
    E aplico o cupom "VERAO2026"
    Então vejo a mensagem "Cupom expirado."
