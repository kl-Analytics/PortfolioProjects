-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null/Blank Values
-- 4. Remove any Columns or Rows

-- copy the Data from the source and create staging table

CREATE TABLE layoffs_staging
LIKE layoffs;
 
SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

------------------------------------------------------------------------------------------------
-- 1. Remove duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, 'date', stage,
country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Test

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Delete the Duplicates is not possible - can not update cte
-- Create a new table
-- right click on the table - copy to clipboard - Create Statement or create new Table

DROP TABLE layoffs_staging2;

CREATE TABLE layoffs_staging2 (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, 'date', stage,
country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;		-- rows are deleted

-------------------------------------------------------------------------------------------------
-- 2. Standardizing Data

-- Trim to delete space
SELECT company, TRIM(company)
FROM layoffs_staging2;
-- Update column
UPDATE layoffs_staging2
SET company = TRIM(company);

-- select Distinct values
SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;
-- check columns for Duplicates
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';
-- if more than 1 time is the same value -> update values that you have only distinct values
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- check columns for Duplicates
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

-- check columns for Duplicates
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';
-- make changes that both values are the same(United States, United States.)
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;
-- update columns with duplicate values
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)		-- Trailing = trim from the end
WHERE country LIKE 'United States%';

-- change 'date' in Date format (was created as text data type)
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;
-- update 'date' in Date format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
-- check
SELECT `date`
FROM layoffs_staging2;
-- modify Data type of column
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-----------------------------------------------------------------------------------------------
-- 3. Null/Blank Values

-- NULL Values
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Blanks
-- check Columns for NULL Values or Blanks
SELECT DISTINCT industry
FROM layoffs_staging2;
-- check for NULLS and Blanks
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- check Example Values were found
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';
-- check another Value with NULL in a column
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- Join tables (here self Join)
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Update Column
-- First: Update Blanks in NULL Values
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';
-- Second: Update NULL Values in Column
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Delete NULL Values
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
--------------------------------------------------------------------------------------------
-- 4. Remove any Columns or Rows you don't need anymore

SELECT *
FROM layoffs_staging2;

-- Delete Column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;