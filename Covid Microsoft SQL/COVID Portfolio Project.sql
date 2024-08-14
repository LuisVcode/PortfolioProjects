--Verification of table contents
SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths 
--Shows likelihood of dying if you contract covid in state-named countries throughout the pandemic.
SELECT 
		Location, 
		date, 
		total_cases, 
		total_deaths, 
		ROUND((total_deaths / total_cases) * 100,1) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE (total_deaths / total_cases) * 100 IS NOT NULL AND location like '%states%'
ORDER BY total_cases DESC

--Looking at Total Cases vs Population 
--Shows likelihood of you contract covid in state-named countries throughout the pandemic.
SELECT 
		Location, 
		date, 
		population,
		total_cases, 
		ROUND((total_cases / population) * 100,1) AS ContractPercentage
FROM PortfolioProject..CovidDeaths
WHERE (total_cases / population) * 100 IS NOT NULL AND location like '%states%' 
ORDER BY total_cases DESC

--Looking at countries with highest infection rate compared to Population 

SELECT 
		Location, 	
		population, 
		MAX(total_cases) AS HighestInfectionCount,
		MAX(ROUND((total_cases / population) * 100,1)) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE (total_cases / population) * 100 IS NOT NULL AND continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population

SELECT 
    Location, 
    population, 
    MAX(CAST(total_deaths AS INT)) AS HighestDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE total_deaths IS NOT NULL
AND continent IS NOT NULL
GROUP BY Location, population
ORDER BY HighestDeathsCount DESC;


-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  ROUND(Max((total_cases/population))*100,1) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  ROUND(Max((total_cases/population))*100,2) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


--GLOBAL NUMBERS
SELECT 
    SUM(new_cases) AS Total_Cases,
    SUM(CAST(new_deaths AS INT)) AS Total_Deaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE (SUM(CAST(new_deaths AS INT)) / CAST(SUM(new_cases) AS FLOAT)) * 100 END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
HAVING SUM(CAST(total_deaths AS INT)) IS NOT NULL 
    AND SUM(new_cases) IS NOT NULL
ORDER BY Total_Deaths DESC;

--JOIN IN CovidDeaths AND CovidVaccinations
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT 
	DEA.continent,
	DEA.location,
	DEA.date,
	DEA.population,	
	VAC.new_vaccinations,
	SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.date) AS RollingPeopleVaccinated,
	CASE 
	WHEN VAC.new_vaccinations = 0 THEN 0
	ELSE (SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date)/DEA.population)*100 END AS Vaccionations_Percentage
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.date = VAC.date
	AND DEA.location = VAC.location
WHERE DEA.continent IS NOT NULL 
AND VAC.new_vaccinations IS NOT NULL
ORDER BY 1, 2 DESC

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac AS (
    SELECT 
        DEA.continent,
        DEA.location,
        DEA.date,
        DEA.population,    
        VAC.new_vaccinations,
	SUM(CONVERT(INT, VAC.new_vaccinations)) 
      OVER (PARTITION BY DEA.location ORDER BY DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.date = VAC.date
	AND DEA.location = VAC.location
WHERE DEA.continent IS NOT NULL 
AND VAC.new_vaccinations IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 as Vaccionations_Percentage
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
        DEA.continent,
        DEA.location,
        DEA.date,
        DEA.population,    
        VAC.new_vaccinations,
	SUM(CONVERT(INT, VAC.new_vaccinations)) 
      OVER (PARTITION BY DEA.location ORDER BY DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.date = VAC.date
	AND DEA.location = VAC.location

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT * 
FROM PercentPopulationVaccinated