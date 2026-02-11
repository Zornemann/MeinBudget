import { create } from 'zustand';
import { Transaction, Credit, Category, AppSettings, TransactionType } from '@/types';
import * as db from '@/lib/db';

interface BudgetState {
  transactions: Transaction[];
  credits: Credit[];
  categories: Category[];
  settings: AppSettings;
  initialized: boolean;

  // Actions
  initialize: () => Promise<void>;
  
  // Transaction actions
  addTransaction: (transaction: Omit<Transaction, 'id' | 'createdAt' | 'updatedAt'>) => Promise<void>;
  updateTransaction: (transaction: Transaction) => Promise<void>;
  deleteTransaction: (id: string) => Promise<void>;
  
  // Credit actions
  addCredit: (credit: Omit<Credit, 'id' | 'createdAt' | 'updatedAt'>) => Promise<void>;
  updateCredit: (credit: Credit) => Promise<void>;
  deleteCredit: (id: string) => Promise<void>;
  
  // Category actions
  addCategory: (category: Omit<Category, 'id' | 'createdAt'>) => Promise<void>;
  updateCategory: (category: Category) => Promise<void>;
  deleteCategory: (id: string) => Promise<void>;
  
  // Settings actions
  updateSettings: (settings: Partial<AppSettings>) => Promise<void>;
  toggleDarkMode: () => Promise<void>;
}

export const useBudgetStore = create<BudgetState>((set, get) => ({
  transactions: [],
  credits: [],
  categories: [],
  settings: {
    darkMode: false,
    currency: '€',
    pinEnabled: false,
    biometricEnabled: false,
    syncEnabled: false,
  },
  initialized: false,

  initialize: async () => {
    try {
      await db.initDB();
      
      const [transactions, credits, categories, settings] = await Promise.all([
        db.getAllTransactions(),
        db.getAllCredits(),
        db.getAllCategories(),
        db.getSettings(),
      ]);

      set({
        transactions,
        credits,
        categories,
        settings: settings || {
          darkMode: false,
          currency: '€',
          pinEnabled: false,
          biometricEnabled: false,
          syncEnabled: false,
        },
        initialized: true,
      });
    } catch (error) {
      console.error('Failed to initialize store:', error);
    }
  },

  addTransaction: async (transaction) => {
    const newTransaction: Transaction = {
      ...transaction,
      id: crypto.randomUUID(),
      createdAt: new Date(),
      updatedAt: new Date(),
      synced: false,
    };

    await db.addTransaction(newTransaction);
    set((state) => ({
      transactions: [...state.transactions, newTransaction],
    }));
  },

  updateTransaction: async (transaction) => {
    const updatedTransaction = {
      ...transaction,
      updatedAt: new Date(),
    };

    await db.updateTransaction(updatedTransaction);
    set((state) => ({
      transactions: state.transactions.map((t) =>
        t.id === transaction.id ? updatedTransaction : t
      ),
    }));
  },

  deleteTransaction: async (id) => {
    await db.deleteTransaction(id);
    set((state) => ({
      transactions: state.transactions.filter((t) => t.id !== id),
    }));
  },

  addCredit: async (credit) => {
    const newCredit: Credit = {
      ...credit,
      id: crypto.randomUUID(),
      createdAt: new Date(),
      updatedAt: new Date(),
      synced: false,
    };

    await db.addCredit(newCredit);
    set((state) => ({
      credits: [...state.credits, newCredit],
    }));
  },

  updateCredit: async (credit) => {
    const updatedCredit = {
      ...credit,
      updatedAt: new Date(),
    };

    await db.updateCredit(updatedCredit);
    set((state) => ({
      credits: state.credits.map((c) => (c.id === credit.id ? updatedCredit : c)),
    }));
  },

  deleteCredit: async (id) => {
    await db.deleteCredit(id);
    set((state) => ({
      credits: state.credits.filter((c) => c.id !== id),
    }));
  },

  addCategory: async (category) => {
    const newCategory: Category = {
      ...category,
      id: crypto.randomUUID(),
      createdAt: new Date(),
    };

    await db.addCategory(newCategory);
    set((state) => ({
      categories: [...state.categories, newCategory],
    }));
  },

  updateCategory: async (category) => {
    await db.updateCategory(category);
    set((state) => ({
      categories: state.categories.map((c) =>
        c.id === category.id ? category : c
      ),
    }));
  },

  deleteCategory: async (id) => {
    await db.deleteCategory(id);
    set((state) => ({
      categories: state.categories.filter((c) => c.id !== id),
    }));
  },

  updateSettings: async (newSettings) => {
    const updatedSettings = {
      ...get().settings,
      ...newSettings,
    };

    await db.updateSettings(updatedSettings);
    set({ settings: updatedSettings });
  },

  toggleDarkMode: async () => {
    const { settings } = get();
    const updatedSettings = {
      ...settings,
      darkMode: !settings.darkMode,
    };

    await db.updateSettings(updatedSettings);
    set({ settings: updatedSettings });
  },
}));
