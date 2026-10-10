# language: pt

Funcionalidade: Confirmação do pedido pela interface
  Como cliente da Verzel Store
  Quero confirmar meu pedido preenchendo meus dados de entrega
  Para finalizar a compra

  Contexto:
    Dado que estou na loja Verzel Store com o carrinho vazio

  @CT-039 @Checkout
  Cenário: Confirmar pedido com dados válidos exibe o número do pedido e esvazia o carrinho
    Dado que adicionei o produto "P001" com quantidade 1 ao carrinho
    E estou na página de finalizar compra
    Quando preencho nome "Maria Silva", e-mail "maria@exemplo.com" e CEP "01310-100"
    E confirmo o pedido
    Então vejo a mensagem "Pedido confirmado"
    E o número do pedido segue o formato "VZ-000000"
    E o carrinho exibido no cabeçalho volta a mostrar 0 itens

  @CT-040 @ValidacaoCliente
  Cenário: Nome sem sobrenome no checkout exibe erro inline e não confirma o pedido
    Dado que adicionei o produto "P001" com quantidade 1 ao carrinho
    E estou na página de finalizar compra
    Quando preencho nome "Maria", e-mail "maria@exemplo.com" e CEP "01310-100"
    E confirmo o pedido
    Então vejo a mensagem "Informe nome e sobrenome." junto ao campo de nome
    E continuo na página de finalizar compra
