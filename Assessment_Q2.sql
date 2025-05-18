-- Q2: Transaction Frequency Analysis

-- Step 1: Get total transactions and active duration (in months) per customer
WITH customer_tx AS (
    SELECT 
        owner_id,
        COUNT(*) AS total_tx,
        PERIOD_DIFF(EXTRACT(YEAR_MONTH FROM MAX(transaction_date)), EXTRACT(YEAR_MONTH FROM MIN(transaction_date))) + 1 AS active_months
    FROM savings_savingsaccount
    GROUP BY owner_id
),

-- Step 2: Compute average transactions per month
customer_avg_tx AS (
    SELECT 
        owner_id,
        total_tx,
        active_months,
        total_tx / active_months AS avg_tx_per_month
    FROM customer_tx
),

-- Step 3: Categorize users based on average monthly transaction frequency
categorized_customers AS (
    SELECT 
        owner_id,
        avg_tx_per_month,
        CASE 
            WHEN avg_tx_per_month >= 10 THEN 'High Frequency'
            WHEN avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'  -- BETWEEN is inclusive so 3 and 9 is included.
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM customer_avg_tx
)

-- Step 4: Aggregate results by frequency category
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month  -- rounding to 1 decimal place to match the expected output
FROM categorized_customers
GROUP BY frequency_category
ORDER BY 
    CASE frequency_category 
        WHEN 'High Frequency' THEN 1 
        WHEN 'Medium Frequency' THEN 2 
        WHEN 'Low Frequency' THEN 3 
    END;