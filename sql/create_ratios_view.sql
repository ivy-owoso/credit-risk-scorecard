CREATE TABLE company_financials (
	company VARCHAR(50),
	ticker VARCHAR(10),
	sector VARCHAR(50),
	year INT,
	revenue DECIMAL(15,2),
	total_debt DECIMAL(15,2),
	total_equity DECIMAL(15,2),
	retained_earnings DECIMAL(15,2),
	ebit DECIMAL(15,2),
	interest_expense DECIMAL(15,2) NULL,
	current_assets DECIMAL(15,2) NULL,
	current_liabilities DECIMAL(15,2) NULL
);


CREATE VIEW company_ratios AS
SELECT
	company, ticker, sector, year,
	total_debt / total_equity AS debt_to_equity,
	
	CASE WHEN current_assets IS NOT NULL AND current_liabilities IS NOT NULL AND current_liabilities != 0
		THEN current_assets / current_liabilities END AS current_ratio,	
	
	CASE WHEN interest_expense IS NOT NULL AND interest_expense != 0 
		THEN ebit / interest_expense END AS interest_coverage,
		
	CASE
	    WHEN current_assets IS NOT NULL
	         AND current_liabilities IS NOT NULL
	         AND total_assets IS NOT NULL
	         AND total_assets != 0
	         AND retained_earnings IS NOT NULL
	         AND ebit IS NOT NULL
	         AND total_equity IS NOT NULL
	         AND (total_assets - total_equity) != 0
	         AND revenue IS NOT NULL
	    THEN
	        1.2 * ((current_assets - current_liabilities) / total_assets)
	      + 1.4 * (retained_earnings / total_assets)
	      + 3.3 * (ebit / total_assets)
	      + 0.6 * (total_equity / (total_assets - total_equity))
	      + 1.0 * (revenue / total_assets)
	END AS altman_z_score

FROM company_financials;
