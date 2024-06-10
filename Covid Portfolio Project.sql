/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Converting Data Types

*/

SELECT * 
FROM CovidProject..CovidDeaths$
WHERE continent  is not null
ORDER BY 3,4

--SELECT * 
--FROM CovidProject..CovidVaccinations$
--ORDER BY 3,4

--Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths$
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihhood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM CovidProject..CovidDeaths$
--WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of population contracting Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths$
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths$
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM CovidProject..CovidDeaths$
WHERE continent  is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global Death Percentages
SELECT sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths$
WHERE continent is not null
order by 1,2

--Global Death Count by Continent
SELECT location, SUM(cast(new_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths$
WHERE continent is null
AND location not in ('World', 'European Union', 'International', 'High Income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC


--Looking at Total Population vs Vaccinations

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths$ dea
JOIN CovidProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 AS RollingVaccinationPercentages
FROM PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths$ dea
JOIN CovidProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100 AS RollingVaccinationPercentages
FROM #PercentPopulationVaccinated


