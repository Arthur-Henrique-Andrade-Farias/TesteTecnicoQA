# language: pt

Funcionalidade: Validação dos dados do cliente na confirmação do pedido
  Como loja Verzel Store
  Quero validar os dados do cliente antes de confirmar o pedido
  Para garantir que o pedido possa ser entregue e cobrado

  @CT-034 @ValidacaoCliente
  Cenário: Nome sem sobrenome retorna erro 422
    Quando confirmo um pedido com nome do cliente "Maria", item "P001" quantidade 1
    Então o status HTTP é 422
    E o código de erro é "DADOS_INVALIDOS"
    E o campo com erro é "cliente.nome"

  @CT-035 @ValidacaoCliente
  Cenário: E-mail em formato inválido retorna erro 422
    Quando confirmo um pedido com email do cliente "invalido", item "P001" quantidade 1
    Então o status HTTP é 422
    E o código de erro é "DADOS_INVALIDOS"
    E o campo com erro é "cliente.email"

  @CT-036 @ValidacaoCliente
  Cenário: CEP com formato inválido retorna erro 422
    Quando confirmo um pedido com CEP do cliente "123", item "P001" quantidade 1
    Então o status HTTP é 422
    E o código de erro é "DADOS_INVALIDOS"
    E o campo com erro é "cliente.cep"

  @CT-037 @ValidacaoCliente
  Cenário: CEP com hífen e 8 dígitos é aceito
    Quando confirmo um pedido com CEP do cliente "01310-100", item "P001" quantidade 1
    Então o status HTTP é 201
