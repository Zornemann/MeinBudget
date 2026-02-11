// Core data types for MeinBudget application

export enum TransactionType {
  INCOME = 'INCOME',
  EXPENSE = 'EXPENSE',
}

export enum CategoryType {
  // Predefined categories
  GEHALT = 'GEHALT', // Salary
  KINDERGELD = 'KINDERGELD', // Child benefit
  KREDIT = 'KREDIT', // Credit
  VERSICHERUNG = 'VERSICHERUNG', // Insurance
  TANKEN = 'TANKEN', // Fuel
  EINKAUF = 'EINKAUF', // Shopping
  UNTERHALTUNG = 'UNTERHALTUNG', // Entertainment
  CUSTOM = 'CUSTOM', // Custom category
}

export interface Category {
  id: string;
  name: string;
  type: CategoryType;
  transactionType: TransactionType;
  icon?: string;
  color?: string;
  isCustom: boolean;
  createdAt: Date;
}

export interface Transaction {
  id: string;
  amount: number;
  type: TransactionType;
  categoryId: string;
  description: string;
  date: Date;
  createdAt: Date;
  updatedAt: Date;
  synced?: boolean;
}

export interface Credit {
  id: string;
  creditor: string; // Kreditgeber
  debtor: string; // Kreditnehmer
  totalAmount: number; // Gesamtsumme
  termMonths: number; // Laufzeit in Monaten
  monthlyRate: number; // Monatliche Rate
  effectiveInterestRate: number; // Effektiver Jahreszins
  startDate: Date;
  description?: string;
  createdAt: Date;
  updatedAt: Date;
  synced?: boolean;
}

export interface InterestRateComparison {
  provider: string;
  rate: number;
  savings?: number;
  url?: string;
}

export interface Statistics {
  totalIncome: number;
  totalExpenses: number;
  balance: number;
  topCategories: {
    categoryId: string;
    amount: number;
  }[];
  monthlyTrend: {
    month: string;
    income: number;
    expenses: number;
  }[];
}

export interface AppSettings {
  darkMode: boolean;
  currency: string;
  pinEnabled: boolean;
  biometricEnabled: boolean;
  syncEnabled: boolean;
  lastSync?: Date;
}
