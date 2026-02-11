'use client';

import { useState, useMemo } from 'react';
import { useBudgetStore } from '@/lib/stores/budget-store';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { formatCurrency } from '@/lib/utils';
import { TransactionType } from '@/types';
import Link from 'next/link';

export default function HomePage() {
  const { transactions, credits, categories, settings, toggleDarkMode } = useBudgetStore();

  const stats = useMemo(() => {
    const totalIncome = transactions
      .filter((t) => t.type === TransactionType.INCOME)
      .reduce((sum, t) => sum + t.amount, 0);

    const totalExpenses = transactions
      .filter((t) => t.type === TransactionType.EXPENSE)
      .reduce((sum, t) => sum + t.amount, 0);

    const balance = totalIncome - totalExpenses;

    const totalCreditAmount = credits.reduce((sum, c) => sum + c.totalAmount, 0);
    const totalMonthlyPayments = credits.reduce((sum, c) => sum + c.monthlyRate, 0);

    return {
      totalIncome,
      totalExpenses,
      balance,
      totalCreditAmount,
      totalMonthlyPayments,
    };
  }, [transactions, credits]);

  return (
    <div className="min-h-screen">
      {/* Header */}
      <header className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
              💰 MeinBudget
            </h1>
            <Button variant="ghost" size="sm" onClick={toggleDarkMode}>
              {settings.darkMode ? '☀️' : '🌙'}
            </Button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Overview */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <Card>
            <CardContent className="pt-6">
              <div className="text-sm font-medium text-gray-500 dark:text-gray-400">
                Einnahmen
              </div>
              <div className="text-2xl font-bold text-green-600 dark:text-green-400 mt-2">
                {formatCurrency(stats.totalIncome, settings.currency)}
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="pt-6">
              <div className="text-sm font-medium text-gray-500 dark:text-gray-400">
                Ausgaben
              </div>
              <div className="text-2xl font-bold text-red-600 dark:text-red-400 mt-2">
                {formatCurrency(stats.totalExpenses, settings.currency)}
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="pt-6">
              <div className="text-sm font-medium text-gray-500 dark:text-gray-400">
                Bilanz
              </div>
              <div
                className={`text-2xl font-bold mt-2 ${
                  stats.balance >= 0
                    ? 'text-green-600 dark:text-green-400'
                    : 'text-red-600 dark:text-red-400'
                }`}
              >
                {formatCurrency(stats.balance, settings.currency)}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Credits Summary */}
        {credits.length > 0 && (
          <div className="mb-8">
            <Card>
              <CardHeader>
                <CardTitle>Kredite Übersicht</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <div className="text-sm font-medium text-gray-500 dark:text-gray-400">
                      Gesamtkreditsumme
                    </div>
                    <div className="text-xl font-bold text-gray-900 dark:text-white mt-1">
                      {formatCurrency(stats.totalCreditAmount, settings.currency)}
                    </div>
                  </div>
                  <div>
                    <div className="text-sm font-medium text-gray-500 dark:text-gray-400">
                      Monatliche Belastung
                    </div>
                    <div className="text-xl font-bold text-gray-900 dark:text-white mt-1">
                      {formatCurrency(stats.totalMonthlyPayments, settings.currency)}
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Quick Actions */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <Link href="/transactions/new">
            <Button className="w-full" variant="primary">
              ➕ Transaktion hinzufügen
            </Button>
          </Link>
          <Link href="/credits">
            <Button className="w-full" variant="secondary">
              🏦 Kredite verwalten
            </Button>
          </Link>
          <Link href="/statistics">
            <Button className="w-full" variant="secondary">
              📊 Statistiken
            </Button>
          </Link>
          <Link href="/settings">
            <Button className="w-full" variant="secondary">
              ⚙️ Einstellungen
            </Button>
          </Link>
        </div>

        {/* Recent Transactions */}
        <Card>
          <CardHeader>
            <CardTitle>Letzte Transaktionen</CardTitle>
          </CardHeader>
          <CardContent>
            {transactions.length === 0 ? (
              <div className="text-center py-8 text-gray-500 dark:text-gray-400">
                <p>Noch keine Transaktionen vorhanden.</p>
                <p className="text-sm mt-2">
                  Fügen Sie Ihre erste Transaktion hinzu, um loszulegen!
                </p>
              </div>
            ) : (
              <div className="space-y-3">
                {transactions
                  .sort((a, b) => b.date.getTime() - a.date.getTime())
                  .slice(0, 5)
                  .map((transaction) => {
                    const category = categories.find((c) => c.id === transaction.categoryId);
                    return (
                      <div
                        key={transaction.id}
                        className="flex items-center justify-between p-3 rounded-lg bg-gray-50 dark:bg-gray-700"
                      >
                        <div className="flex items-center gap-3">
                          <div className="text-2xl">{category?.icon || '💰'}</div>
                          <div>
                            <div className="font-medium text-gray-900 dark:text-white">
                              {transaction.description}
                            </div>
                            <div className="text-sm text-gray-500 dark:text-gray-400">
                              {category?.name || 'Unbekannt'} •{' '}
                              {new Date(transaction.date).toLocaleDateString('de-DE')}
                            </div>
                          </div>
                        </div>
                        <div
                          className={`font-bold ${
                            transaction.type === TransactionType.INCOME
                              ? 'text-green-600 dark:text-green-400'
                              : 'text-red-600 dark:text-red-400'
                          }`}
                        >
                          {transaction.type === TransactionType.INCOME ? '+' : '-'}
                          {formatCurrency(transaction.amount, settings.currency)}
                        </div>
                      </div>
                    );
                  })}
              </div>
            )}
          </CardContent>
        </Card>
      </main>
    </div>
  );
}
