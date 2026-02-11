'use client';

import { useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { useBudgetStore } from '@/lib/stores/budget-store';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { formatCurrency } from '@/lib/utils';
import { TransactionType } from '@/types';
import {
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';

export default function StatisticsPage() {
  const router = useRouter();
  const { transactions, categories, settings } = useBudgetStore();

  const stats = useMemo(() => {
    // Category breakdown
    const categoryStats = categories.map((category) => {
      const categoryTransactions = transactions.filter(
        (t) => t.categoryId === category.id
      );
      const total = categoryTransactions.reduce((sum, t) => sum + t.amount, 0);

      return {
        name: category.name,
        value: total,
        icon: category.icon,
        color: category.color,
        count: categoryTransactions.length,
      };
    }).filter(stat => stat.value > 0);

    // Monthly trend
    const monthlyData = new Map<string, { income: number; expenses: number }>();
    
    transactions.forEach((transaction) => {
      const date = new Date(transaction.date);
      const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
      
      if (!monthlyData.has(monthKey)) {
        monthlyData.set(monthKey, { income: 0, expenses: 0 });
      }
      
      const data = monthlyData.get(monthKey)!;
      if (transaction.type === TransactionType.INCOME) {
        data.income += transaction.amount;
      } else {
        data.expenses += transaction.amount;
      }
    });

    const monthlyTrend = Array.from(monthlyData.entries())
      .sort((a, b) => a[0].localeCompare(b[0]))
      .slice(-6)
      .map(([month, data]) => ({
        month: new Date(month + '-01').toLocaleDateString('de-DE', {
          month: 'short',
          year: '2-digit',
        }),
        Einnahmen: data.income,
        Ausgaben: data.expenses,
      }));

    // Income vs Expenses
    const totalIncome = transactions
      .filter((t) => t.type === TransactionType.INCOME)
      .reduce((sum, t) => sum + t.amount, 0);

    const totalExpenses = transactions
      .filter((t) => t.type === TransactionType.EXPENSE)
      .reduce((sum, t) => sum + t.amount, 0);

    return {
      categoryStats,
      monthlyTrend,
      totalIncome,
      totalExpenses,
      balance: totalIncome - totalExpenses,
    };
  }, [transactions, categories]);

  const COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#14b8a6'];

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <header className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center gap-4">
            <Button variant="ghost" onClick={() => router.push('/')}>
              ← Zurück
            </Button>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
              📊 Statistiken
            </h1>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {transactions.length === 0 ? (
          <Card>
            <CardContent className="py-16 text-center">
              <div className="text-gray-500 dark:text-gray-400">
                <p className="text-lg">Keine Daten für Statistiken verfügbar</p>
                <p className="text-sm mt-2">
                  Fügen Sie Transaktionen hinzu, um Statistiken zu sehen.
                </p>
              </div>
              <Button
                className="mt-6"
                onClick={() => router.push('/transactions/new')}
              >
                Transaktion hinzufügen
              </Button>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-6">
            {/* Overview Cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <Card>
                <CardContent className="pt-6">
                  <div className="text-sm font-medium text-gray-500 dark:text-gray-400">
                    Gesamteinnahmen
                  </div>
                  <div className="text-2xl font-bold text-green-600 dark:text-green-400 mt-2">
                    {formatCurrency(stats.totalIncome, settings.currency)}
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="pt-6">
                  <div className="text-sm font-medium text-gray-500 dark:text-gray-400">
                    Gesamtausgaben
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

            {/* Monthly Trend */}
            {stats.monthlyTrend.length > 0 && (
              <Card>
                <CardHeader>
                  <CardTitle>Monatlicher Verlauf</CardTitle>
                </CardHeader>
                <CardContent>
                  <ResponsiveContainer width="100%" height={300}>
                    <BarChart data={stats.monthlyTrend}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="month" />
                      <YAxis />
                      <Tooltip
                        formatter={(value) =>
                          formatCurrency(value as number, settings.currency)
                        }
                      />
                      <Legend />
                      <Bar dataKey="Einnahmen" fill="#10b981" />
                      <Bar dataKey="Ausgaben" fill="#ef4444" />
                    </BarChart>
                  </ResponsiveContainer>
                </CardContent>
              </Card>
            )}

            {/* Category Breakdown */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {stats.categoryStats.length > 0 && (
                <Card>
                  <CardHeader>
                    <CardTitle>Ausgaben nach Kategorie</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <ResponsiveContainer width="100%" height={300}>
                      <PieChart>
                        <Pie
                          data={stats.categoryStats}
                          cx="50%"
                          cy="50%"
                          labelLine={false}
                          label={({ name, percent }) =>
                            `${name} ${((percent || 0) * 100).toFixed(0)}%`
                          }
                          outerRadius={80}
                          fill="#8884d8"
                          dataKey="value"
                        >
                          {stats.categoryStats.map((entry, index) => (
                            <Cell
                              key={`cell-${index}`}
                              fill={entry.color || COLORS[index % COLORS.length]}
                            />
                          ))}
                        </Pie>
                        <Tooltip
                          formatter={(value) =>
                            formatCurrency(value as number, settings.currency)
                          }
                        />
                      </PieChart>
                    </ResponsiveContainer>
                  </CardContent>
                </Card>
              )}

              <Card>
                <CardHeader>
                  <CardTitle>Top Kategorien</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3">
                    {stats.categoryStats
                      .sort((a, b) => b.value - a.value)
                      .slice(0, 5)
                      .map((stat) => (
                        <div
                          key={stat.name}
                          className="flex items-center justify-between p-3 rounded-lg bg-gray-50 dark:bg-gray-700"
                        >
                          <div className="flex items-center gap-3">
                            <span className="text-2xl">{stat.icon}</span>
                            <div>
                              <div className="font-medium text-gray-900 dark:text-white">
                                {stat.name}
                              </div>
                              <div className="text-sm text-gray-500 dark:text-gray-400">
                                {stat.count} Transaktionen
                              </div>
                            </div>
                          </div>
                          <div className="font-bold text-gray-900 dark:text-white">
                            {formatCurrency(stat.value, settings.currency)}
                          </div>
                        </div>
                      ))}
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
