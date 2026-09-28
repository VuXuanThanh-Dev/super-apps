package com.example.shop.order;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final StockRepository stockRepository;

    public OrderService(OrderRepository orderRepository, StockRepository stockRepository) {
        this.orderRepository = orderRepository;
        this.stockRepository = stockRepository;
    }

    public Order placeOrder(OrderRequest request) {
        return saveOrderAndReduceStock(request);
    }

    @Transactional
    private Order saveOrderAndReduceStock(OrderRequest request) {
        Order order = orderRepository.save(new Order(request.productId(), request.quantity()));
        stockRepository.decrease(request.productId(), request.quantity()); // throws when stock < quantity
        return order;
    }
}
