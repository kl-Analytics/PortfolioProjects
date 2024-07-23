-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

-- Looking at Total and Percentage to see how big these layoffs were
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of they company laid off
-- if we order by funds_raised_millions we can see how big some of these companies were
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- these are mostly startups it looks like who all went out of business during this time


-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Date were layoffs documented
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- this it total in the past 3 years or in the dataset
-- by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- by country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- by Year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- ba stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- by Month
SELECT SUBSTRING(`date`, 1, 7) as `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 2 DESC;

-- Rolling Total of Layoffs Per Month
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) as `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 2 DESC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- Companies with the most Layoffs by Year and Country
SELECT company, country, YEAR(`date`) AS Year, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company, country, YEAR(`date`)
ORDER BY 3;

WITH Company_Country_Year AS
(
SELECT company, country, YEAR(`date`) AS Year, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company, country, YEAR(`date`)
ORDER BY 1
)
SELECT *
FROM Company_Country_Year;

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`) AS Year, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company, YEAR(`date`)
-- ORDER BY 3 DESC
),
Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
-- ORDER BY Ranking;
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;







