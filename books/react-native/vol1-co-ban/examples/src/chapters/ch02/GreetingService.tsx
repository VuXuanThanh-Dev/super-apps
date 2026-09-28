import { createContext, useContext, useMemo, type ReactNode } from 'react';

// Angular DI:  @Injectable() class GreetingService { greet(name) {...} }
//              providers: [{ provide: GreetingService, useClass: FormalGreetingService }]
// React:       Context + Provider. "useClass" = truyền một implementation khác vào value.
export interface GreetingService {
  greet: (name: string) => string;
}

export const friendlyGreeting: GreetingService = { greet: (name) => `Chào ${name}!` };
export const formalGreeting: GreetingService = { greet: (name) => `Kính chào anh/chị ${name}.` };

const GreetingContext = createContext<GreetingService>(friendlyGreeting);

export function GreetingProvider({ service, children }: { service: GreetingService; children: ReactNode }) {
  const value = useMemo(() => service, [service]);
  return <GreetingContext.Provider value={value}>{children}</GreetingContext.Provider>;
}

// Giống inject(GreetingService)
export function useGreeting(): GreetingService {
  return useContext(GreetingContext);
}
