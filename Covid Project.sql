Select *
From PortfoliaProject..CovidDeaths$
order by 3,4

--Select *
--From PortfoliaProject..CovidVaccination$
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfoliaProject..CovidDeaths$
order by 1,2
-- Looking at total cases vs total deaths
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 AS DeathPercentage
FROM
    PortfoliaProject..CovidDeaths$
WHERE location like '%Canada%'
ORDER BY
    location,
    date;

	-- Looking at total cases vs population 
	-- shows what percentage of population got covid

SELECT
    location,
    date,
    total_cases,
    population,
    (CAST(total_cases AS float) / CAST(population AS float)) * 100 AS DeathPercentage
FROM
    PortfoliaProject..CovidDeaths$
--WHERE location like '%Canada%'
ORDER BY
    location,
    date;

--Looking at countries with highest infection rate compared to population

SELECT
    location,
    date,
    MAX(total_cases) as HighestInfectionCount,
    population,
    MAX((CAST(total_cases AS float) / CAST(population AS float))) * 100 AS percentpopulationinfected
FROM
    PortfoliaProject..CovidDeaths$
--WHERE location like '%Canada%'
Group by location, date, population
ORDER BY
    percentpopulationinfected desc

--Showing countries with Highest Death count per population

SELECT
    location,
    MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM
    PortfoliaProject..CovidDeaths$
--WHERE location like '%Canada%'
WHere continent is not null
Group by location
ORDER BY
    TotalDeathCount desc

--Breaking things down by continent

SELECT
    continent,
    MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM
    PortfoliaProject..CovidDeaths$
--WHERE location like '%Canada%'
WHere continent is not null
Group by continent
ORDER BY
    TotalDeathCount desc

--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
		sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
FROM
    PortfoliaProject..CovidDeaths$
where continent is not null
order by 1,2


--Joning two tables on location and date

Select *
From PortfoliaProject..CovidDeaths$ ds
Join PortfoliaProject..CovidVaccination$ vc
	on ds.location = vc.location
	and ds.date = vc.date

--Looking at total population vs vaccinations

Select ds.continent, ds.location, ds.date, ds.population, vc.new_vaccinations,
SUM(Convert(int,vc.new_vaccinations)) OVER (Partition by ds.location order by ds.location, ds.date) as Rollingpeoplevaccinated
From PortfoliaProject..CovidDeaths$ ds
Join PortfoliaProject..CovidVaccination$ vc
	on ds.location = vc.location
	and ds.date = vc.date
where ds.continent is not null
order by 2,3

--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
Newvaccinations numeric,
Rollingpeoplevaccinated numeric
)

--Creating view to store data for visualization

Create view PercentPopulationVaccinated as
Select ds.continent, ds.location, ds.date, ds.population, vc.new_vaccinations,
SUM(Convert(int,vc.new_vaccinations)) OVER (Partition by ds.location order by ds.location, ds.date) as Rollingpeoplevaccinated
From PortfoliaProject..CovidDeaths$ ds
Join PortfoliaProject..CovidVaccination$ vc
	on ds.location = vc.location
	and ds.date = vc.date
where ds.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated