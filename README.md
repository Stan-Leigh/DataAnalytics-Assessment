
Each SQL file contains a single, well-formatted query with inline comments to explain any complex logic.

---

## Question 1: High-Value Customers with Multiple Products

**Objective**: Identify customers who have both a funded savings plan and a funded investment plan, sorted by total deposit amount.

**Approach**:
- Used `plans_plan` to identify savings (`is_regular_savings = 1`) and investment (`is_a_fund = 1`) plans.
- Joined with `savings_savingsaccount` to calculate total `confirmed_amount`.
- Filtered only funded plans (confirmed_amount > 0).
- Converted the `confirmed_amount` column from kobo to naira by dividing by 100 and rounding to 2 decimal places.
- Grouped by customer and used conditional aggregation to count plan types.
- Returned customers with at least one of each type, ordered by deposit total.

**Assumptions**:
- "Funded" = has at least one deposit (`confirmed_amount > 0`)
- Only deposit transactions from `savings_savingsaccount` are considered.
- There was no ordering specification so I defaulted to descending order to show the largest deposits first.

---

## Question 2: Transaction Frequency Analysis

**Objective**: Classify users into frequency tiers based on their average number of transactions per month.

**Approach**:
- Counted total transactions per user from `savings_savingsaccount`.
- Calculated active period in months from first to last transaction date using `PERIOD_DIFF`.
- Used the `PERIOD_DIFF` function because partial months where customers made transactions should be included. For example, if a customer's first transaction date is 27/02/2024 and the last transaction date is 12/03/2024, the number of active months should be **2**.
- Added **1** to the result of the `PERIOD_DIFF` to take care of customers with first and last transaction date in the same month, preventing `division by 0` errors. It also ensures that the first month is included when `PERIOD_DIFF` makes its count.
- Computed average monthly transactions.
- Bucketed users into "High", "Medium", or "Low" categories based on given thresholds.
- Aggregated and returned customer counts and average transaction rates per tier.

**Assumptions**:
- Active period is defined as the months that at least one transaction took place.
- At least one month of activity is assumed if the `transaction_date` column is not null.

---

## Question 3: Account Inactivity Alert

**Objective**: Find all active savings or investment accounts with no deposits in the last 365 days.

**Approach**:
- Identified latest transaction per plan (`confirmed_amount > 0`).
- Joined with `plans_plan` to classify plan type and verify it is not deleted/archived.
- Filtered for plans where the last transaction is more than 1 year ago.
- Calculated number of inactivity days using `DATEDIFF`.

**Assumptions**:
- Only considers deposit activity for inactivity (no withdrawals).
- Active accounts are assumed to be defined as `is_deleted = 0` and `is_archived = 0`.

---

## Question 4: Customer Lifetime Value (CLV) Estimation

**Objective**: Estimate CLV using account tenure and transaction volume.

**Approach**:
- Joined `users_customuser` and `savings_savingsaccount` by `owner_id`.
- Calculated tenure as number of complete months since `date_joined`.
- Computed total confirmed deposits and transaction count.
- Applied given formula:
  \[
  CLV = \left( \frac{total\_transactions}{tenure} \right) \times 12 \times 0.1\% \text{ of avg transaction value}
  \]
- Converted the estimated CLV values from **kobo** to **naira** by dividing by 100.
- Sorted users by estimated CLV in descending order as requested.

**Assumptions**:
- Account tenure is assumed to be expected as whole months (following the format of the expected output), so I did not express `tenure_months` as a decimal figure which may give a more accurate CLV estimate.
- Customers with <1 month tenure are treated as 1-month to prevent `division by 0` error.

---

## Challenges & Solutions

- **Kobo-to-naira conversion**: All monetary fields were divided by 100 and rounded to 2 decimal places.
- **Handling zero-division and nulls**: Implemented default logic (e.g., minimum 1 month tenure) to handle edge cases robustly.
- **Account tenure interpretation**: Calculated account tenure as the number of complete months since signup, expressed as a whole number to match what was displayed as the expected output.

---

## Notes

- All queries are written for compatibility with MySQL.

---

Thank you for reviewing my submission.