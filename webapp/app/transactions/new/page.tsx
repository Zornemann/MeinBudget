'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useBudgetStore } from '@/lib/stores/budget-store';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Select } from '@/components/ui/select';
import { TransactionType } from '@/types';

export default function NewTransactionPage() {
  const router = useRouter();
  const { addTransaction, categories } = useBudgetStore();
  
  const [formData, setFormData] = useState({
    amount: '',
    type: TransactionType.EXPENSE,
    categoryId: '',
    description: '',
    date: new Date().toISOString().split('T')[0],
  });

  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);

    try {
      await addTransaction({
        amount: parseFloat(formData.amount),
        type: formData.type,
        categoryId: formData.categoryId,
        description: formData.description,
        date: new Date(formData.date),
      });

      router.push('/');
    } catch (error) {
      console.error('Failed to add transaction:', error);
      alert('Fehler beim Hinzufügen der Transaktion');
    } finally {
      setIsSubmitting(false);
    }
  };

  const filteredCategories = categories.filter(
    (cat) => cat.transactionType === formData.type
  );

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <header className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center gap-4">
            <Button variant="ghost" onClick={() => router.push('/')}>
              ← Zurück
            </Button>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
              Neue Transaktion
            </h1>
          </div>
        </div>
      </header>

      <main className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <Card>
          <CardHeader>
            <CardTitle>Transaktion hinzufügen</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <Select
                label="Typ"
                value={formData.type}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    type: e.target.value as TransactionType,
                    categoryId: '',
                  })
                }
                required
              >
                <option value={TransactionType.EXPENSE}>Ausgabe</option>
                <option value={TransactionType.INCOME}>Einnahme</option>
              </Select>

              <Select
                label="Kategorie"
                value={formData.categoryId}
                onChange={(e) =>
                  setFormData({ ...formData, categoryId: e.target.value })
                }
                required
              >
                <option value="">Kategorie auswählen...</option>
                {filteredCategories.map((category) => (
                  <option key={category.id} value={category.id}>
                    {category.icon} {category.name}
                  </option>
                ))}
              </Select>

              <Input
                label="Betrag (€)"
                type="number"
                step="0.01"
                min="0"
                value={formData.amount}
                onChange={(e) =>
                  setFormData({ ...formData, amount: e.target.value })
                }
                required
              />

              <Input
                label="Beschreibung"
                type="text"
                value={formData.description}
                onChange={(e) =>
                  setFormData({ ...formData, description: e.target.value })
                }
                required
              />

              <Input
                label="Datum"
                type="date"
                value={formData.date}
                onChange={(e) =>
                  setFormData({ ...formData, date: e.target.value })
                }
                required
              />

              <div className="flex gap-4 pt-4">
                <Button
                  type="button"
                  variant="secondary"
                  className="flex-1"
                  onClick={() => router.push('/')}
                >
                  Abbrechen
                </Button>
                <Button
                  type="submit"
                  variant="primary"
                  className="flex-1"
                  disabled={isSubmitting}
                >
                  {isSubmitting ? 'Speichern...' : 'Speichern'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </main>
    </div>
  );
}
