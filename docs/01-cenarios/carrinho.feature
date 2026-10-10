# language: pt

Funcionalidade: Estado do carrinho
  Como cliente da Verzel Store
  Quero que o carrinho reflita corretamente os itens que escolhi
  Para confiar no que vou pagar antes de finalizar a compra

  @CT-041 @Carrinho
  Cenário: Acessar o carrinho sem nenhum item mostra o estado vazio
    Dado que estou na loja Verzel Store com o carrinho vazio
    Quando acesso a página do carrinho
    Então vejo a mensagem "Seu carrinho está vazio"
    E o carrinho exibido no cabeçalho mostra 0 itens

  @CT-042 @Carrinho
  Cenário: Esvaziar o carrinho remove todos os itens
    Dado que adicionei o produto "P001" com quantidade 1 ao carrinho
    E adicionei o produto "P004" com quantidade 1 ao carrinho
    Quando clico em "Esvaziar carrinho"
    Então vejo a mensagem "Seu carrinho está vazio"

  @CT-043 @Carrinho
  Cenário: O carrinho persiste ao recarregar a página na mesma aba
    Dado que adicionei o produto "P005" com quantidade 1 ao carrinho
    Quando recarrego a página do carrinho
    Então o produto "P005" continua no carrinho
    E o subtotal exibido continua "R$ 100,00"
