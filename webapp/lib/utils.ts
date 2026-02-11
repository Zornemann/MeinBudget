import { Category, CategoryType, TransactionType } from '@/types';

export const PREDEFINED_CATEGORIES: Omit<Category, 'id' | 'createdAt'>[] = [
  {
    name: 'Gehalt',
    type: CategoryType.GEHALT,
    transactionType: TransactionType.INCOME,
    icon: '💰',
    color: '#10b981',
    isCustom: false,
  },
  {
    name: 'Kindergeld',
    type: CategoryType.KINDERGELD,
    transactionType: TransactionType.INCOME,
    icon: '👶',
    color: '#3b82f6',
    isCustom: false,
  },
  {
    name: 'Kredit',
    type: CategoryType.KREDIT,
    transactionType: TransactionType.EXPENSE,
    icon: '🏦',
    color: '#ef4444',
    isCustom: false,
  },
  {
    name: 'Versicherung',
    type: CategoryType.VERSICHERUNG,
    transactionType: TransactionType.EXPENSE,
    icon: '🛡️',
    color: '#f59e0b',
    isCustom: false,
  },
  {
    name: 'Tanken',
    type: CategoryType.TANKEN,
    transactionType: TransactionType.EXPENSE,
    icon: '⛽',
    color: '#8b5cf6',
    isCustom: false,
  },
  {
    name: 'Einkauf',
    type: CategoryType.EINKAUF,
    transactionType: TransactionType.EXPENSE,
    icon: '🛒',
    color: '#ec4899',
    isCustom: false,
  },
  {
    name: 'Unterhaltung',
    type: CategoryType.UNTERHALTUNG,
    transactionType: TransactionType.EXPENSE,
    icon: '🎬',
    color: '#14b8a6',
    isCustom: false,
  },
];

export async function initializePredefinedCategories(): Promise<void> {
  const { addCategory, getAllCategories } = await import('@/lib/db');
  const existingCategories = await getAllCategories();

  if (existingCategories.length === 0) {
    for (const category of PREDEFINED_CATEGORIES) {
      await addCategory({
        ...category,
        id: crypto.randomUUID(),
        createdAt: new Date(),
      });
    }
  }
}

export function generateId(): string {
  return crypto.randomUUID();
}

export function formatCurrency(amount: number, currency: string = '€'): string {
  return new Intl.NumberFormat('de-DE', {
    style: 'currency',
    currency: currency === '€' ? 'EUR' : currency,
  }).format(amount);
}

export function calculateCreditDetails(
  totalAmount: number,
  termMonths: number,
  effectiveInterestRate: number
): { monthlyRate: number; totalInterest: number } {
  const monthlyRate =
    (totalAmount * (effectiveInterestRate / 100 / 12)) /
    (1 - Math.pow(1 + effectiveInterestRate / 100 / 12, -termMonths));

  const totalInterest = monthlyRate * termMonths - totalAmount;

  return {
    monthlyRate: Math.round(monthlyRate * 100) / 100,
    totalInterest: Math.round(totalInterest * 100) / 100,
  };
}
