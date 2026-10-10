import { test, expect } from '@playwright/test';
import { adicionarAoCarrinho, irParaCarrinho } from './helpers';

test.describe('Limite de 5 unidades por produto', () => {
  // CT-014 / CA10: a interface impede ultrapassar 5 unidades do mesmo produto
  test('CT-014 - botão de aumentar quantidade é desabilitado ao atingir 5 unidades', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Kit 3 Pares de Meias');
    await irParaCarrinho(page);

    const botaoMais = page.getByRole('button', { name: /aumentar quantidade de kit 3 pares de meias/i });
    for (let i = 0; i < 4; i++) {
      await botaoMais.click();
    }

    await expect(page.locator('output')).toHaveText('5');
    await expect(botaoMais).toBeDisabled();
    await expect(page.getByText('Limite de 5 unidades por produto.')).toBeVisible();
  });
});
