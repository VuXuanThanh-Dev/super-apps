using System.Net.Http;
using Microsoft.Extensions.Logging;

namespace Shop.Services
{
    public class OrderService
    {
        private readonly ILogger<OrderService> _logger;
        private readonly ShopDbContext _db;

        public OrderService(ILogger<OrderService> logger, ShopDbContext db)
        {
            _logger = logger;
            _db = db;
        }

        public Order GetOrder(int id)
        {
            var order = _db.Orders.ToList().Where(o => o.Id == id).FirstOrDefault();
            _logger.LogInformation($"Loaded order {id} at {DateTime.Now}");
            return order!;
        }

        public async void SendInvoice(Order order)
        {
            var client = new HttpClient();
            var response = client.PostAsJsonAsync("https://billing.example.com/invoices", order).Result;
            try
            {
                response.EnsureSuccessStatusCode();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
