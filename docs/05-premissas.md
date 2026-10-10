# Premissas e ambiguidades

Interpretações adotadas quando a documentação da entrega (VZS-142) não deixa
um comportamento explícito. Cada item cita o ponto da documentação que gerou
a dúvida e a interpretação seguida para desenhar os cenários.

## P01 — Texto exato das mensagens de cupom

CA03 e CA04 definem o texto exato "Cupom inválido." e "Cupom expirado." para
a resposta da API (confirmado literalmente no campo `cupom.mensagem`). A
documentação não garante que a interface exiba essa mesma string
literalmente na tela (poderia, por exemplo, envolver a mensagem em um texto
maior, do tipo "Erro: Cupom inválido."). Interpretação adotada: os cenários
de interface verificam que o texto "Cupom inválido." e "Cupom expirado."
está presente na tela, sem exigir que seja o conteúdo exato e isolado de um
elemento, a menos que a execução mostre um elemento dedicado só para essa
mensagem.

## P02 — Comportamento do input de quantidade acima de 5 na interface

CA10 diz que o limite de 5 unidades "vale para a interface e para a API",
mas não descreve o mecanismo. **Confirmado por exploração (2026-10-09):** o
botão "+" do seletor de quantidade no carrinho fica desabilitado
(`aria-label="Aumentar quantidade de <produto>"`) ao atingir 5 unidades, e o
texto "Limite de 5 unidades por produto." aparece junto ao item. CT-014 foi
escrito e automatizado em cima desse mecanismo real. Importante: esse limite
só foi confirmado como aplicado pela interface — a API **não** aplica o
mesmo limite (ver BUG-02 em `docs/03-bugs.md`), então a frase "vale para a
interface e para a API" do CA10 está parcialmente violada.

## P03 — Unicidade do cupom ao trocar sem remover (CA05)

CA05 diz que é preciso remover o cupom atual para trocar, mas não descreve o
que a interface faz se o usuário tentar aplicar um segundo cupom sem
remover o primeiro (bloquear o campo, ignorar a nova tentativa, substituir
automaticamente, ou exibir um erro). Interpretação adotada: CT-006 verifica
apenas que o cupom aplicado continua sendo o primeiro após a tentativa,
sem assumir qual mensagem (se houver) é exibida nesse caso. O comportamento
observado será registrado na execução.

## P04 — Quando o aviso "falta R$X para frete grátis" desaparece

CA07 diz que o carrinho informa quanto falta para o frete grátis quando o
subtotal está abaixo de R$ 200,00. A documentação não diz explicitamente que
esse aviso deve desaparecer quando o subtotal atinge R$ 200,00 ou mais — é
uma inferência razoável a partir da regra de frete grátis, não uma frase
literal da documentação. Tratada como comportamento esperado por decorrência
direta de CA06/CA07, não como um critério de aceite separado.

## P05 — Carrinho vazio e cálculo

A documentação não define o comportamento ao calcular ou confirmar um
pedido com o carrinho vazio pela interface (os critérios de erro da API
cobrem apenas `ITENS_OBRIGATORIOS` para a API). Assumido como fora do
escopo direto do VZS-142 (cupom e frete), mas incluído na sessão exploratória
como charter, não como cenário formal derivado de um CA.

## P06 — Alcance desta entrega (VZS-142)

A documentação completa da loja inclui regras que já existiam antes desta
entrega (nome/sobrenome, formato de e-mail, formato de CEP). Esses pontos
não fazem parte do escopo de "cupom de desconto e frete grátis", mas foram
incluídos em `validacao-cliente.feature` porque bloqueiam a confirmação de
qualquer pedido usado para testar cupom e frete via `/api/pedidos` — são
pré-condição técnica dos cenários de pedido, não o alvo principal do teste.
