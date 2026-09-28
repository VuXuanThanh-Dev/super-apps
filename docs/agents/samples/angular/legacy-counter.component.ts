import { Component, EventEmitter, Input, OnDestroy, OnInit, Output } from '@angular/core';
import { interval, Subscription } from 'rxjs';

// Legacy style: NgModule-declared, decorators, *ngIf/*ngFor, manual subscription.
@Component({
  selector: 'app-counter',
  template: `
    <h3>{{ title }}</h3>
    <p *ngIf="count > 0; else zero">Count: {{ count }} (double: {{ count * 2 }})</p>
    <ng-template #zero><p>Nothing yet</p></ng-template>
    <ul><li *ngFor="let h of history">{{ h }}</li></ul>
    <button (click)="inc()">+1</button>
  `,
})
export class CounterComponent implements OnInit, OnDestroy {
  @Input() title = 'Counter';
  @Input() start = 0;
  @Output() changed = new EventEmitter<number>();
  count = 0;
  history: number[] = [];
  private sub?: Subscription;

  ngOnInit() {
    this.count = this.start;
    this.sub = interval(10000).subscribe(() => this.inc());
  }

  inc() {
    this.count++;
    this.history.push(this.count);
    this.changed.emit(this.count);
  }

  ngOnDestroy() {
    this.sub?.unsubscribe();
  }
}
