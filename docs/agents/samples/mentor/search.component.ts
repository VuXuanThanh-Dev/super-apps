// Intern question: "What does this code do? Why switchMap and not mergeMap?"
results$ = this.searchControl.valueChanges.pipe(
  debounceTime(300),
  map((term) => term.trim()),
  distinctUntilChanged(),
  filter((term) => term.length >= 2),
  switchMap((term) => this.api.search(term).pipe(catchError(() => of([])))),
);
