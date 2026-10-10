# Execução dos testes

Entrega testada: VZS-142 (cupom de desconto e frete grátis), versão 2.3.0.
Cenários completos em `docs/01-cenarios/*.feature`. Bugs encontrados em
`docs/03-bugs.md`. Evidências em `docs/04-evidencias.md` e
`docs/04-evidencias/`.

Legenda de tipo de execução:
- **UI-Automatizado**: rodado pela suíte Playwright (`automacao/`), contra o
  site real, em 2026-10-09.
- **API-Verificado**: requisição HTTP real enviada direto para a API
  (`api/verzel-store.http`), em 2026-10-09.

| CT | CA | Cenário | Tipo | Resultado | Observações |
|---|---|---|---|---|---|
| CT-001 | CA01 | Cupom válido aplica 10% de desconto | UI-Automatizado | Passou | `automacao/tests/cupom.spec.ts` |
| CT-002 | CA02 | Cupom em minúsculas é aceito | API-Verificado | Passou | cupom `"  bemvindo10  "` aplicado como `BEMVINDO10` |
| CT-003 | CA02 | Cupom com espaços nas pontas é aparado | API-Verificado | Passou | mesma requisição de CT-002 |
| CT-004 | CA03 | Cupom inexistente exibe "Cupom inválido." | UI-Automatizado | Passou | `automacao/tests/cupom.spec.ts` |
| CT-005 | CA04 | Cupom expirado exibe "Cupom expirado." (interface) | UI-Automatizado | Passou | `automacao/tests/cupom-troca.spec.ts` |
| CT-006 | CA05 | Não é possível aplicar 2º cupom sem remover o atual | UI-Automatizado | Passou | campo de cupom some da tela enquanto houver cupom aplicado |
| CT-007 | CA05 | Remover cupom e aplicar outro | UI-Automatizado | Passou | `automacao/tests/cupom-troca.spec.ts` |
| CT-008 | CA06 | Subtotal exatamente R$ 200,00 tem frete grátis | UI-Automatizado | **Falhou** | BUG-01 — ver `docs/03-bugs.md` |
| CT-009 | CA06 | Subtotal acima de R$ 200,00 tem frete grátis | UI-Automatizado | Passou | `automacao/tests/frete.spec.ts` |
| CT-010 | CA07 | Subtotal abaixo de R$ 200,00 cobra frete de R$ 19,90 | UI-Automatizado | Passou | `automacao/tests/frete.spec.ts` |
| CT-011 | CA07 | Aviso de quanto falta para frete grátis | UI-Automatizado | Passou | mesmo teste de CT-010 |
| CT-012 | CA08 | Frete grátis considera subtotal antes do desconto | UI-Automatizado | **Falhou** | BUG-01 — mesma causa de CT-008 |
| CT-013 | CA09 | Desconto não incide sobre o frete | UI-Automatizado | Passou | `automacao/tests/calculo-total.spec.ts` |
| CT-014 | CA10 | Interface impede mais de 5 unidades do mesmo produto | UI-Automatizado | Passou | `automacao/tests/limite-quantidade.spec.ts` |
| CT-015 | CA10 | API recusa quantidade > 5 no cálculo do carrinho | API-Verificado | **Falhou** | BUG-02 — aceitou quantidade 6 e 100 sem erro |
| CT-016 | CA10 | API recusa quantidade > 5 na confirmação do pedido | API-Verificado | **Falhou** | BUG-02 — pedido criado (201) com quantidade 6 |
| CT-016b | CA10 | Produto duplicado em dois itens é rejeitado | API-Verificado | Passou | retorna `ITEM_DUPLICADO` / 422 |
| CT-017 | CA11 | Valores da API arredondados em 2 casas decimais | API-Verificado | Passou | P002 x3 = 419.7, P006 x3 = 89.7, sem artefato de ponto flutuante |
| CT-018 | — | Total sem cupom segue a fórmula (interface) | UI-Automatizado | Passou | `automacao/tests/calculo-total.spec.ts` |
| CT-019 | — | Total com cupom e frete pago segue a fórmula (interface) | UI-Automatizado | Passou | `automacao/tests/calculo-total.spec.ts` |
| CT-020 | — | GET /api/produtos lista produtos | API-Verificado | Passou | HTTP 200 |
| CT-021 | — | GET /api/produtos/{id} existente | API-Verificado | Passou | HTTP 200 |
| CT-022 | — | GET /api/produtos/{id} inexistente | API-Verificado | Passou | HTTP 404, `PRODUTO_NAO_ENCONTRADO` |
| CT-023 | CA03 | Calcular com cupom inválido não gera erro, só mensagem | API-Verificado | Passou | HTTP 200, `cupom.mensagem = "Cupom inválido."` |
| CT-024 | CA04 | Calcular com cupom expirado não gera erro, só mensagem | API-Verificado | Passou | HTTP 200, `cupom.mensagem = "Cupom expirado."` |
| CT-025 | CA03 | Confirmar pedido com cupom inválido retorna 422 | API-Verificado | Passou | `CUPOM_INVALIDO` |
| CT-026 | CA04 | Confirmar pedido com cupom expirado retorna 422 | API-Verificado | Passou | `CUPOM_EXPIRADO` |
| CT-027 | — | Confirmar pedido sem itens retorna 422 | API-Verificado | Passou | `ITENS_OBRIGATORIOS` |
| CT-028 | — | Item sem produtoId/quantidade retorna 422 ITEM_INVALIDO | API-Verificado | **Falhou** | BUG-03 — retorna `PRODUTO_NAO_ENCONTRADO` com "Produto undefined não encontrado." |
| CT-029 | — | Produto inexistente no pedido retorna 422 | API-Verificado | Passou | `PRODUTO_NAO_ENCONTRADO` |
| CT-030 | — | Quantidade inválida no pedido retorna 422 | API-Verificado | Passou | `QUANTIDADE_INVALIDA` |
| CT-031 | — | Corpo não-JSON retorna 400 | API-Verificado | Passou | `JSON_INVALIDO` |
| CT-032 | — | Rota inexistente retorna 404 | API-Verificado | Passou | `ROTA_NAO_ENCONTRADA` |
| CT-033 | — | Método não permitido retorna 405 | API-Verificado | Passou | `METODO_NAO_PERMITIDO` |
| CT-034 | — | Nome sem sobrenome retorna 422 DADOS_INVALIDOS | API-Verificado | Passou | campo `cliente.nome` |
| CT-035 | — | E-mail inválido retorna 422 DADOS_INVALIDOS | API-Verificado | Passou | campo `cliente.email` |
| CT-036 | — | CEP inválido retorna 422 DADOS_INVALIDOS | API-Verificado | Passou | campo `cliente.cep` |
| CT-037 | — | CEP com hífen e 8 dígitos é aceito | API-Verificado | Passou | pedido confirmado com 201 |
| CT-038 | — | Pedido válido retorna número VZ-000000 | API-Verificado | Passou | formato confirmado |
| CT-039 | — | Confirmar pedido exibe número VZ-000000 e esvazia o carrinho (interface) | UI-Automatizado | Passou | `automacao/tests/checkout.spec.ts` |
| CT-040 | — | Nome sem sobrenome no checkout exibe erro inline | UI-Automatizado | Passou | `automacao/tests/checkout.spec.ts` |
| CT-041 | — | Carrinho vazio mostra estado vazio | UI-Automatizado | Passou | `automacao/tests/carrinho.spec.ts` |
| CT-042 | — | Esvaziar carrinho remove todos os itens | UI-Automatizado | Passou | `automacao/tests/carrinho.spec.ts` |
| CT-043 | — | Carrinho persiste ao recarregar a página na mesma aba | UI-Automatizado | Passou | `automacao/tests/carrinho.spec.ts` |

## Resumo

- 44 cenários levantados (CT-001 a CT-043, mais CT-016b), todos executados:
  18 via automação Playwright contra a UI real (`automacao/`) e 26 via
  verificação direta da API (`api/verzel-store.http`).
- 39 passaram e 5 falharam, reproduzindo os 3 bugs documentados em
  `docs/03-bugs.md`:
  - BUG-01 (CA06/CA08, frete no limite exato de R$ 200,00): CT-008, CT-012.
  - BUG-02 (CA10, limite de 5 unidades não validado na API): CT-015, CT-016.
  - BUG-03 (item sem `produtoId` classificado com o código errado): CT-028.
