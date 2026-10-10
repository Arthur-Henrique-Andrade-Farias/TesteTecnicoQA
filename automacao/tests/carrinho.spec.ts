import { test, expect } from '@playwright/test';
import { adicionarAoCarrinho, irParaCarrinho } from './helpers';

test.describe('Estado do carrinho', () => {
  // CT-041: acessar o carrinho sem nenhum item mostra o estado vazio
  test('CT-041 - carrinho vazio mostra "Seu carrinho está vazio"', async ({ page }) => {
    await page.goto('/carrinho');

    await expect(page.getByText('Seu carrinho está vazio')).toBeVisible();
    await expect(page.getByRole('link', { name: /^carrinho/i })).toContainText('0');
  });

  // CT-042: "Esvaziar carrinho" remove todos os itens
  test('CT-042 - esvaziar carrinho remove todos os itens', async ({ page }) => {
    page.on('dialog', (dialog) => dialog.accept());

    await adicionarAoCarrinho(page, 'Camiseta Essencial');
    await irParaCarrinho(page);
    await adicionarAoCarrinho(page, 'Boné Aba Curva');
    await irParaCarrinho(page);

    await page.getByRole('button', { name: /esvaziar carrinho/i }).click();

    await expect(page.getByText('Seu carrinho está vazio')).toBeVisible();
  });

  // CT-043: o carrinho persiste ao recarregar a página na mesma aba
  test('CT-043 - carrinho persiste após recarregar a página na mesma aba', async ({ page }) => {
    await adicionarAoCarrinho(page, 'Mochila Urbana 20L');
    await irParaCarrinho(page);
    await expect(page.locator('[data-valor="subtotal"]')).toHaveText('R$ 100,00');

    await page.reload();

    await expect(page.locator('[data-valor="subtotal"]')).toHaveText('R$ 100,00');
    await expect(page.getByText('Mochila Urbana 20L')).toBeVisible();
  });
});
