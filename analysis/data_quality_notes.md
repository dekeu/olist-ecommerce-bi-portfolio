# Data Quality Notes

Date checked: 31 August 2026
Script used: `sql/02_quality_checks.sql`

Before building the analysis tables, I checked the source data for duplicate orders, missing key information, and records that did not connect correctly between tables.

## Data overview

The six source tables contain the following numbers of rows:

| Table                |    Rows |
| -------------------- | ------: |
| category_translation |      71 |
| customers            |  99,441 |
| order_items          | 112,650 |
| orders               |  99,441 |
| products             |  32,951 |
| reviews              |  99,224 |

There are more order-item rows than orders because a single order can contain several items. This is important to remember when joining the tables, since counting item rows as orders would overstate the number of orders.

The customers table also contains 99,441 rows, but that does not necessarily mean 99,441 different people. I will use `customer_unique_id` when counting unique customers.

## Results of the initial checks

I did not find any duplicate order IDs. The duplicate check returned zero rows, meaning no `order_id` appeared more than once in the orders table.

There were also no missing values in the three order fields I checked:

* Order ID: 0 missing
* Customer ID: 0 missing
* Purchase date: 0 missing

The relationship checks returned zero unmatched records. Every order-item row linked to an existing order, and every order linked to a customer record.

## Order statuses

| Status      | Orders |
| ----------- | -----: |
| delivered   | 96,478 |
| shipped     |  1,107 |
| canceled    |    625 |
| unavailable |    609 |
| invoiced    |    314 |
| processing  |    301 |
| created     |      5 |
| approved    |      2 |
| Total       | 99,441 |

Most orders were marked as delivered. The status counts add up to 99,441, which matches the total number of orders.

The other statuses are not automatically data errors. I will keep them in the source data and apply the appropriate status filters when calculating each KPI.

## Time period covered

The earliest purchase date is 4 September 2016, and the latest is 17 October 2018.

The dataset includes partial years, so comparing annual totals directly could be misleading. It is also historical data and should not be presented as Olist’s current business performance.

## Overall assessment

The initial checks did not reveal problems with order IDs, the key fields checked, or the two table relationships tested. I can move on to building the analysis tables.

However, this does not mean the entire dataset is free of issues. Other fields still need attention, including review coverage. The difference between the orders and reviews row counts does not tell me exactly how many orders lack reviews, because an order may have multiple review records.
