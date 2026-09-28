import { Component, Input, OnInit, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CartService, CartItem } from './cart.service';

@Component({
  selector: 'app-cart',
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div *ngIf="items.length > 0; else empty">
      <div *ngFor="let item of items" [ngClass]="{ 'sale': item.onSale }" (click)="remove(item)">
        {{ item.name }} - {{ formatPrice(item.price * item.qty) }}
      </div>
      <b>Total: {{ total() }}</b>
    </div>
    <ng-template #empty>Cart is empty</ng-template>
  `,
})
export class CartComponent implements OnInit {
  @Input() userId: any;
  items: CartItem[] = [];

  constructor(private cart: CartService) {}

  ngOnInit() {
    this.cart.items$(this.userId).subscribe((items) => (this.items = items));
  }

  total() {
    return this.items.reduce((s, i) => s + i.price * i.qty, 0);
  }

  formatPrice(v: number) {
    return v.toFixed(2) + ' $';
  }

  remove(item: CartItem) {
    this.cart.remove(item.id).subscribe(() => {
      this.cart.items$(this.userId).subscribe((items) => (this.items = items));
    });
  }
}
