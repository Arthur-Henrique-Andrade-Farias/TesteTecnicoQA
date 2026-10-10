# language: pt

Funcionalidade: Cálculo do carrinho e confirmação de pedidos pela API
  Como integrador da Verzel Store
  Quero calcular o carrinho e confirmar pedidos pela API
  Para que a interface exiba valores corretos e o cliente finalize a compra

  @CT-023 @API @CA03
  Cenário: Calcular carrinho com cupom inválido não gera erro, apenas mensagem
    Quando calculo o carrinho com o item "P001" quantidade 1 e cupom "NAOEXISTE"
    Então o status HTTP é 200
    E o campo "cupom.aplicado" é "false"
    E o campo "cupom.mensagem" é "Cupom inválido."
    E o campo "desconto" é "0"

  @CT-024 @API @CA04
  Cenário: Calcular carrinho com cupom expirado não gera erro, apenas mensagem
    Quando calculo o carrinho com o item "P001" quantidade 1 e cupom "VERAO2026"
    Então o status HTTP é 200
    E o campo "cupom.aplicado" é "false"
    E o campo "cupom.mensagem" é "Cupom expirado."
    E o campo "desconto" é "0"

  @CT-025 @API @CA03
  Cenário: Confirmar pedido com cupom inválido retorna erro 422
    Quando confirmo um pedido com dados de cliente válidos, item "P001" quantidade 1 e cupom "NAOEXISTE"
    Então o status HTTP é 422
    E o código de erro é "CUPOM_INVALIDO"

  @CT-026 @API @CA04
  Cenário: Confirmar pedido com cupom expirado retorna erro 422
    Quando confirmo um pedido com dados de cliente válidos, item "P001" quantidade 1 e cupom "VERAO2026"
    Então o status HTTP é 422
    E o código de erro é "CUPOM_EXPIRADO"

  @CT-027 @API
  Cenário: Confirmar pedido sem itens retorna erro 422
    Quando confirmo um pedido com dados de cliente válidos e sem itens
    Então o status HTTP é 422
    E o código de erro é "ITENS_OBRIGATORIOS"

  @CT-028 @API
  Cenário: Confirmar pedido com item sem produtoId ou quantidade retorna erro 422
    Quando confirmo um pedido com dados de cliente válidos e um item malformado
    Então o status HTTP é 422
    E o código de erro é "ITEM_INVALIDO"

  @CT-029 @API
  Cenário: Confirmar pedido com produto inexistente retorna erro 422
    Quando confirmo um pedido com dados de cliente válidos e o item "P999" quantidade 1
    Então o status HTTP é 422
    E o código de erro é "PRODUTO_NAO_ENCONTRADO"

  @CT-030 @API
  Cenário: Confirmar pedido com quantidade não inteira ou menor que 1 retorna erro 422
    Quando confirmo um pedido com dados de cliente válidos e o item "P001" quantidade 0
    Então o status HTTP é 422
    E o código de erro é "QUANTIDADE_INVALIDA"

  @CT-031 @API
  Cenário: Corpo da requisição que não é um JSON válido retorna erro 400
    Quando envio um corpo que não é um JSON válido para "/api/carrinho/calcular"
    Então o status HTTP é 400
    E o código de erro é "JSON_INVALIDO"

  @CT-038 @API
  Cenário: Confirmar pedido com dados válidos retorna número de pedido
    Quando confirmo um pedido com dados de cliente válidos e o item "P001" quantidade 1
    Então o status HTTP é 201
    E o campo "numero" segue o formato "VZ-000000"
