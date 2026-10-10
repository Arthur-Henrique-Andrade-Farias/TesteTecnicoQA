import { test, expect } from '@playwright/test';
import { adicionarAoCarrinho, irParaCarrinho, aumentarQuantidade } from './helpers';

test.describe('Cálculo do total (subtotal - desconto + frete)', () => {
  // CT-013 / CA09: o desconto do cupom não incide sobre o valor do frete
  test('CT-013 - desconto do cupom não incide sobre o frete', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Tênis Casual Urbano'); // R$ 189,90
    await irParaCarrinho(page);

    await page.locator('#campo-cupom').fill('BEMVINDO10');
    await page.getByRole('button', { name: /aplicar cupom/i }).click();

    await expect(page.locator('[data-valor="subtotal"]')).toHaveText('R$ 189,90');
    await expect(page.locator('[data-valor="desconto"]')).toContainText('R$ 18,99');
    await expect(page.locator('[data-valor="frete"]')).toHaveText('R$ 19,90');
    await expect(page.locator('[data-valor="total"]')).toHaveText('R$ 190,81');
  });

  // CT-018: total sem cupom segue subtotal - desconto + frete
  test('CT-018 - total sem cupom segue a fórmula subtotal - desconto + frete', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Garrafa Térmica 750ml'); // R$ 50,00
    await irParaCarrinho(page);
    await aumentarQuantidade(page, 'Garrafa Térmica 750ml', 2); // quantidade 3 = R$ 150,00
    await adicionarAoCarrinho(page, 'Boné Aba Curva'); // R$ 49,90
    await irParaCarrinho(page);

    await expect(page.locator('[data-valor="subtotal"]')).toHaveText('R$ 199,90');
    await expect(page.locator('[data-valor="desconto"]')).toHaveText('R$ 0,00');
    await expect(page.locator('[data-valor="frete"]')).toHaveText('R$ 19,90');
    await expect(page.locator('[data-valor="total"]')).toHaveText('R$ 219,80');
  });

  // CT-019: total com cupom e frete pago segue subtotal - desconto + frete
  test('CT-019 - total com cupom e frete pago segue a fórmula subtotal - desconto + frete', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Kit 3 Pares de Meias'); // R$ 29,90
    await irParaCarrinho(page);
    await aumentarQuantidade(page, 'Kit 3 Pares de Meias', 2); // quantidade 3 = R$ 89,70

    await page.locator('#campo-cupom').fill('BEMVINDO10');
    await page.getByRole('button', { name: /aplicar cupom/i }).click();

    await expect(page.locator('[data-valor="subtotal"]')).toHaveText('R$ 89,70');
    await expect(page.locator('[data-valor="desconto"]')).toContainText('R$ 8,97');
    await expect(page.locator('[data-valor="frete"]')).toHaveText('R$ 19,90');
    await expect(page.locator('[data-valor="total"]')).toHaveText('R$ 100,63');
  });
});
