import { test, expect } from '@playwright/test';
import { adicionarAoCarrinho, irParaCarrinho, aumentarQuantidade } from './helpers';

test.describe('Frete grátis a partir de R$ 200,00', () => {
  // CT-010 / CT-011 / CA07: abaixo de R$200 cobra frete fixo e avisa quanto falta
  test('CT-010/CT-011 - subtotal abaixo de R$ 200 cobra frete de R$ 19,90 e avisa quanto falta', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Mochila Urbana 20L'); // R$ 100,00
    await irParaCarrinho(page);

    await expect(page.locator('[data-valor="subtotal"]')).toHaveText('R$ 100,00');
    await expect(page.locator('[data-valor="frete"]')).toHaveText('R$ 19,90');
    await expect(page.locator('[data-valor="total"]')).toHaveText('R$ 119,90');
    await expect(page.getByText('Faltam R$ 100,00 para o frete grátis.')).toBeVisible();
  });

  // CT-009 / CA06: subtotal acima de R$200 tem frete grátis
  test('CT-009 - subtotal acima de R$ 200 tem frete grátis', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Jaqueta Corta-Vento'); // R$ 229,90
    await irParaCarrinho(page);

    await expect(page.locator('[data-valor="subtotal"]')).toHaveText('R$ 229,90');
    await expect(page.locator('[data-valor="frete"]')).toHaveText('Grátis');
    await expect(page.locator('[data-valor="total"]')).toHaveText('R$ 229,90');
  });

  // CT-008 / CA06: subtotal EXATAMENTE R$200 deve ter frete grátis ("a partir de, inclusive").
  // BUG-01 (docs/03-bugs.md): no ambiente real, o frete de R$19,90 é cobrado indevidamente.
  // Este teste segue o critério de aceite documentado e falha até o bug ser corrigido.
  test('CT-008 - subtotal de exatamente R$ 200,00 tem frete grátis (CA06, inclusive)', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Mochila Urbana 20L'); // R$ 100,00
    await irParaCarrinho(page);
    await aumentarQuantidade(page, 'Mochila Urbana 20L', 1); // quantidade 2 = R$ 200,00

    await expect(page.locator('[data-valor="subtotal"]')).toHaveText('R$ 200,00');
    await expect(page.locator('[data-valor="frete"]')).toHaveText('Grátis');
    await expect(page.locator('[data-valor="total"]')).toHaveText('R$ 200,00');
  });

  // CT-012 / CA08: frete grátis considera o subtotal ANTES do desconto do cupom.
  // BUG-01 também afeta este caso: o subtotal pré-desconto já fecha em R$200,00 exatos.
  test('CT-012 - frete grátis considera o subtotal antes do desconto do cupom', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Mochila Urbana 20L');
    await irParaCarrinho(page);
    await aumentarQuantidade(page, 'Mochila Urbana 20L', 1); // quantidade 2 = R$ 200,00 antes do desconto

    await page.locator('#campo-cupom').fill('BEMVINDO10');
    await page.getByRole('button', { name: /aplicar cupom/i }).click();

    await expect(page.locator('[data-valor="subtotal"]')).toHaveText('R$ 200,00');
    await expect(page.locator('[data-valor="frete"]')).toHaveText('Grátis');
    await expect(page.locator('[data-valor="total"]')).toHaveText('R$ 180,00');
  });
});
