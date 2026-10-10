# Bugs encontrados

Entrega testada: VZS-142 (cupom de desconto e frete grátis), versão 2.3.0.
Ambiente: https://verzel-store.qa-test-verzel-store.workers.dev/ (API em
`/api`). Testes de API executados em 2026-10-09 via requisições HTTP diretas
(ver `api/verzel-store.http`). Evidência de cada bug é a requisição e
resposta JSON reais, reproduzidas abaixo.

---

## BUG-01 — Subtotal de exatamente R$ 200,00 não libera frete grátis

**Severidade:** Alta.
**Justificativa de negócio:** CA06 promete frete grátis "a partir de R$
200,00, inclusive" e esse valor é anunciado na página inicial da loja
("Frete grátis a partir de R$ 200,00."). Clientes cujo carrinho fecha
exatamente nesse valor — o limite mais citado da promoção — são cobrados
indevidamente, contradizendo tanto o critério de aceite quanto a propaganda
exibida na home. O próprio documento de referência da entrega já previa esse
cenário (carrinho P005 x2 + BEMVINDO10 com total esperado de R$ 180,00).

**Passos para reproduzir:**
1. Montar um carrinho cujo subtotal dos produtos feche em exatamente
   R$ 200,00 (ex.: P005 "Mochila Urbana 20L" x2, R$ 100,00 cada).
2. Calcular o carrinho pela API (`POST /api/carrinho/calcular`), sem cupom.
3. Observar os campos `frete` e `freteGratis` na resposta.
4. Repetir o mesmo carrinho aplicando o cupom `BEMVINDO10` e repetir a
   observação.
5. Repetir com uma segunda combinação de produtos que também soma
   R$ 200,00 (P008 "Garrafa Térmica" x4, R$ 50,00 cada), para descartar erro
   de arredondamento de ponto flutuante.

**Resultado esperado:** CA06 — subtotal a partir de R$ 200,00, **inclusive**,
tem frete grátis (`frete: 0`, `freteGratis: true`). CA08 reforça que essa
verificação usa o subtotal antes do desconto do cupom.

**Resultado obtido:** nas três repetições, com subtotal exato de
R$ 200,00, a API cobra o frete fixo de R$ 19,90 e retorna
`freteGratis: false`. O limite está sendo tratado como estritamente maior
que R$ 200,00, não "a partir de, inclusive".

**Evidência (requisição e resposta reais):**

Sem cupom, P005 x2 (R$ 100,00 cada):
```http
POST /api/carrinho/calcular
{"itens":[{"produtoId":"P005","quantidade":2}]}

200 OK
{"subtotal":200,"desconto":0,"frete":19.9,"freteGratis":false,"valorFaltanteFreteGratis":0,"total":219.9,"cupom":null}
```

Com cupom BEMVINDO10, mesmo carrinho:
```http
POST /api/carrinho/calcular
{"itens":[{"produtoId":"P005","quantidade":2}],"cupom":"BEMVINDO10"}

200 OK
{"subtotal":200,"desconto":20,"frete":19.9,"freteGratis":false,"valorFaltanteFreteGratis":0,"total":199.9,"cupom":{"codigo":"BEMVINDO10","aplicado":true,"mensagem":"Cupom aplicado: 10% de desconto nos produtos."}}
```
(Total obtido R$ 199,90 contra R$ 180,00 esperado pela tabela de referência
da entrega — diferença de R$ 19,90, exatamente o valor do frete cobrado
indevidamente.)

Confirmado também em `POST /api/pedidos` (não fica restrito ao cálculo) e
com uma segunda combinação de produtos (P008 x4) que soma R$ 200,00 por
aritmética inteira, descartando problema de ponto flutuante — ver
`api/verzel-store.http` para as requisições completas.

