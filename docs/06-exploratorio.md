# Sessões exploratórias

Formato baseado em Session-Based Test Management (charter, tempo, notas,
bugs/questões encontrados). As 7 sessões abaixo foram de fato rodadas, via
requisições HTTP reais contra a API e via Playwright contra a UI real, como
parte da investigação que também gerou `docs/03-bugs.md`.

---

## Sessão 01 — Limites exatos de frete grátis e cupom

**Charter:** explorar o comportamento do cálculo de frete e desconto nos
valores de fronteira da regra de R$ 200,00 (exatamente no limite, um
centavo abaixo, um centavo acima), com e sem cupom, usando mais de uma
combinação de produtos para descartar erro de ponto flutuante.
**Área:** CA06, CA07, CA08, CA09.
**Status:** Executada (2026-10-09), via API.
**Duração:** ~20 min.

**Notas:**
- Subtotal de exatamente R$ 200,00 (testado com P005 x2 e, separadamente,
  com P008 x4) cobra frete de R$ 19,90 em vez de ficar grátis, com e sem
  cupom aplicado. Virou **BUG-01**.
- R$ 199,90 (um real e 10 centavos abaixo) cobra frete corretamente.
- R$ 200,01 ou mais (ex.: R$ 249,80) libera frete grátis corretamente — o
  problema é isolado ao valor exato de R$ 200,00, não à faixa inteira.
- O campo `valorFaltanteFreteGratis` retorna `0` mesmo quando o frete é
  cobrado no limite exato, o que por si só já é uma contradição visível na
  tela ("Faltam R$ 0,00 para o frete grátis" ao lado de um frete cobrado).

---

## Sessão 02 — Formatos malformados de item na API

**Charter:** enviar itens fora do formato esperado (`produtoId` ausente,
`quantidade` ausente, item como string, objeto vazio, tipos errados de
quantidade) em `/api/carrinho/calcular` e `/api/pedidos`, e comparar qual
código de erro cada formato dispara contra a tabela de erros da
documentação.
**Área:** validação de entrada da API (`ITEM_INVALIDO`, `PRODUTO_NAO_ENCONTRADO`,
`QUANTIDADE_INVALIDA`).
**Status:** Executada (2026-10-09), via API.
**Duração:** ~15 min.

**Notas:**
- Item que não é um objeto (ex.: `"P001"` solto na lista) corretamente
  dispara `ITEM_INVALIDO`.
- Item objeto sem `quantidade` (só `produtoId`) dispara `QUANTIDADE_INVALIDA`
  — razoável, dado que o campo ausente é tratado como quantidade inválida.
- Item objeto sem `produtoId` (ou objeto vazio `{}`) dispara
  `PRODUTO_NAO_ENCONTRADO` com a mensagem "Produto undefined não
  encontrado.", vazando um artefato de JavaScript (`undefined`) numa
  resposta pública de API. Virou **BUG-03**.
- Quantidade 0, -1, 1.5 e string (`"3"`) são corretamente rejeitadas com
  `QUANTIDADE_INVALIDA` em ambas as rotas.

---

## Sessão 03 — Limite de 5 unidades, interface vs. API

**Charter:** comparar o comportamento do limite de 5 unidades por produto
(CA10) entre a interface (carrinho) e a API, incluindo o caso de contornar o
limite da interface enviando a mesma requisição que a API aceitaria
diretamente.
**Área:** CA10.
**Status:** Executada (2026-10-09), via Playwright (UI) e via API.
**Duração:** ~15 min.

**Notas:**
- Na interface, o botão "+" do seletor de quantidade no carrinho fica
  desabilitado ao atingir 5 unidades, com o aviso "Limite de 5 unidades por
  produto." — a regra está corretamente implementada do lado do cliente.
- Pela API, quantidades de 6 até 100 (testado) são aceitas sem nenhum erro,
  tanto em `/api/carrinho/calcular` quanto em `/api/pedidos` (que inclusive
  confirma o pedido com 201, número de pedido incluso). O erro documentado
  `QUANTIDADE_MAXIMA_EXCEDIDA` nunca é retornado. Virou **BUG-02** — a
  regra "vale para a interface e para a API" do CA10 só é verdadeira para a
  interface.
- Enviar o mesmo produto em dois itens separados (ex.: quantidade 3 + 4) é
  corretamente rejeitado como `ITEM_DUPLICADO`, então essa não é uma forma
  de contornar o limite — mas enviar um único item com quantidade alta
  continua sendo.

---

## Sessão 04 — Fluxo de troca e remoção de cupom (CA05)

