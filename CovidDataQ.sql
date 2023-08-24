SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


--got error Operand data type nvarchar is invalid for divide operator.
-- trying to solve
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths float;

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases float;

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Pakistan%'
ORDER BY 1, 2

-- Looking at the total cases versus population
SELECT location, date,  population, total_cases,(total_cases/population)*100 AS cases_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Pakistan%'
ORDER BY 1, 2

--Looking at countries with highest infection ratecompared to population
SELECT location, population, MAX(total_cases) AS max_cases, MAX((total_cases/population))*100 AS population_infected_percentage
FROM PortfolioProject..CovidDeaths
GROUP BY  location, population
ORDER BY population_infected_percentage desc

--Looking at countries with highest death rate compared to population
SELECT location, MAX(cast(total_deaths as int)) AS death_rate_population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY  location
ORDER BY death_rate_population desc

--Looking at continent data with highest death count
SELECT location, MAX(cast(total_deaths as int)) AS death_rate_population
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY  location
ORDER BY death_rate_population desc


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS new_cases_total, SUM(cast(new_deaths AS int)) AS new_deaths_total, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as global_death
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2


--Indexing table to increase the speed of execution while using joins.
CREATE INDEX idx_P
ON PortfolioProject..CovidDeaths (location);
--Starting vaccination queries
--Vaccination v/s population
-- Using CTE
WITH popVsVac(continent, location, date, population, new_vaccination,rolling)
AS(
	SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vac
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null
	
)Select *, (rolling/population)*100
FROM popVsVac

-- using temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	continent nvarchar(255), 
	location nvarchar(255), 
	date datetime, 
	population numeric, 
	new_vaccination numeric,
	rolling numeric)

INSERT INTO #PercentPopulationVaccinated
	SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vac
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null

Select *, (rolling/population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for visulizations
CREATE VIEW PercentPopultionVaccinated AS
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vac
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null

