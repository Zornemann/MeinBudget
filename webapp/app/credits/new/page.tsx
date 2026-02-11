'use client';

import { useState, useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { useBudgetStore } from '@/lib/stores/budget-store';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { calculateCreditDetails, formatCurrency } from '@/lib/utils';

export default function NewCreditPage() {
  const router = useRouter();
  const { addCredit, settings } = useBudgetStore();
  
  const [formData, setFormData] = useState({
    creditor: '',
    debtor: '',
    totalAmount: '',
    termMonths: '',
    effectiveInterestRate: '',
    startDate: new Date().toISOString().split('T')[0],
    description: '',
  });

  const [isSubmitting, setIsSubmitting] = useState(false);

  const calculatedDetails = useMemo(() => {
    if (!formData.totalAmount || !formData.termMonths || !formData.effectiveInterestRate) {
      return null;
    }

    return calculateCreditDetails(
      parseFloat(formData.totalAmount),
      parseInt(formData.termMonths),
      parseFloat(formData.effectiveInterestRate)
    );
  }, [formData.totalAmount, formData.termMonths, formData.effectiveInterestRate]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!calculatedDetails) {
      alert('Bitte füllen Sie alle Pflichtfelder aus.');
      return;
    }

    setIsSubmitting(true);

    try {
      await addCredit({
        creditor: formData.creditor,
        debtor: formData.debtor,
        totalAmount: parseFloat(formData.totalAmount),
        termMonths: parseInt(formData.termMonths),
        monthlyRate: calculatedDetails.monthlyRate,
        effectiveInterestRate: parseFloat(formData.effectiveInterestRate),
        startDate: new Date(formData.startDate),
        description: formData.description || undefined,
      });

      router.push('/credits');
    } catch (error) {
      console.error('Failed to add credit:', error);
      alert('Fehler beim Hinzufügen des Kredits');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <header className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center gap-4">
            <Button variant="ghost" onClick={() => router.push('/credits')}>
              ← Zurück
            </Button>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
              Neuer Kredit
            </h1>
          </div>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <Card>
            <CardHeader>
              <CardTitle>Kreditdetails eingeben</CardTitle>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-4">
                <Input
                  label="Kreditgeber"
                  type="text"
                  value={formData.creditor}
                  onChange={(e) =>
                    setFormData({ ...formData, creditor: e.target.value })
                  }
                  placeholder="z.B. Bank AG"
                  required
                />

                <Input
                  label="Kreditnehmer"
                  type="text"
                  value={formData.debtor}
                  onChange={(e) =>
                    setFormData({ ...formData, debtor: e.target.value })
                  }
                  placeholder="z.B. Max Mustermann"
                  required
                />

                <Input
                  label="Kreditsumme (€)"
                  type="number"
                  step="0.01"
                  min="0"
                  value={formData.totalAmount}
                  onChange={(e) =>
                    setFormData({ ...formData, totalAmount: e.target.value })
                  }
                  placeholder="z.B. 10000"
                  required
                />

                <Input
                  label="Laufzeit (Monate)"
                  type="number"
                  min="1"
                  value={formData.termMonths}
                  onChange={(e) =>
                    setFormData({ ...formData, termMonths: e.target.value })
                  }
                  placeholder="z.B. 60"
                  required
                />

                <Input
                  label="Effektiver Jahreszins (%)"
                  type="number"
                  step="0.01"
                  min="0"
                  max="100"
                  value={formData.effectiveInterestRate}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      effectiveInterestRate: e.target.value,
                    })
                  }
                  placeholder="z.B. 3.5"
                  required
                />

                <Input
                  label="Startdatum"
                  type="date"
                  value={formData.startDate}
                  onChange={(e) =>
                    setFormData({ ...formData, startDate: e.target.value })
                  }
                  required
                />

                <Input
                  label="Beschreibung (optional)"
                  type="text"
                  value={formData.description}
                  onChange={(e) =>
                    setFormData({ ...formData, description: e.target.value })
                  }
                  placeholder="z.B. Autokredit"
                />

                <div className="flex gap-4 pt-4">
                  <Button
                    type="button"
                    variant="secondary"
                    className="flex-1"
                    onClick={() => router.push('/credits')}
                  >
                    Abbrechen
                  </Button>
                  <Button
                    type="submit"
                    variant="primary"
                    className="flex-1"
                    disabled={isSubmitting || !calculatedDetails}
                  >
                    {isSubmitting ? 'Speichern...' : 'Speichern'}
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>

          {calculatedDetails && (
            <Card>
              <CardHeader>
                <CardTitle>Berechnete Kreditdetails</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
                    <div className="text-sm text-gray-600 dark:text-gray-400">
                      Monatliche Rate
                    </div>
                    <div className="text-2xl font-bold text-blue-600 dark:text-blue-400">
                      {formatCurrency(calculatedDetails.monthlyRate, settings.currency)}
                    </div>
                  </div>

                  <div className="space-y-3">
                    <div>
                      <div className="text-sm text-gray-500 dark:text-gray-400">
                        Gesamtzinsen
                      </div>
                      <div className="text-lg font-medium text-red-600 dark:text-red-400">
                        {formatCurrency(calculatedDetails.totalInterest, settings.currency)}
                      </div>
                    </div>

                    <div>
                      <div className="text-sm text-gray-500 dark:text-gray-400">
                        Gesamtbetrag zu zahlen
                      </div>
                      <div className="text-lg font-medium">
                        {formatCurrency(
                          parseFloat(formData.totalAmount) +
                            calculatedDetails.totalInterest,
                          settings.currency
                        )}
                      </div>
                    </div>
                  </div>

                  <div className="pt-4 border-t border-gray-200 dark:border-gray-700">
                    <div className="text-sm text-gray-600 dark:text-gray-400">
                      💡 <strong>Tipp:</strong> Vergleichen Sie verschiedene Angebote,
                      um den besten Zinssatz zu finden!
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}
        </div>
      </main>
    </div>
  );
}
