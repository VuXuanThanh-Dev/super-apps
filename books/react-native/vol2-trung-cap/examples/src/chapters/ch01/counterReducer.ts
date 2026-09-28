// useReducer: state cục bộ, logic tập trung trong một hàm thuần (giống NgRx reducer thu nhỏ).
export type CounterAction = { type: 'inc' } | { type: 'dec' } | { type: 'reset' };

export function counterReducer(state: number, action: CounterAction): number {
  switch (action.type) {
    case 'inc':
      return state + 1;
    case 'dec':
      return Math.max(0, state - 1);
    case 'reset':
      return 0;
  }
}
