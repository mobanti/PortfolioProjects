SELECT *
From covid-project-123.Covid.Deaths
Where continent is not null
order by 3,4

-- Select*
-- From covid-project-123.Covid.Vaccinations
-- order by 3,4


-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, Population;
FROM covid-project-123.Covid.Deaths
order by 1,2

-- Looking at Total Cases vs Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From covid-project-123.Covid.Deaths
Where location = 'Canada'
order by 1,2 desc

-- Looking at Total Cases vs Population
-- Shows what percentage of population have gotten covid
Select Location, date, Population,total_cases,  (total_cases/Population) * 100 as InfectionRate
From covid-project-123.Covid.Deaths
Where location = 'Canada'
order by 1,2 desc

-- Looking at Countries with Highest Infection Rate Compared to Populations
Select Location, Population,MAX(total_cases) as HighestInfectionCount, (MAX(total_cases/Population)) * 100 as HighestInfectionRate
From covid-project-123.Covid.Deaths
Group by Location, Population
-- Where location = 'Canada'
order by 4 desc

-- Countries with Highest Death Count per Population
Select Location, Population,MAX(total_deaths) as TotalDeaths, (MAX(total_deaths/Population)) * 100 as HighestDeathRate
From covid-project-123.Covid.Deaths
Where continent is not null
Group by Location, Population
order by 3 desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Continent with Highest Death Count
Select continent, sum(new_deaths)
From covid-project-123.Covid.Deaths
Group by continent

-- Global Numbers by Day
Select date, SUM(new_cases)as TotalCases,
    sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases) * 100 as DeathPercent
From covid-project-123.Covid.Deaths
where continent is not null
Group by date
Order by 1 desc


-- Global Numbers Total
Select SUM(new_cases)as TotalCases,
    sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases) * 100 as DeathPercent
From covid-project-123.Covid.Deaths
where continent is not null
Order by 1 desc

-- Joining our two tables
Select *
From covid-project-123.Covid.Deaths as dea
Join covid-project-123.Covid.Vaccinations as vac
    ON dea.location = vac.location
    AND dea.date = vac.date


-- Total Population vs Vaccinations
Select *, RollingNewVaccinations/population * 100 as VaccinationRate
FROM(
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(vac.new_vaccinations)
        OVER (Partition by dea.location order by dea.location, dea.date) as RollingNewVaccinations
    From covid-project-123.Covid.Deaths as dea
    Join covid-project-123.Covid.Vaccinations as vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    Where dea.continent is not null
    order by 2,3
)


-- Creating View to Store Data for Later Visualizations

create View covid-project-123.Covid.PercentPopulationVaccinated as
Select *, RollingNewVaccinations/population * 100 as VaccinationRate
FROM(
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(vac.new_vaccinations)
        OVER (Partition by dea.location order by dea.location, dea.date) as RollingNewVaccinations
    From covid-project-123.Covid.Deaths as dea
    Join covid-project-123.Covid.Vaccinations as vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    Where dea.continent is not null
)