**Charter:** aplicar um cupom válido, tentar aplicar um segundo cupom sem
remover o primeiro, remover o cupom aplicado e aplicar um cupom diferente,
observando mensagens e estado da tela em cada etapa.
**Área:** CA05.
**Status:** Executada (2026-10-09), via Playwright.
**Duração:** ~10 min.

**Notas:**
- Assim que um cupom é aplicado com sucesso, o campo de texto `#campo-cupom`
  e o botão "Aplicar cupom" desaparecem da tela, substituídos por uma caixa
  "Cupom BEMVINDO10 aplicado." com um botão "Remover cupom". Não existe
  nenhuma forma de digitar um segundo código enquanto essa caixa estiver
  visível — a CA05 é garantida estruturalmente pela interface, não por uma
  mensagem de erro ao tentar trocar.
- Clicar em "Remover cupom" (é um `<button>`, não um link, apesar do estilo
  sublinhado) faz o campo de texto voltar, com o desconto voltando a
  R$ 0,00.
- Aplicar um cupom diferente (`VERAO2026`) logo em seguida funciona
  normalmente e mostra "Cupom expirado.", como esperado pela CA04.
- Nenhum bug encontrado nesta sessão.

---

## Sessão 05 — Fluxo completo de checkout pela interface

**Charter:** percorrer o checkout do carrinho até a confirmação do pedido
pela tela (não pela API), incluindo preenchimento de nome, e-mail e CEP,
validações de campo exibidas na interface e o número de pedido mostrado ao
final.
**Área:** fluxo de checkout, validação de cliente na UI.
**Status:** Executada (2026-10-09), via Playwright.
**Duração:** ~15 min.

**Notas:**
- O botão "Finalizar compra" no carrinho é um link para `/checkout`, uma
  página separada com formulário "Dados para entrega" (nome, e-mail, CEP) e
  o mesmo resumo do pedido do carrinho.
- Com dados válidos, o botão "Confirmar pedido" muda para o estado
  "Confirmando pedido..." (desabilitado) enquanto a API processa, depois
  navega para `/pedido-confirmado`, mostrando "Pedido confirmado", o número
  no formato `VZ-000000`, mensagem de agradecimento e o resumo final. O
  contador do carrinho no cabeçalho volta a 0 depois da confirmação.
- Com nome sem sobrenome ("Maria"), a página não navega: o campo de nome
  fica com borda vermelha, `aria-invalid="true"`, e a mensagem "Informe nome
  e sobrenome." aparece logo abaixo — exatamente o mesmo texto do erro
  `DADOS_INVALIDOS` da API, consistente entre os dois.
- Nenhum bug encontrado nesta sessão.

---

## Sessão 06 — Carrinho vazio e esvaziar carrinho

**Charter:** explorar o comportamento do carrinho vazio (acesso direto à
página `/carrinho` sem itens, tentativa de finalizar compra vazio) e o
botão "Esvaziar carrinho".
**Área:** carrinho.
**Status:** Executada (2026-10-09), via Playwright.
**Duração:** ~10 min.

**Notas:**
- Acessar `/carrinho` diretamente sem nenhum item mostra "Seu carrinho está
  vazio", com um botão "Ver produtos" — sem erro, sem carregar o resumo de
  valores.
- "Esvaziar carrinho" também é um `<button>` (não um link, apesar do
  sublinhado) e não abre nenhum diálogo de confirmação do navegador — a
  remoção é imediata. Depois de clicar, a tela volta ao mesmo estado vazio.
- Não cheguei a tentar finalizar compra com o carrinho vazio pela tela — o
  botão "Finalizar compra" só existe dentro do resumo do carrinho, que não é
  renderizado quando ele está vazio, então esse caminho parece
  estruturalmente inacessível pela UI (diferente da API, que tem o erro
  dedicado `ITENS_OBRIGATORIOS` para esse caso).
- Nenhum bug encontrado nesta sessão.

---

## Sessão 07 — Persistência do carrinho na mesma aba

**Charter:** confirmar que o carrinho persiste ao recarregar a página na
mesma aba (F5) e ao navegar entre páginas da loja, dentro da mesma aba —
sem contradizer a simplificação documentada de que outra aba/navegador
começa vazio.
**Área:** carrinho, estado da sessão.
**Status:** Executada (2026-10-09), via Playwright.
**Duração:** ~5 min.

**Notas:**
- Adicionar um item e recarregar a página (`page.reload()`, equivalente a
  F5) na mesma aba mantém o item, a quantidade e o subtotal exatamente como
  estavam antes do reload. Consistente com a simplificação documentada
  ("carrinho guardado apenas na aba do navegador") — o que não é bug é
  especificamente outra aba/navegador começar vazio, não o reload na mesma
  aba, e isso de fato funciona.
- Nenhum bug encontrado nesta sessão.
