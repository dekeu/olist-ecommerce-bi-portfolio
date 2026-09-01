# KPI Dictionary

These notes explain what each number in my dashboard means and how I calculate it. I’m keeping the definitions here so I can use them consistently and explain the results clearly.

## Sales and customers

I use `mart_orders` for these measures. For sales by product category, I use the item-level data in `mart_sales`.

* **Delivered GMV:** The total value of products in orders marked as delivered. I add up the product prices and leave out freight charges. GMV stands for Gross Merchandise Value—it is not Olist’s revenue or profit.

* **Delivered Orders:** The number of delivered orders. I count each `order_id` once, even when the order contains several products.

* **Delivered Customers:** The number of different customers who received a delivered order. I use `customer_unique_id`, so a customer with several orders is still counted once.

* **Average Order Value:** Delivered GMV divided by delivered orders. This tells me the average product value per delivered order, excluding freight.

## Delivery and customer reviews

These measures use `mart_orders`.

* **On-Time Delivery Rate:** The percentage of delivered orders confirmed as on time. I count delivered orders where `is_late = FALSE` and divide that number by all delivered orders.

* **Average Delivery Days:** The average number of days between purchase and delivery to the customer. I include delivered orders with valid delivery-duration values.

* **Average Review Score:** The average of the available customer ratings, which range from 1 to 5. I use the single review record kept for each order in the analysis table.

## Cancellations and freight

* **Cancellation Rate:** For this project, I group orders marked `canceled` and `unavailable` together. I divide their distinct order count by all distinct orders in `mart_orders`. I will make this definition clear on the dashboard.

* **Freight-to-GMV Ratio:** Total freight value for delivered items divided by their total product value, using `mart_sales`. This shows how large the freight charges are compared with the value of the products.

## Things to keep in mind

Missing review scores and delivery durations are left out of averages rather than treated as zero.

For the current on-time calculation, delivered orders with missing delivery information remain in the total but are not counted as confirmed on time. I need to check these cases before interpreting the rate; missing information does not automatically mean a late delivery.

If I change a calculation or its filtering rules, I will update these notes so they continue to match the dashboard.
