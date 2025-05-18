-- Q3: Account Inactivity Alert

-- Step 1: Get the last deposit transaction date for each plan
WITH last_tx_per_plan AS (
    SELECT 
        plan_id,
        MAX(transaction_date) AS last_transaction_date  -- Most recent confirmed deposit date
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0  -- Only consider actual inflow transactions
    GROUP BY plan_id
)

SELECT 
    p.id AS plan_id,
    p.owner_id,
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Other'  -- Incase there are any others
    END AS type,
    lt.last_transaction_date,
    DATEDIFF(CURDATE(), lt.last_transaction_date) AS inactivity_days  -- Days since last deposit
FROM plans_plan p
JOIN last_tx_per_plan lt ON p.id = lt.plan_id
WHERE 
    DATEDIFF(CURDATE(), lt.last_transaction_date) > 365  -- Only include plans with over 1 year of inactivity
    AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)  -- Only consider savings or investment plans
    AND p.is_archived = 0  -- Exclude archived (inactive) plans
    AND p.is_deleted = 0;  -- Exclude deleted plans