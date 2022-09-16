SELECT * 
FROM covid_dataset..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT * 
--FROM covid_dataset..Covid_Vaccinatins
--ORDER BY 3,4


-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_dataset..Covid_Deaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM covid_dataset..Covid_Deaths
WHERE location LIKE '%states%' AND total_deaths IS NOT NULL
ORDER BY 1,2

-- Shows the likelihood if you contract covid in Pakistan or Germany
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM covid_dataset..Covid_Deaths
WHERE location LIKE '%akistan%' OR location LIKE '_ermany'
ORDER BY 3 DESC


-- Looking at Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 as Total_Cases_Percentage
FROM covid_dataset..Covid_Deaths
WHERE location LIKE '%_many%'
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population
SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX(total_cases/population)*100 AS Total_Cases_Percentage
FROM covid_dataset..Covid_Deaths
--WHERE location LIKE '%_many%'
GROUP BY location,population
ORDER BY Total_Cases_Percentage DESC


-- Showing Countries with Percentage Highest Death Count per Population
SELECT location,MAX(total_cases) AS HighestCasesCount, MAX(total_deaths) AS HighestDeathCount, population, (MAX(total_deaths)/population)*100 AS Total_Death_Percentage
FROM covid_dataset..Covid_Deaths
--WHERE location LIKE '%_many%'
GROUP BY location,population
ORDER BY 2 DESC


-- Showing Countries with Highest Death Count per Population, This is Correct!
SELECT location,MAX(cast(total_deaths AS INT)) AS TotalDeathCount,MAX(total_cases) AS TotalCasesCount ,population
FROM covid_dataset..Covid_Deaths
--WHERE location LIKE '%_many%'
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 2 DESC


-- Lets Break things down by continent as TotalDeathCount and TotalCasesCount
SELECT continent,MAX(cast(total_deaths AS INT)) AS TotalDeathCount, MAX(total_cases) AS TotalCasesCount
FROM covid_dataset..Covid_Deaths
GROUP BY continent
ORDER BY 2 DESC


-- Showing the continents with the highest death count per population
SELECT continent,MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM covid_dataset..Covid_Deaths
--WHERE location LIKE '%_many%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC



-- Global Numbers
SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths AS INT)) AS New_Deaths, (SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 AS Death_Percentage
FROM covid_dataset..Covid_Deaths
-- WHERE location LIKE '%states%' AND 
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1


SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths AS INT)) AS Total_Deaths, SUM(DISTINCT population) AS Total_World_Population, (SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 AS Death_Percentage_Over_Cases,
(SUM(new_cases)/SUM(DISTINCT population))*100 AS Cases_Percentage_Over_Population,(SUM(cast(new_deaths AS INT))/SUM(DISTINCT population))*100 AS Death_Percentage_Over_Cases
FROM covid_dataset..Covid_Deaths
-- WHERE location LIKE '%states%' AND 
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1



-- Joining covid_deaths and covid_vaccinations tables together
SELECT * 
FROM covid_dataset..Covid_Deaths dea
JOIN covid_dataset..Covid_Vaccinatins vac
ON dea.location = vac.location
AND dea.date = vac.date


-- Looking at Total Population vs Vaccinations
SELECT dea.location ,dea.population, MAX(vac.new_vaccinations) AS New_Vaccinations
FROM covid_dataset..Covid_Deaths dea
JOIN covid_dataset..Covid_Vaccinatins vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location,dea.population
ORDER BY 1 


-- Adding new Vaccinations into Total Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations
FROM covid_dataset..Covid_Deaths dea
JOIN covid_dataset..Covid_Vaccinatins vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE
WITH PopulationvsVaccinations (Continent, Location, Date, Population, New_Vaccinations, Total_Vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations
FROM covid_dataset..Covid_Deaths dea
JOIN covid_dataset..Covid_Vaccinatins vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * , (Total_Vaccinations/Population)*100 AS PERCENTAGE
FROM PopulationvsVaccinations

-- ALTERNATE METHOD

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
Total_Vaccinations NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations
FROM covid_dataset..Covid_Deaths dea
JOIN covid_dataset..Covid_Vaccinatins vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2

SELECT * , (Total_Vaccinations/Population)*100 AS PERCENTAGE
FROM #PercentPopulationVaccinated



-- Creating View to Store data for later Visualizations
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations
FROM covid_dataset..Covid_Deaths dea
JOIN covid_dataset..Covid_Vaccinatins vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

--DROP VIEW IF EXISTS [dbo].[PercentPopulationVaccinated]


SELECT * FROM PercentPopulationVaccinated