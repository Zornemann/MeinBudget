'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useBudgetStore } from '@/lib/stores/budget-store';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { TransactionType, CategoryType } from '@/types';

export default function SettingsPage() {
  const router = useRouter();
  const { settings, updateSettings, toggleDarkMode, categories, addCategory } = useBudgetStore();
  const [showAddCategory, setShowAddCategory] = useState(false);
  const [newCategory, setNewCategory] = useState({
    name: '',
    icon: '📌',
    color: '#3b82f6',
    transactionType: TransactionType.EXPENSE,
  });

  const handleAddCategory = async () => {
    if (!newCategory.name.trim()) {
      alert('Bitte geben Sie einen Kategorienamen ein.');
      return;
    }

    await addCategory({
      name: newCategory.name,
      type: CategoryType.CUSTOM,
      transactionType: newCategory.transactionType,
      icon: newCategory.icon,
      color: newCategory.color,
      isCustom: true,
    });

    setNewCategory({
      name: '',
      icon: '📌',
      color: '#3b82f6',
      transactionType: TransactionType.EXPENSE,
    });
    setShowAddCategory(false);
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <header className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center gap-4">
            <Button variant="ghost" onClick={() => router.push('/')}>
              ← Zurück
            </Button>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
              ⚙️ Einstellungen
            </h1>
          </div>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="space-y-6">
          {/* Appearance Settings */}
          <Card>
            <CardHeader>
              <CardTitle>Erscheinungsbild</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center justify-between">
                <div>
                  <div className="font-medium text-gray-900 dark:text-white">
                    Dark Mode
                  </div>
                  <div className="text-sm text-gray-500 dark:text-gray-400">
                    Dunkles Design für die App aktivieren
                  </div>
                </div>
                <Button onClick={toggleDarkMode}>
                  {settings.darkMode ? '🌙 An' : '☀️ Aus'}
                </Button>
              </div>
            </CardContent>
          </Card>

          {/* Categories Management */}
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>Kategorien verwalten</CardTitle>
                <Button size="sm" onClick={() => setShowAddCategory(!showAddCategory)}>
                  {showAddCategory ? 'Abbrechen' : '➕ Kategorie hinzufügen'}
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              {showAddCategory && (
                <div className="mb-6 p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg space-y-3">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                      Kategorienamen
                    </label>
                    <input
                      type="text"
                      value={newCategory.name}
                      onChange={(e) =>
                        setNewCategory({ ...newCategory, name: e.target.value })
                      }
                      className="w-full px-3 py-2 border rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 border-gray-300 dark:border-gray-600"
                      placeholder="z.B. Restaurant"
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                        Icon (Emoji)
                      </label>
                      <input
                        type="text"
                        value={newCategory.icon}
                        onChange={(e) =>
                          setNewCategory({ ...newCategory, icon: e.target.value })
                        }
                        className="w-full px-3 py-2 border rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 border-gray-300 dark:border-gray-600"
                        placeholder="🍽️"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                        Farbe
                      </label>
                      <input
                        type="color"
                        value={newCategory.color}
                        onChange={(e) =>
                          setNewCategory({ ...newCategory, color: e.target.value })
                        }
                        className="w-full h-10 rounded-lg cursor-pointer"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                      Typ
                    </label>
                    <select
                      value={newCategory.transactionType}
                      onChange={(e) =>
                        setNewCategory({
                          ...newCategory,
                          transactionType: e.target.value as TransactionType,
                        })
                      }
                      className="w-full px-3 py-2 border rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 border-gray-300 dark:border-gray-600"
                    >
                      <option value={TransactionType.EXPENSE}>Ausgabe</option>
                      <option value={TransactionType.INCOME}>Einnahme</option>
                    </select>
                  </div>

                  <Button onClick={handleAddCategory} className="w-full">
                    Kategorie hinzufügen
                  </Button>
                </div>
              )}

              <div className="space-y-3">
                {categories.map((category) => (
                  <div
                    key={category.id}
                    className="flex items-center justify-between p-3 rounded-lg bg-gray-50 dark:bg-gray-700"
                  >
                    <div className="flex items-center gap-3">
                      <span
                        className="text-2xl w-10 h-10 flex items-center justify-center rounded-lg"
                        style={{ backgroundColor: category.color + '20' }}
                      >
                        {category.icon}
                      </span>
                      <div>
                        <div className="font-medium text-gray-900 dark:text-white">
                          {category.name}
                          {category.isCustom && (
                            <span className="ml-2 text-xs px-2 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 rounded">
                              Benutzerdefiniert
                            </span>
                          )}
                        </div>
                        <div className="text-sm text-gray-500 dark:text-gray-400">
                          {category.transactionType === TransactionType.INCOME
                            ? 'Einnahme'
                            : 'Ausgabe'}
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Security Settings */}
          <Card>
            <CardHeader>
              <CardTitle>Sicherheit</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <div className="font-medium text-gray-900 dark:text-white">
                      PIN-Sperre
                    </div>
                    <div className="text-sm text-gray-500 dark:text-gray-400">
                      App mit PIN schützen
                    </div>
                  </div>
                  <Button
                    variant={settings.pinEnabled ? 'primary' : 'secondary'}
                    onClick={() =>
                      updateSettings({ pinEnabled: !settings.pinEnabled })
                    }
                  >
                    {settings.pinEnabled ? 'Aktiviert' : 'Deaktiviert'}
                  </Button>
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <div className="font-medium text-gray-900 dark:text-white">
                      Fingerabdruck/Face ID
                    </div>
                    <div className="text-sm text-gray-500 dark:text-gray-400">
                      Biometrische Authentifizierung verwenden
                    </div>
                  </div>
                  <Button
                    variant={settings.biometricEnabled ? 'primary' : 'secondary'}
                    onClick={() =>
                      updateSettings({
                        biometricEnabled: !settings.biometricEnabled,
                      })
                    }
                  >
                    {settings.biometricEnabled ? 'Aktiviert' : 'Deaktiviert'}
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Sync Settings */}
          <Card>
            <CardHeader>
              <CardTitle>Synchronisierung</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center justify-between">
                <div>
                  <div className="font-medium text-gray-900 dark:text-white">
                    Cloud-Synchronisierung
                  </div>
                  <div className="text-sm text-gray-500 dark:text-gray-400">
                    Daten über MongoDB synchronisieren
                  </div>
                  {settings.lastSync && (
                    <div className="text-xs text-gray-400 dark:text-gray-500 mt-1">
                      Letzte Sync: {new Date(settings.lastSync).toLocaleString('de-DE')}
                    </div>
                  )}
                </div>
                <Button
                  variant={settings.syncEnabled ? 'primary' : 'secondary'}
                  onClick={() =>
                    updateSettings({ syncEnabled: !settings.syncEnabled })
                  }
                >
                  {settings.syncEnabled ? 'Aktiviert' : 'Deaktiviert'}
                </Button>
              </div>
            </CardContent>
          </Card>

          {/* App Info */}
          <Card>
            <CardHeader>
              <CardTitle>App-Informationen</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2 text-sm text-gray-600 dark:text-gray-400">
                <div>
                  <strong>Version:</strong> 1.0.0
                </div>
                <div>
                  <strong>Beschreibung:</strong> MeinBudget hilft Ihnen, Ihre Finanzen
                  im Griff zu behalten – Einnahmen, Ausgaben & Kredite einfach managen.
                </div>
                <div className="pt-4">
                  <p className="text-xs">
                    Offline-fähig • Dark Mode • Sichere Datenspeicherung
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </main>
    </div>
  );
}