**Observação adicional:** o campo `valorFaltanteFreteGratis` retorna `0`
nesses casos (coerente com "falta R$ 0,00"), o que reforça que o sistema
reconhece o subtotal como tendo atingido o limite, mas mesmo assim cobra o
frete — um sinal de que a comparação usada no cálculo do frete está com o
operador trocado (`>` no lugar de `>=`).

**Canal:** confirmado nos dois canais — pela API (`/api/carrinho/calcular` e
`/api/pedidos`) e pela interface real, com print em
`docs/04-evidencias/BUG-01-frete-subtotal-200-com-cupom.png`, já que os
cálculos são feitos pela API e a tela só exibe o resultado.

**Ambiente:** API de produção do ambiente de teste, testado em 2026-10-09.

---

## BUG-02 — Limite de 5 unidades por produto (CA10) não é validado pela API

**Severidade:** Alta.
**Justificativa de negócio:** CA10 estabelece o limite de 5 unidades por
produto e afirma explicitamente que "a regra vale para a interface e para a
API". A documentação da API lista o código de erro dedicado
`QUANTIDADE_MAXIMA_EXCEDIDA` (422) para esse caso. Mesmo que a interface
bloqueie o incremento visualmente, qualquer cliente de API (ou um
interceptador de requisição no navegador) contorna o limite por completo,
tornando a regra de negócio inexistente do lado do servidor — que é o único
lado confiável para aplicar uma regra de negócio.

**Passos para reproduzir:**
1. Enviar `POST /api/carrinho/calcular` com um item de quantidade 6.
2. Observar que a resposta é 200, sem erro.
3. Repetir com quantidade 100.
4. Repetir enviando `POST /api/pedidos` com dados de cliente válidos e
   quantidade 6 no item.
5. Para contraste, confirmar que quantidades inválidas por outros motivos
   (0, -1, 1.5, string) continuam sendo corretamente rejeitadas com
   `QUANTIDADE_INVALIDA`, isolando o problema especificamente à checagem do
   limite máximo.

**Resultado esperado:** CA10 — quantidade de um item maior que 5 deve ser
rejeitada com o erro `QUANTIDADE_MAXIMA_EXCEDIDA` e status 422, tanto no
cálculo do carrinho quanto na confirmação do pedido.

**Resultado obtido:** a API aceita qualquer quantidade acima de 5 sem erro,
calculando o subtotal normalmente. O erro `QUANTIDADE_MAXIMA_EXCEDIDA`
nunca é retornado, em nenhuma das duas rotas testadas.

**Evidência (requisição e resposta reais):**

Quantidade 6 no cálculo do carrinho:
```http
POST /api/carrinho/calcular
{"itens":[{"produtoId":"P001","quantidade":6}]}

200 OK
{"itens":[{"produtoId":"P001","nome":"Camiseta Essencial","precoUnitario":59.9,"quantidade":6,"total":359.4}],"subtotal":359.4,"desconto":0,"frete":0,"freteGratis":true,"valorFaltanteFreteGratis":0,"total":359.4,"cupom":null}
```

Quantidade 100, mesmo endpoint:
```http
POST /api/carrinho/calcular
{"itens":[{"produtoId":"P001","quantidade":100}]}

200 OK
{"subtotal":5990, ... "total":5990}
```

Quantidade 6 na confirmação do pedido (gera pedido normalmente, sem erro):
```http
POST /api/pedidos
{"cliente":{"nome":"Maria Silva","email":"maria@exemplo.com","cep":"01310100"},"itens":[{"produtoId":"P001","quantidade":6}]}

201 Created
{"numero":"VZ-453912", ... "itens":[{"produtoId":"P001","quantidade":6,"total":359.4}], ...}
```

Por contraste, quantidade 0, -1, 1.5 e `"3"` (string) são corretamente
rejeitadas com `QUANTIDADE_INVALIDA` nas mesmas rotas — ver
`api/verzel-store.http` — confirmando que apenas a checagem do teto de 5
unidades está ausente, não a validação de quantidade como um todo.

