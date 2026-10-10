import { test, expect } from '@playwright/test';
import { adicionarAoCarrinho, irParaCarrinho } from './helpers';

test.describe('Checkout', () => {
  // CT-039: confirmar o pedido pela interface exibe o número no formato VZ-000000 e esvazia o carrinho
  test('CT-039 - confirmar pedido exibe número VZ-000000 e esvazia o carrinho', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Camiseta Essencial');
    await irParaCarrinho(page);
    await page.getByRole('link', { name: /finalizar compra/i }).click();

    await page.locator('#campo-nome').fill('Maria Silva');
    await page.locator('#campo-email').fill('maria@exemplo.com');
    await page.locator('#campo-cep').fill('01310-100');
    await page.getByRole('button', { name: /confirmar pedido/i }).click();

    await expect(page.getByText('Pedido confirmado')).toBeVisible();
    await expect(page.getByRole('heading', { name: /^Pedido VZ-\d{6}$/ })).toBeVisible();
    await expect(page.getByRole('link', { name: /^carrinho/i })).toContainText('0');
  });

  // CT-040 / DADOS_INVALIDOS: nome sem sobrenome é bloqueado no checkout com mensagem inline
  test('CT-040 - nome sem sobrenome exibe erro inline e não confirma o pedido', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Camiseta Essencial');
    await irParaCarrinho(page);
    await page.getByRole('link', { name: /finalizar compra/i }).click();

    await page.locator('#campo-nome').fill('Maria');
    await page.locator('#campo-email').fill('maria@exemplo.com');
    await page.locator('#campo-cep').fill('01310-100');
    await page.getByRole('button', { name: /confirmar pedido/i }).click();

    await expect(page.locator('#campo-nome-erro')).toHaveText('Informe nome e sobrenome.');
    await expect(page).toHaveURL(/\/checkout$/);
  });
});
