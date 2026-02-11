'use client';

import { useEffect } from 'react';
import { useBudgetStore } from '@/lib/stores/budget-store';
import { initializePredefinedCategories } from '@/lib/utils';

export function AppProvider({ children }: { children: React.ReactNode }) {
  const { initialize, initialized, settings } = useBudgetStore();

  useEffect(() => {
    const init = async () => {
      await initialize();
      await initializePredefinedCategories();
    };

    if (!initialized) {
      init();
    }
  }, [initialize, initialized]);

  useEffect(() => {
    // Apply dark mode
    if (settings.darkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [settings.darkMode]);

  if (!initialized) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600 dark:text-gray-400">Laden...</p>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}
