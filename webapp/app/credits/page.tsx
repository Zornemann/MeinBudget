'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useBudgetStore } from '@/lib/stores/budget-store';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { formatCurrency, calculateCreditDetails } from '@/lib/utils';

export default function CreditsPage() {
  const router = useRouter();
  const { credits, settings, deleteCredit } = useBudgetStore();
  const [showAddForm, setShowAddForm] = useState(false);

  const handleDelete = async (id: string) => {
    if (confirm('Möchten Sie diesen Kredit wirklich löschen?')) {
      await deleteCredit(id);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <header className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <Button variant="ghost" onClick={() => router.push('/')}>
                ← Zurück
              </Button>
              <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
                🏦 Kredite verwalten
              </h1>
            </div>
            <Button onClick={() => router.push('/credits/new')}>
              ➕ Kredit hinzufügen
            </Button>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {credits.length === 0 ? (
          <Card>
            <CardContent className="py-16 text-center">
              <div className="text-gray-500 dark:text-gray-400">
                <p className="text-lg">Keine Kredite vorhanden</p>
                <p className="text-sm mt-2">
                  Fügen Sie Ihren ersten Kredit hinzu, um ihn zu verwalten.
                </p>
              </div>
              <Button
                className="mt-6"
                onClick={() => router.push('/credits/new')}
              >
                Kredit hinzufügen
              </Button>
            </CardContent>
          </Card>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {credits.map((credit) => {
              const totalInterest =
                credit.monthlyRate * credit.termMonths - credit.totalAmount;
              const totalPayment = credit.monthlyRate * credit.termMonths;

              return (
                <Card key={credit.id}>
                  <CardHeader>
                    <div className="flex items-start justify-between">
                      <div>
                        <CardTitle>
                          {credit.creditor} → {credit.debtor}
                        </CardTitle>
                        {credit.description && (
                          <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
                            {credit.description}
                          </p>
                        )}
                      </div>
                      <Button
                        variant="danger"
                        size="sm"
                        onClick={() => handleDelete(credit.id)}
                      >
                        🗑️
                      </Button>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <div className="text-sm text-gray-500 dark:text-gray-400">
                            Kreditsumme
                          </div>
                          <div className="font-bold text-lg">
                            {formatCurrency(credit.totalAmount, settings.currency)}
                          </div>
                        </div>
                        <div>
                          <div className="text-sm text-gray-500 dark:text-gray-400">
                            Zinssatz
                          </div>
                          <div className="font-bold text-lg">
                            {credit.effectiveInterestRate.toFixed(2)}%
                          </div>
                        </div>
                      </div>

                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <div className="text-sm text-gray-500 dark:text-gray-400">
                            Laufzeit
                          </div>
                          <div className="font-medium">
                            {credit.termMonths} Monate
                          </div>
                        </div>
                        <div>
                          <div className="text-sm text-gray-500 dark:text-gray-400">
                            Monatliche Rate
                          </div>
                          <div className="font-medium">
                            {formatCurrency(credit.monthlyRate, settings.currency)}
                          </div>
                        </div>
                      </div>

                      <div className="pt-3 border-t border-gray-200 dark:border-gray-700">
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <div className="text-sm text-gray-500 dark:text-gray-400">
                              Gesamtzinsen
                            </div>
                            <div className="font-medium text-red-600 dark:text-red-400">
                              {formatCurrency(totalInterest, settings.currency)}
                            </div>
                          </div>
                          <div>
                            <div className="text-sm text-gray-500 dark:text-gray-400">
                              Gesamtbetrag
                            </div>
                            <div className="font-medium">
                              {formatCurrency(totalPayment, settings.currency)}
                            </div>
                          </div>
                        </div>
                      </div>

                      <div className="pt-3">
                        <div className="text-sm text-gray-500 dark:text-gray-400">
                          Startdatum
                        </div>
                        <div className="font-medium">
                          {new Date(credit.startDate).toLocaleDateString('de-DE')}
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              );
            })}
          </div>
        )}
      </main>
    </div>
  );
}
