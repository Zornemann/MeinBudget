import { openDB, DBSchema, IDBPDatabase } from 'idb';
import { Transaction, Credit, Category, AppSettings } from '@/types';

interface MeinBudgetDB extends DBSchema {
  transactions: {
    key: string;
    value: Transaction;
    indexes: { 'by-date': Date; 'by-category': string };
  };
  credits: {
    key: string;
    value: Credit;
    indexes: { 'by-date': Date };
  };
  categories: {
    key: string;
    value: Category;
  };
  settings: {
    key: string;
    value: AppSettings;
  };
}

const DB_NAME = 'mein-budget-db';
const DB_VERSION = 1;

let dbInstance: IDBPDatabase<MeinBudgetDB> | null = null;

export async function initDB(): Promise<IDBPDatabase<MeinBudgetDB>> {
  if (dbInstance) return dbInstance;

  dbInstance = await openDB<MeinBudgetDB>(DB_NAME, DB_VERSION, {
    upgrade(db) {
      // Transactions store
      if (!db.objectStoreNames.contains('transactions')) {
        const transactionStore = db.createObjectStore('transactions', {
          keyPath: 'id',
        });
        transactionStore.createIndex('by-date', 'date');
        transactionStore.createIndex('by-category', 'categoryId');
      }

      // Credits store
      if (!db.objectStoreNames.contains('credits')) {
        const creditStore = db.createObjectStore('credits', {
          keyPath: 'id',
        });
        creditStore.createIndex('by-date', 'startDate');
      }

      // Categories store
      if (!db.objectStoreNames.contains('categories')) {
        db.createObjectStore('categories', {
          keyPath: 'id',
        });
      }

      // Settings store
      if (!db.objectStoreNames.contains('settings')) {
        db.createObjectStore('settings', {
          keyPath: 'id',
        });
      }
    },
  });

  return dbInstance;
}

export async function getDB(): Promise<IDBPDatabase<MeinBudgetDB>> {
  if (!dbInstance) {
    return await initDB();
  }
  return dbInstance;
}

// Transaction operations
export async function addTransaction(transaction: Transaction): Promise<void> {
  const db = await getDB();
  await db.add('transactions', transaction);
}

export async function getAllTransactions(): Promise<Transaction[]> {
  const db = await getDB();
  return await db.getAll('transactions');
}

export async function getTransactionById(id: string): Promise<Transaction | undefined> {
  const db = await getDB();
  return await db.get('transactions', id);
}

export async function updateTransaction(transaction: Transaction): Promise<void> {
  const db = await getDB();
  await db.put('transactions', transaction);
}

export async function deleteTransaction(id: string): Promise<void> {
  const db = await getDB();
  await db.delete('transactions', id);
}

// Credit operations
export async function addCredit(credit: Credit): Promise<void> {
  const db = await getDB();
  await db.add('credits', credit);
}

export async function getAllCredits(): Promise<Credit[]> {
  const db = await getDB();
  return await db.getAll('credits');
}

export async function getCreditById(id: string): Promise<Credit | undefined> {
  const db = await getDB();
  return await db.get('credits', id);
}

export async function updateCredit(credit: Credit): Promise<void> {
  const db = await getDB();
  await db.put('credits', credit);
}

export async function deleteCredit(id: string): Promise<void> {
  const db = await getDB();
  await db.delete('credits', id);
}

// Category operations
export async function addCategory(category: Category): Promise<void> {
  const db = await getDB();
  await db.add('categories', category);
}

export async function getAllCategories(): Promise<Category[]> {
  const db = await getDB();
  return await db.getAll('categories');
}

export async function getCategoryById(id: string): Promise<Category | undefined> {
  const db = await getDB();
  return await db.get('categories', id);
}

export async function updateCategory(category: Category): Promise<void> {
  const db = await getDB();
  await db.put('categories', category);
}

export async function deleteCategory(id: string): Promise<void> {
  const db = await getDB();
  await db.delete('categories', id);
}

// Settings operations
export async function getSettings(): Promise<AppSettings | undefined> {
  const db = await getDB();
  return await db.get('settings', 'app-settings');
}

interface StoredSettings extends AppSettings {
  id: string;
}

export async function updateSettings(settings: AppSettings): Promise<void> {
  const db = await getDB();
  await db.put('settings', { ...settings, id: 'app-settings' } as StoredSettings);
}
