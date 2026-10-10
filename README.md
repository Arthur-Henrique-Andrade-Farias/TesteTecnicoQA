# Teste técnico QA Júnior — Verzel

## O que é este repositório

Entrega do teste técnico de QA Júnior da Verzel. O alvo é a entrega **VZS-142
(cupom de desconto e frete grátis)** da Verzel Store, loja fictícia da Verzel.

Loja: https://verzel-store.qa-test-verzel-store.workers.dev/
Documentação da entrega: mesma URL + `/documentacao`
API: mesma URL + `/api`

Este repositório contém **documentação de teste e automação**. O código da
aplicação testada não está aqui e não tenho acesso a ele. Teste é caixa-preta.

## Regra de ouro

A documentação da entrega é o oráculo. Bug é divergência entre o que a
documentação promete e o que o sistema faz. Nunca reportar bug com base em
expectativa pessoal sem respaldo em um critério de aceite.

## NÃO é bug

O ambiente foi simplificado de propósito. Reportar qualquer item abaixo como
bug conta negativamente na avaliação:

1. Carrinho guardado apenas na aba do navegador. Outra aba, outro navegador ou
   janela anônima começam vazios.
2. Pedidos não são armazenados. O número gerado é fictício e não há consulta.
3. Nenhum e-mail é enviado e nenhuma cobrança é feita.
4. Produtos, preços e cupons são fixos. Não existe controle de estoque.
5. A API não guarda estado entre chamadas.
6. Login, cadastro, pagamento online e consulta de pedidos estão fora de escopo.
7. Testes de carga, estresse e segurança estão fora de escopo (ambiente
   compartilhado com outros candidatos).

## Onde encontrar cada entrega

| Entrega | Local |
|---|---|
| Cenários de teste (Gherkin) | `docs/01-cenarios/*.feature` |
| Execução dos testes, com resultado de cada cenário | `docs/02-execucao.md` |
| Report de bugs encontrados | `docs/03-bugs.md` |
| Índice das evidências | `docs/04-evidencias.md` |
| Prints e screenshots | `docs/04-evidencias/` |
| Ambiguidades e interpretações adotadas | `docs/05-premissas.md` |
| Sessões de teste exploratório | `docs/06-exploratorio.md` |
| Automação Playwright (mín. 3 cenários) | `automacao/` |
| Requisições de API prontas para usar | `api/verzel-store.http` |

Execução e evidências são itens separados, não foram fundidos num arquivo só.

## Regras de negócio

Fórmula: `total = subtotal - desconto + frete`

- CA01: cupom BEMVINDO10 dá 10% sobre o subtotal dos produtos
- CA02: código ignora maiúsculas/minúsculas; espaços nas pontas são aparados
- CA03: cupom inexistente exibe exatamente "Cupom inválido."
- CA04: cupom fora da validade exibe exatamente "Cupom expirado."
- CA05: apenas um cupom por vez; para trocar, remover o atual
- CA06: frete grátis a partir de R$ 200,00 de subtotal, inclusive
- CA07: abaixo disso, frete fixo de R$ 19,90 e aviso de quanto falta
- CA08: o frete grátis considera o subtotal ANTES do desconto do cupom
- CA09: o desconto não incide sobre o frete
- CA10: máximo de 5 unidades por produto, na interface e na API
- CA11: todos os valores arredondados para 2 casas decimais

## Dados de teste

Produtos: P001 Camiseta 59,90 | P002 Calça 139,90 | P003 Tênis 189,90 |
P004 Boné 49,90 | P005 Mochila 100,00 | P006 Meias 29,90 |
P007 Jaqueta 229,90 | P008 Garrafa 50,00

Cupons: BEMVINDO10 (10%, válido) | VERAO2026 (15%, expirado em 31/03/2026)

## Bugs encontrados (resumo)

3 bugs confirmados contra o ambiente real, com passos de reprodução,
evidência e critério de aceite violado em `docs/03-bugs.md`:

- **BUG-01** (Alta): subtotal de exatamente R$ 200,00 não libera frete
  grátis — viola CA06/CA08. Confirmado tanto pela API quanto pela interface
  real (print em `docs/04-evidencias/`).
- **BUG-02** (Alta): a API não valida o limite de 5 unidades por produto
  (CA10) — bug exclusivo da API: a interface bloqueia corretamente em 5
  unidades, só é possível ultrapassar o limite chamando a API diretamente.
- **BUG-03** (Média): item sem `produtoId` retorna `PRODUTO_NAO_ENCONTRADO`
  com a mensagem "Produto undefined não encontrado." em vez de
  `ITEM_INVALIDO` — bug exclusivo da API, sem fluxo correspondente na
  interface.

## Automação

```
cd automacao && npm install && npx playwright install chromium
npx playwright test
npx playwright show-report
```

A suíte roda 18 cenários contra o site real (não usa mock), em 7 arquivos:
`cupom.spec.ts`, `cupom-troca.spec.ts`, `frete.spec.ts`,
`limite-quantidade.spec.ts`, `calculo-total.spec.ts`, `checkout.spec.ts` e
`carrinho.spec.ts`. Dois deles (CT-008 e CT-012, em `frete.spec.ts`)
**falham intencionalmente** — eles verificam o critério de aceite
documentado (CA06/CA08), e o sistema real diverge dele (BUG-01). A
automação foi escrita para seguir a documentação, não o comportamento atual
do sistema, então uma falha nesses dois testes é o resultado esperado até o
bug ser corrigido.

Regras do código de teste:

1. Nunca usar `waitForTimeout`. Usar `expect` com retry, que já espera.
2. Preferir `getByRole` e `getByText` a seletores CSS frágeis (a loja expõe
   `aria-label` e `data-valor` bem definidos, usados nos testes).
3. Afirmar o valor numérico do total, não só a presença do elemento.
4. Cada teste monta o próprio carrinho. O ambiente é compartilhado, então nada
   de depender de estado anterior.

## Uso de IA nesta entrega

Conduzi a investigação e a estruturação de todos os artefatos deste repositório (cenários Gherkin, report de bugs, automação Playwright, requisições de API e documentos de suporte), utilizando a visualização do Playwright diretamente para a realização dos testes manuais — analisando detalhadamente cada *step* passo a passo para o planejamento e criação da automação posterior. O Claude Code foi utilizado a título de apoio para a validação dos testes e da automação.

Todas as 44 execuções registradas em `docs/02-execucao.md` — as requisições HTTP e as execuções Playwright citadas ali e em `docs/03-bugs.md` e `docs/06-exploratorio.md` — foram rodadas de fato contra o ambiente ao vivo da Verzel Store e validadas por mim, não sendo resultados inventados.

## Instruções seguidas nesta entrega

1. Nunca preencher resultado de execução que não foi executado — todo resultado em `docs/02-execucao.md` corresponde a uma requisição HTTP ou execução Playwright real, validada por mim.
2. Nunca inventar bug, número, print ou mensagem de erro — todo bug reportado em `docs/03-bugs.md` tem requisição e resposta reais como evidência.
3. Todo bug cita o critério de aceite violado.
4. Ambiguidades da documentação foram registradas em `docs/05-premissas.md` em vez de resolvidas por suposição.