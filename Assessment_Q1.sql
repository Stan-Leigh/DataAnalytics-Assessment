-- Q1: High-Value Customers with Multiple Products

SELECT 
    u.id AS owner_id,
    u.name,
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_count,
    ROUND(SUM(sa.confirmed_amount) / 100, 2) AS total_deposits  -- converting from kobo to naira
FROM users_customuser AS u
JOIN plans_plan AS p ON u.id = p.owner_id
JOIN savings_savingsaccount sa ON sa.plan_id = p.id AND sa.confirmed_amount > 0  -- Only consider deposit transactions with inflow > 0
GROUP BY u.id, u.name
HAVING 
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) >= 1
    AND COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) >= 1  -- Ensure customer has at least one savings plan and one investment plan
ORDER BY total_deposits DESC;