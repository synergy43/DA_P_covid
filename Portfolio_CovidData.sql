/*
Data Exploration - Covid 19 Data - SQL Server
Skills Used- Joins, CTE's, Temp Tables, Windows Functions, Aggregate Function, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject.[dbo].CovidDeaths$
Order by 3, 4


--SELECT *
--FROM PortfolioProject.[dbo].CovidVaccinations$
--Order by 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.[dbo].CovidDeaths$
ORDER BY 1, 2

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in a particular country

SELECT Location, date, total_cases, total_deaths, (CONVERT(DECIMAL(15, 3), total_deaths)/total_cases)*100 as DeathPercentage
FROM PortfolioProject.[dbo].CovidDeaths$
WHERE location='Australia'
ORDER BY 1, 2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfection
FROM PortfolioProject.[dbo].CovidDeaths$
WHERE location='Australia'
ORDER BY 1, 2

--Countries with Highest Infection rate based on Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfection
FROM PortfolioProject.[dbo].CovidDeaths$
GROUP BY Location, Population
ORDER BY PercentPopulationInfection DESC

--Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.[dbo].CovidDeaths$
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC


--Deaths by Continent and Class
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.[dbo].CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Continents with Highest Death Count
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.[dbo].CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global numbers (Death Count)

SELECT SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.[dbo].CovidDeaths$
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1, 2


--Total Population vs Vaccinations
SELECT CD.continent, CV.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(DECIMAL(15), CV.new_vaccinations)) 
OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) as  RollingCount_Vaccinated
FROM PortfolioProject.[dbo].CovidDeaths$ AS CD
JOIN PortfolioProject..CovidVaccinations$ AS CV
	ON CD.location = CV.location
	and CD.date = CV.date
WHERE CD.continent is NOT NULL
ORDER BY 2,3


--Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingCount_Vaccinated)
AS
(
SELECT CD.continent, CV.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(DECIMAL(15), CV.new_vaccinations)) 
OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) as  RollingCount_Vaccinated
FROM PortfolioProject.[dbo].CovidDeaths$ AS CD
JOIN PortfolioProject..CovidVaccinations$ AS CV
	ON CD.location = CV.location
	and CD.date = CV.date
WHERE CD.continent is NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingCount_Vaccinated/Population)*100
FROM PopvsVac

--TEMP Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCount_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT CD.continent, CV.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(DECIMAL(15), CV.new_vaccinations)) 
OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) as  RollingCount_Vaccinated
FROM PortfolioProject.[dbo].CovidDeaths$ AS CD
JOIN PortfolioProject..CovidVaccinations$ AS CV
	ON CD.location = CV.location
	and CD.date = CV.date
WHERE CD.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (RollingCount_Vaccinated/Population)*100
From #PercentPopulationVaccinated

--VIEW
CREATE VIEW PercentPopulationVaccinated AS
SELECT CD.continent, CV.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(DECIMAL(15), CV.new_vaccinations)) 
OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) as  RollingCount_Vaccinated
FROM PortfolioProject.[dbo].CovidDeaths$ AS CD
JOIN PortfolioProject..CovidVaccinations$ AS CV
	ON CD.location = CV.location
	and CD.date = CV.date
WHERE CD.continent is NOT NULL
--ORDER BY 2,3

--DROP VIEW PercentPopulationVaccinated






