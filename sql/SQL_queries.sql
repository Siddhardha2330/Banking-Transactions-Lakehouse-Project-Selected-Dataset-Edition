-- Base Dataset: Banking Main Dataset
-- Joins transactions, accounts, customers, branches, and cards tables
SELECT
  t.transaction_date,
  t.amount,
  t.transaction_type,
  t.balance as transaction_balance,
  a.latest_balance as account_balance,
  a.account_type,
  c.customer_id,
  c.customer_name,
  c.city as customer_city,
  b.branch_id,
  b.branch_name,
  b.city as branch_city,
  card.card_type,
  CASE WHEN t.transaction_type = 'credit' THEN t.amount ELSE -t.amount END as net_transaction_value
FROM delta.`/Volumes/workspace/default/banking-transactions-lakehouse-project-selected-dataset-edition/delta/gold/transactions` t
  INNER JOIN delta.`/Volumes/workspace/default/banking-transactions-lakehouse-project-selected-dataset-edition/delta/gold/accounts` a ON t.account_id = a.account_id
  INNER JOIN delta.`/Volumes/workspace/default/banking-transactions-lakehouse-project-selected-dataset-edition/delta/gold/customers` c ON a.account_id = c.account_id
  INNER JOIN delta.`/Volumes/workspace/default/banking-transactions-lakehouse-project-selected-dataset-edition/delta/gold/branches` b ON a.branch_id = b.branch_id
  LEFT JOIN delta.`/Volumes/workspace/default/banking-transactions-lakehouse-project-selected-dataset-edition/delta/gold/cards` card ON a.account_id = card.account_id;

-- KPI 1: Total Transactions Count
SELECT COUNT(*) as total_transactions FROM <base_dataset>;

-- KPI 2: Total Credit Amount
SELECT SUM(amount) as total_credit FROM <base_dataset> WHERE transaction_type = 'credit';

-- KPI 3: Total Debit Amount
SELECT SUM(amount) as total_debit FROM <base_dataset> WHERE transaction_type = 'debit';

-- KPI 4: Net Transaction Amount
SELECT SUM(net_transaction_value) as net_amount FROM <base_dataset>;

-- KPI 5: Total Customers Count
SELECT COUNT(DISTINCT customer_id) as total_customers FROM <base_dataset>;

-- KPI 6: Average Account Balance
SELECT AVG(account_balance) as avg_balance FROM <base_dataset>;

-- KPI 7: Average Transaction Amount
SELECT AVG(amount) as avg_transaction FROM <base_dataset>;

-- KPI 8: Top Account Balance
SELECT MAX(account_balance) as top_balance FROM <base_dataset>;

-- Top Customers by Account Balance
SELECT customer_name, MAX(account_balance) as account_balance FROM <base_dataset> GROUP BY customer_name ORDER BY account_balance DESC;

-- Number of Customers by City
SELECT customer_city, COUNT(DISTINCT customer_id) as customer_count FROM <base_dataset> GROUP BY customer_city;

-- Customer Activity by Transaction Count
SELECT customer_name, COUNT(*) as transaction_count FROM <base_dataset> GROUP BY customer_name ORDER BY transaction_count DESC;

-- Credit vs Debit Comparison
SELECT transaction_type, SUM(amount) as total_amount FROM <base_dataset> GROUP BY transaction_type;

-- Transactions Over Time
SELECT transaction_date, transaction_type, COUNT(*) as transaction_count FROM <base_dataset> GROUP BY transaction_date, transaction_type ORDER BY transaction_date;

-- Transaction Amount Trend Over Time
SELECT transaction_date, transaction_type, SUM(amount) as total_amount FROM <base_dataset> GROUP BY transaction_date, transaction_type ORDER BY transaction_date;

-- Transactions per Branch
SELECT branch_name, transaction_type, COUNT(*) as transaction_count FROM <base_dataset> GROUP BY branch_name, transaction_type;

-- Total Balance per Branch
SELECT branch_name, SUM(account_balance) as total_balance FROM <base_dataset> GROUP BY branch_name;

-- Customer Distribution by Branch
SELECT branch_name, COUNT(DISTINCT customer_id) as customer_count FROM <base_dataset> GROUP BY branch_name;

-- Debit vs Credit Cards Distribution
SELECT card_type, COUNT(DISTINCT customer_id) as card_count FROM <base_dataset> GROUP BY card_type;

-- Transactions by Card Type
SELECT card_type, transaction_type, SUM(amount) as transaction_amount FROM <base_dataset> GROUP BY card_type, transaction_type;

-- Accounts with Highest Transaction Volume
SELECT customer_name, COUNT(*) as transaction_count FROM <base_dataset> GROUP BY customer_name ORDER BY transaction_count DESC;

-- Account Type Distribution
SELECT account_type, COUNT(DISTINCT customer_id) as account_count FROM <base_dataset> GROUP BY account_type;

-- Recent Transactions Details
SELECT transaction_date, customer_name, transaction_type, amount, branch_name, customer_city, card_type FROM <base_dataset> ORDER BY transaction_date DESC;
