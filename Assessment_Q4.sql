-- Q4: Customer Lifetime Value (CLV) Estimation

WITH user_tx_summary AS (
    SELECT 
        sa.owner_id,
        COUNT(*) AS total_transactions,  -- Number of deposit transactions per user
        SUM(sa.confirmed_amount) AS total_amount_kobo  -- Total deposit amount in kobo
    FROM savings_savingsaccount sa
    WHERE sa.confirmed_amount > 0
    GROUP BY sa.owner_id
),
user_with_tenure AS (
    SELECT 
        u.id AS customer_id,
        u.name,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,  -- Full calendar months since account creation
        uts.total_transactions,
        uts.total_amount_kobo
    FROM users_customuser u
    JOIN user_tx_summary uts ON u.id = uts.owner_id
    WHERE u.date_joined IS NOT NULL  -- Ensure valid signup dates
),
clv_calc AS (
    SELECT 
        customer_id,
        name,
        CASE 
            WHEN tenure_months < 1 THEN 1  
            ELSE tenure_months
        END AS tenure_months,
        total_transactions,
        ROUND(
            (total_transactions / 
                CASE 
                    WHEN tenure_months < 1 THEN 1  -- Ensure minimum 1 month to avoid division by zero
                    ELSE tenure_months 
                END
            ) * 12 * 
            (total_amount_kobo * 0.001 / total_transactions / 100),  -- Average profit per transaction in naira
            2
        ) AS estimated_clv
    FROM user_with_tenure
)

-- Return the CLV data, sorted by highest estimated clv
SELECT *
FROM clv_calc
ORDER BY estimated_clv DESC;