# Índice de evidências

Evidência de execução da entrega VZS-142, separada do report de bugs
(`docs/03-bugs.md`) e da tabela de execução (`docs/02-execucao.md`).

## Evidências de API

As evidências dos bugs e cenários verificados por API são as próprias
requisições e respostas HTTP reais, reproduzidas em `docs/03-bugs.md` e em
`api/verzel-store.http`. Não há print de tela para esses casos — a evidência
é o JSON cru trocado com o servidor.

## Evidências de interface (prints e vídeos)

Arquivos em `docs/04-evidencias/`, nomeados pelo id do bug ou cenário:

| Arquivo | Cenário / Bug | Descrição |
|---|---|---|
| `BUG-01-frete-subtotal-200-com-cupom.png` | BUG-01 / CT-012 | Print do carrinho real mostrando subtotal R$ 200,00, cupom BEMVINDO10 aplicado, frete R$ 19,90 cobrado e o aviso contraditório "Faltam R$ 0,00 para o frete grátis." no mesmo momento em que o frete é cobrado. |
| `BUG-01-CT-008-falha-automatizada.png` | BUG-01 / CT-008 | Screenshot automático de falha gerado pelo Playwright ao rodar o teste CT-008 (subtotal exato de R$ 200,00 sem cupom). |
| `BUG-01-CT-012-falha-automatizada.png` | BUG-01 / CT-012 | Screenshot automático de falha gerado pelo Playwright ao rodar o teste CT-012 (subtotal exato de R$ 200,00 com cupom). |

## Evidências da automação (Playwright)

A suíte em `automacao/` gera, a cada execução, o relatório HTML completo em
`automacao/playwright-report/` (não versionado — ver `automacao/.gitignore`)
e, para testes que falham, screenshot e trace automáticos em
`automacao/test-results/`. Para visualizar depois de rodar os testes:

```
cd automacao
npx playwright show-report
```

O trace de uma falha específica (linha de comando mostrada no próprio
terminal ao final da execução) permite inspecionar passo a passo o DOM, a
rede e o estado da página no momento da falha — é a evidência mais completa
para os cenários CT-008 e CT-012.

## Cobertura

Os 44 cenários de `docs/02-execucao.md` foram executados por completo: 18
via Playwright e 26 via verificação direta da API.