**Canal:** bug exclusivo da API. Pela interface, o botão "+" do seletor de
quantidade fica corretamente desabilitado ao chegar em 5 unidades (ver
CT-014, `automacao/tests/limite-quantidade.spec.ts`) — não há como alcançar
quantidade 6 clicando na tela. O bug só é alcançável enviando a requisição
HTTP diretamente, contornando a interface.

**Ambiente:** API de produção do ambiente de teste, testado em 2026-10-09.

---

## BUG-03 — Item sem `produtoId` retorna `PRODUTO_NAO_ENCONTRADO` com "Produto undefined não encontrado." em vez de `ITEM_INVALIDO`

**Severidade:** Média.
**Justificativa de negócio:** a documentação define `ITEM_INVALIDO` como "um
item não é um objeto com produtoId e quantidade" (422) e `PRODUTO_NAO_ENCONTRADO`
como "um item referencia um produto inexistente" (422). Um item sem o campo
`produtoId` não referencia produto nenhum — ele não atende ao formato
esperado, que é exatamente o caso que `ITEM_INVALIDO` deveria cobrir. Em vez
disso, a API trata o campo ausente como se fosse a string literal
`"undefined"` e devolve essa palavra, um artefato interno de JavaScript, na
mensagem de erro voltada ao integrador. Não é um erro que afeta o cálculo de
cupom ou frete, mas é uma resposta de API incorreta e não profissional para
quem está integrando com a loja — por isso a severidade é média, não alta.

**Passos para reproduzir:**
1. Enviar `POST /api/carrinho/calcular` ou `POST /api/pedidos` com um item
   contendo `quantidade` mas sem a chave `produtoId` (ex.:
   `{"itens":[{"quantidade":1}]}`), ou com um item como objeto vazio
   (`{}`).
2. Observar o código de erro e a mensagem retornados.

**Resultado esperado:** segundo a tabela de erros da documentação, um item
que não é um objeto válido com `produtoId` e `quantidade` deveria retornar
`ITEM_INVALIDO` (422).

**Resultado obtido:** a API retorna `PRODUTO_NAO_ENCONTRADO` (422) com a
mensagem "Produto undefined não encontrado.", como se `produtoId` tivesse
sido informado com o valor `"undefined"`.

**Evidência (requisição e resposta reais):**
```http
POST /api/carrinho/calcular
{"itens":[{"quantidade":1}]}

422 Unprocessable Entity
{"erro":{"codigo":"PRODUTO_NAO_ENCONTRADO","mensagem":"Produto undefined não encontrado.","campo":"itens[0].produtoId"}}
```
```http
POST /api/pedidos
{"cliente":{"nome":"Maria Silva","email":"maria@exemplo.com","cep":"01310100"},"itens":[{}]}

422 Unprocessable Entity
{"erro":{"codigo":"PRODUTO_NAO_ENCONTRADO","mensagem":"Produto undefined não encontrado.","campo":"itens[0].produtoId"}}
```
Por contraste, um item que não é um objeto (ex.: `{"itens":["P001"]}`) é
corretamente classificado como `ITEM_INVALIDO`, confirmando que a checagem
de formato existe, mas não cobre o caso específico de `produtoId` ausente
dentro de um objeto — ver `api/verzel-store.http`.

**Canal:** bug exclusivo da API. A interface nunca monta um item sem
`produtoId` — o carrinho é sempre populado a partir de um produto real do
catálogo — então não existe fluxo de tela que reproduza este caso. Só é
alcançável montando a requisição HTTP manualmente.

**Ambiente:** API de produção do ambiente de teste, testado em 2026-10-09.

---

## Cobertura

Os 44 cenários de `docs/01-cenarios/` e as 7 sessões exploratórias de
`docs/06-exploratorio.md` foram executados por completo (detalhamento em
`docs/02-execucao.md`). Esses 3 bugs são todos os encontrados nesta
entrega.
