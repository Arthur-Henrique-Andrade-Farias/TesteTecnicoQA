import { test, expect } from '@playwright/test';
import { adicionarAoCarrinho, irParaCarrinho } from './helpers';

test.describe('Cupom de desconto', () => {
  // CT-001 / CA01: cupom válido aplica 10% de desconto sobre o subtotal
  test('CT-001 - cupom BEMVINDO10 aplica 10% de desconto e calcula o total correto', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Calça Jeans Slim');
    await irParaCarrinho(page);
    await adicionarAoCarrinho(page, 'Boné Aba Curva');
    await irParaCarrinho(page);
    await page.getByRole('button', { name: /aumentar quantidade de boné aba curva/i }).click();

    await page.locator('#campo-cupom').fill('BEMVINDO10');
    await page.getByRole('button', { name: /aplicar cupom/i }).click();

    await expect(page.locator('[data-valor="subtotal"]')).toHaveText('R$ 239,70');
    await expect(page.locator('[data-valor="desconto"]')).toContainText('R$ 23,97');
    await expect(page.locator('[data-valor="frete"]')).toHaveText('Grátis');
    await expect(page.locator('[data-valor="total"]')).toHaveText('R$ 215,73');
    await expect(page.getByText('Cupom BEMVINDO10 aplicado.')).toBeVisible();
  });

  // CT-004 / CA03: cupom inexistente exibe mensagem exata e não aplica desconto
  test('CT-004 - cupom inexistente exibe "Cupom inválido." e não aplica desconto', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Camiseta Essencial');
    await irParaCarrinho(page);

    await page.locator('#campo-cupom').fill('NAOEXISTE');
    await page.getByRole('button', { name: /aplicar cupom/i }).click();

    await expect(page.getByRole('alert')).toHaveText('Cupom inválido.');
    await expect(page.locator('[data-valor="desconto"]')).toHaveText('R$ 0,00');
  });
});
