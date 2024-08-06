/*

Queries used for Tableau Project Covid_deaths

*/

use PortfolioProject;

-- 1. 

SELECT SUM(CAST(new_cases AS INT)) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(New_Cases AS FLOAT))*100 AS DeathPercentage
FROM covid_deaths
-- WHERE location like 'Switzerland'
WHERE continent NOT LIKE '' AND total_deaths > 0
--Group By date
ORDER BY 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--FROM covid_deaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(cast(new_deaths AS INT)) AS TotalDeathCount
FROM covid_deaths
--Where location like '%states%'
WHERE continent LIKE ''
AND location NOT IN ('Low income', 'Lower middle income', 'Upper middle income', 'High income', 'World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- SELECT continent, location, new_deaths, total_cases
-- FROM covid_deaths
-- WHERE location in ('Low income', 'Lower middle income', 'Upper middle income', 'High income')

-- 3.

SELECT Location, Population, NULLIF(MAX(total_cases), 0) AS HighestInfectionCount,  
Max(CAST(total_cases AS FLOAT)/(CAST(population AS FLOAT)))*100 AS PercentPopulationInfected
FROM covid_deaths
--Where location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- 4.


SELECT Location, Population, Date, NULLIF(MAX(total_cases), 0) AS HighestInfectionCount,  
Max(CAST(total_cases AS FLOAT)/(CAST(population AS FLOAT)))*100 AS PercentPopulationInfected
FROM covid_deaths
--Where location like '%states%'
GROUP BY Location, Population, Date
ORDER BY PercentPopulationInfected DESC






-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out


-- 1.

SELECT cd.continent, cd.location, cd.date, cd.population,
MAX(cv.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM covid_deaths cd
JOIN covid_vaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent NOT LIKE '' AND new_vaccinations NOT LIKE '' 
GROUP BY cd.continent, cd.location, cd.date, cd.population
ORDER BY 1,2,3




-- 2.
Select SUM(CAST(new_cases AS INT)) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(New_Cases AS FLOAT))*100 AS DeathPercentage
FROM covid_deaths
--Where location like '%states%'
WHERE continent NOT LIKE ''
--Group By date
ORDER BY 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


-- Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
-- FROM covid_deaths
---- Where location like '%states%'
-- where location = 'World'
---- Group By date
-- order by 1,2


-- 3.

-- We take these out as they are not included in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM covid_deaths
--Where location like '%states%'
WHERE continent NOT LIKE '' 
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC



-- 4.

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  
Max(CAST(total_cases AS FLOAT)/(CAST(population AS FLOAT)))*100 AS PercentPopulationInfected
FROM covid_deaths
--Where location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--FROM covid_deaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population

SELECT Location, date, population, total_cases, total_deaths
FROM covid_deaths
--Where location like '%states%'
WHERE continent NOT LIKE '' AND total_cases > 0
ORDER BY 1, 2


-- 6. 

WITH VacbyPop (continent, location, date, population, new_vaccinations, RollingPeopleVaccinations)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinations
-- SUM(convert(int, cv.new_vaccinations)) OVER (PARTITION BY cd.location)
FROM covid_deaths cd
JOIN covid_vaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent NOT LIKE '' AND new_vaccinations NOT LIKE ''
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinations/(CAST(population AS FLOAT)))*100 AS VaccinationsPercentage
FROM VacbyPop



-- 7. 

SELECT Location, Population, date, MAX(total_cases) AS HighestInfectionCount, 
MAX((CONVERT(FLOAT, total_cases) / NULLIF(CONVERT(FLOAT, population ), 0))) * 100 AS PercentagePopulationInfected
FROM covid_deaths
GROUP BY location, population, date
ORDER BY 4 DESC
