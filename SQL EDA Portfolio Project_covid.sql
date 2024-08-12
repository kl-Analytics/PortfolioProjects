/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

use PortfolioProject;

SELECT * FROM covid_deaths
-- WHERE continent LIKE ''
ORDER BY 2,3;

SELECT * FROM covid_vaccinations
ORDER BY 3,4;

-- Select Data that we are going to be using
-- Covid_Deaths

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM covid_deaths
ORDER BY 1,2;

-- Checking for NULL Values
-- Looking for location without cases of Infection (NULL Values)
-- Deleting Data with NULL Values

SELECT *
-- location, population, date, total_cases
FROM covid_deaths
WHERE total_cases like ''
ORDER BY 1,3;

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
FROM covid_deaths
-- WHERE location like 'Switzerland'
-- WHERE location like '%states%'
ORDER BY 1,2;

-- Looking at total_cases vs Population
-- Shows percentage of population got Covid

SELECT location, date, population, total_cases, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population ), 0)) * 100 AS TotalPercentageInfected
FROM covid_deaths
ORDER BY 1,2;

-- Looking for Countries with highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population ), 0))) * 100 AS PercentagePopulationInfected
FROM covid_deaths
GROUP BY location, population
ORDER BY 4 DESC;

-- Looking for Continents with Highest Death Count

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
-- , MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population ), 0))) * 100 AS TotalDeathsPercentage
FROM covid_deaths
WHERE continent NOT LIKE '' AND total_deaths > 0
GROUP BY continent
ORDER BY 2 DESC;

-- Looking for Countries with Highest Death Count

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
-- , MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population ), 0))) * 100 AS TotalDeathsPercentage
FROM covid_deaths
WHERE continent NOT LIKE '' AND total_deaths > 0
GROUP BY location
ORDER BY 2 DESC;

-- Looking for Countries with Highest Death Count by Continent

SELECT location, continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
-- , MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population ), 0))) * 100 AS TotalDeathsPercentage
FROM covid_deaths
WHERE continent NOT LIKE '' AND total_deaths > 0
GROUP BY location, continent
ORDER BY 2;

-- Global Numbers

SELECT 
	date, 
	SUM(CONVERT(float, total_cases)) AS SumTotalCases,
	SUM(CONVERT(float, new_cases)) AS SumNewCases,
	SUM(CONVERT(float,total_deaths)) AS SumTotalDeaths
-- (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
FROM covid_deaths
WHERE continent NOT LIKE '' AND total_deaths > 0
GROUP BY date
ORDER BY 1,2;

SELECT 
	date,
	SUM(cast(new_cases as int)) AS SumNewcases,
	SUM(cast(new_deaths as int)) AS SumNewDeaths,
	SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)) * 100 AS TotalDeathsPercentage
FROM covid_deaths
WHERE continent NOT LIKE '' AND new_cases > 0 AND new_deaths <> 0
GROUP BY date
ORDER BY 1,2;

SELECT 
	SUM(cast(new_cases as int)) AS SumNewcases,
	SUM(cast(new_deaths as int)) AS SumNewDeaths,
	SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)) * 100 AS TotalDeathsPercentage
FROM covid_deaths
WHERE continent NOT LIKE '' AND new_cases > 0 AND new_deaths > 0
ORDER BY 1,2;

-------------------------------------------------------------------------------------------------------
-- Covid_Vaccinations

-- Looking at Total Population by Vaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinations
-- SUM(convert(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location)
FROM covid_deaths cd
JOIN covid_vaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent NOT LIKE '' AND new_vaccinations NOT LIKE ''
ORDER BY 2, 3; 

-- Use CTE

WITH VacbyPop (continent, location, date, population, new_vaccinations, RollingPeopleVaccinations)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinations
-- SUM(convert(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location)
FROM covid_deaths cd
JOIN covid_vaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent NOT LIKE '' AND new_vaccinations NOT LIKE ''
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinations/(CAST(population AS FLOAT)))*100 AS VaccinationsPercentage
FROM VacbyPop;

-- Temp Table

DROP TABLE if exists #PercentPeopleVaccinated;

CREATE TABLE #PercentPeopleVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATE,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinations NUMERIC
)

INSERT INTO #PercentPeopleVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinations
-- SUM(convert(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location)
FROM covid_deaths cd
JOIN covid_vaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent NOT LIKE '' AND new_vaccinations NOT LIKE ''
-- ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinations/(CAST(population AS FLOAT)))*100 AS VaccinationsPercentage
FROM #PercentPeopleVaccinated;

-- Creating View to store Data for Visualisations

CREATE OR ALTER VIEW PercentPeopleVaccinated
AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinations
-- SUM(convert(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location)
FROM covid_deaths cd
JOIN covid_vaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent NOT LIKE '' AND new_vaccinations NOT LIKE '';

SELECT *
FROM PercentPeopleVaccinated;




-- 1:14:33 create new repository on GitHub
