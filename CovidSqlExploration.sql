--SQL COVID DATA EXPLORATION

SELECT TOP 10000 *
FROM PortFolioProject..CovidDeath$
order by 3,4


--SELECT * 
--FROM PortFolioProject..CovidVaccination$
--order by 3,4

SELECT location,date, total_cases, new_cases, total_deaths, population 
FROM PortFolioProject..CovidDeath$
order by 1,2

--Looking at Total cases vs Total Deaths
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM PortFolioProject..CovidDeath$
WHERE location like '%ndia'
order by 1,2

--looking at total cases vs population
-- percentage of popultion got covid
SELECT location,date, total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortFolioProject..CovidDeath$
WHERE location like '%ndia'
order by 1,2

--looking at countries with Highest Infection Rate compared to population

SELECT location, MAX(total_cases) as maxtotalcase,population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortFolioProject..CovidDeath$
--WHERE location like '%ndia'
GROUP BY location,population
order by PercentPopulationInfected DESC

--showing countries death count per population
SELECT TOP 10000 location,MAX(cast(total_deaths as int)) as DEATHCOUNT
FROM PortFolioProject..CovidDeath$
WHERE continent is not null
GROUP BY location
ORDER BY DEATHCOUNT DESC

--death count by continent
SELECT TOP 10 continent, MAX(cast(total_deaths as int)) as DEATHCOUNT
FROM PortFolioProject..CovidDeath$
where continent is not null
GROUP BY continent
ORDER BY DEATHCOUNT desc

--correction of above query

SELECT TOP 100 location, MAX(cast(total_deaths as int)) as DEATHCOUNT
FROM PortFolioProject..CovidDeath$
where continent is null
GROUP BY location
ORDER BY DEATHCOUNT desc

--GLOBAL NUMBERS
SELECT TOP 1000 date,SUM(new_cases) as SumNewCases,SUM(cast(new_deaths as int)) as SumNewDeaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as deathpernewcases --total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortFolioProject..CovidDeath$
WHERE continent is not null
GROUP by date
order by 1,2


SELECT TOP 1000 SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage --total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortFolioProject..CovidDeath$
WHERE continent is not null
--GROUP by date
order by 1,2


--Looking at Total Population  vs Vaccinations
select TOP 10000 dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations
from PortFolioProject..CovidVaccination$ vac
Join PortFolioProject..CovidDeath$  dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null and dea.location like '%ndia'
order by 1,3


select TOP 10000 dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int))
OVER (PARTITION BY dea.location Order by dea.location,dea.date) as CumulativeVac-- (CumulativeVac/population)*100
from PortFolioProject..CovidVaccination$ vac
Join PortFolioProject..CovidDeath$  dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
order by 1,3


--USE CTE

With PopvsVac(Location, Continent, Date, Population, New_Vaccinations, CumulativeVac)
as
(
select TOP 10000 dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int))
OVER (PARTITION BY dea.location Order by dea.location,dea.date) as CumulativeVac-- (CumulativeVac/population)*100
from PortFolioProject..CovidVaccination$ vac
Join PortFolioProject..CovidDeath$  dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
order by 1,3
)
Select *, (CumulativeVac/Population)*100 as CaseIncreasePercentage
FROM PopvsVac


--Temp Table
Create Table PercentPopulationVaccinated
(
Location nvarchar(255),
Continent nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
CumulativeVac numeric
)
Insert into PercentPopulationVaccinated
select TOP 10000 dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int))
OVER (PARTITION BY dea.location Order by dea.location,dea.date) as CumulativeVac-- (CumulativeVac/population)*100
from PortFolioProject..CovidVaccination$ vac
Join PortFolioProject..CovidDeath$  dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
order by 1,3

Select *, (CumulativeVac/Population)*100 as CaseIncreasePercentage
FROM PercentPopulationVaccinated

Drop Table if exists PercentPopulationVaccinated



--Create view to store data for later visualizaton

GO

CREATE VIEW PercentPopulationVaccinated as
select TOP 10000 dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int))
OVER (PARTITION BY dea.location Order by dea.location,dea.date) as CumulativeVac-- (CumulativeVac/population)*100
from PortFolioProject..CovidVaccination$ vac
Join PortFolioProject..CovidDeath$  dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
--order by 1,3


