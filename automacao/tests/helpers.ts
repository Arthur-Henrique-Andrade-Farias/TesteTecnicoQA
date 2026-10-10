import { Page } from '@playwright/test';

export async function adicionarAoCarrinho(page: Page, nomeProduto: string) {
  await page.goto('/');
  const card = page.locator('article', { hasText: nomeProduto }).first();
  await card.getByRole('button', { name: /adicionar ao carrinho/i }).click();
}

export async function irParaCarrinho(page: Page) {
  await page.getByRole('link', { name: /^carrinho/i }).click();
  await page.waitForLoadState('networkidle');
}

export async function aumentarQuantidade(page: Page, nomeProduto: string, vezes: number) {
  const botaoMais = page.getByRole('button', { name: new RegExp(`aumentar quantidade de ${nomeProduto}`, 'i') });
  for (let i = 0; i < vezes; i++) {
    await botaoMais.click();
  }
}
