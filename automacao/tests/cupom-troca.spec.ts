import { test, expect } from '@playwright/test';
import { adicionarAoCarrinho, irParaCarrinho } from './helpers';

test.describe('Expiração e troca de cupom', () => {
  // CT-005 / CA04: cupom expirado exibe mensagem exata na interface
  test('CT-005 - cupom expirado exibe "Cupom expirado." e não aplica desconto', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Camiseta Essencial');
    await irParaCarrinho(page);

    await page.locator('#campo-cupom').fill('VERAO2026');
    await page.getByRole('button', { name: /aplicar cupom/i }).click();

    await expect(page.getByRole('alert')).toHaveText('Cupom expirado.');
    await expect(page.locator('[data-valor="desconto"]')).toHaveText('R$ 0,00');
  });

  // CT-006 / CA05: com um cupom aplicado, não há como aplicar um segundo sem remover o atual primeiro
  test('CT-006 - com um cupom aplicado, o campo para aplicar outro cupom não fica disponível', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Camiseta Essencial');
    await irParaCarrinho(page);

    await page.locator('#campo-cupom').fill('BEMVINDO10');
    await page.getByRole('button', { name: /aplicar cupom/i }).click();

    await expect(page.getByText('Cupom BEMVINDO10 aplicado.')).toBeVisible();
    // o campo de texto do cupom some de tela assim que um cupom é aplicado:
    // a única forma de trocar é pelo link "Remover cupom", confirmando a CA05.
    await expect(page.locator('#campo-cupom')).toHaveCount(0);
    await expect(page.getByRole('button', { name: /remover cupom/i })).toBeVisible();
  });

  // CT-007 / CA05: remover o cupom atual libera o campo para aplicar outro cupom
  test('CT-007 - remover o cupom atual permite aplicar um cupom diferente', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Camiseta Essencial');
    await irParaCarrinho(page);

    await page.locator('#campo-cupom').fill('BEMVINDO10');
    await page.getByRole('button', { name: /aplicar cupom/i }).click();
    await expect(page.getByText('Cupom BEMVINDO10 aplicado.')).toBeVisible();

    await page.getByRole('button', { name: /remover cupom/i }).click();
    await expect(page.locator('#campo-cupom')).toBeVisible();
    await expect(page.locator('[data-valor="desconto"]')).toHaveText('R$ 0,00');

    await page.locator('#campo-cupom').fill('VERAO2026');
    await page.getByRole('button', { name: /aplicar cupom/i }).click();
    await expect(page.getByRole('alert')).toHaveText('Cupom expirado.');
  });
});
