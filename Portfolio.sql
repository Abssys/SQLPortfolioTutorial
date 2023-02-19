
Select *
FROM Portfolio..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--FROM Portfolio..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..CovidDeaths
Where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of Dying if you contract COVID in your Country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio..CovidDeaths
WHERE location like '%Philippines%'
and continent is not null
order by 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of the population got COVID

Select Location, date, Population, total_cases,  (total_cases/population)*100 as CasesPercentage
FROM Portfolio..CovidDeaths
WHERE location like '%States%'
and continent is not null
order by 1,2

--Looking at Countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentaOfPopulationInfected
FROM Portfolio..CovidDeaths
Group by Location, population
order by PercentaOfPopulationInfected desc

--Looking at Countries with highest death count compared to population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Let's Break things down by Continent

--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM Portfolio..CovidDeaths
--Where continent is null
--Group by location
--order by TotalDeathCount desc



--Showing continents with the highest death counts

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100  as DeathPercentage
FROM Portfolio..CovidDeaths
--WHERE location like '%Philippines%'
WHERE continent is not null
--Group by date
order by 1,2

--Looking at total population vs Vaccination

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
--USE CTE
Select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac


-- TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population) * 100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

Select *
FROM PercentPopulationVaccinated