select * from [Portfolio Project]..CovidDeaths
order by 3,4


select * from [Portfolio Project]..CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
where continent is not null and continent <> ''
order by 1,2

-- Looking at total_cases vs total_deaths

select location, date, total_cases, total_deaths, 
cast(total_deaths as float)/nullif(cast(total_cases as float), 0)*100 as death_percentage
from [Portfolio Project]..CovidDeaths
where continent is not null and continent <> ''
order by 1,2

-- Shows likelyhood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, 
cast(total_deaths as float)/nullif(cast(total_cases as float), 0)*100 as death_percentage
from [Portfolio Project]..CovidDeaths
where location like '%States%' and continent is not null and continent <> ''
order by 1,2


-- Looking at the total cases vs population

select location, date, population, total_cases,
cast(total_cases as float)/nullif(cast(population as float), 0)*100 as infected_percentage
from [Portfolio Project]..CovidDeaths
where location like '%States%' and continent is not null and continent <> ''
order by 1,2

-- Looking at countries at countries with the highest infection rate vs population

select location, population, max(total_cases) as HighestInfectionCount,
max(cast(total_cases as float)/nullif(cast(population as float), 0))*100 as percentpopulationinfected
from [Portfolio Project]..CovidDeaths
where continent is not null and continent <> ''
group by location, population
order by percentpopulationinfected desc


-- Showing the countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
group by location
order by TotalDeathCount desc

-- with the above when we run the code, we get the output grouped by continents too. Which is not requried
-- to remove that error, first in the dataset there are few columns where continents are mentioned in 
-- countries leaving the continent column null for few records.

select * from [Portfolio Project]..CovidDeaths
where continent is not null and continent <> ''
order by 3,4

-- As we use this file for visualization purposes or for any future work, we add continent is not null to all 
-- the queries.

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null and continent <> ''
group by location
order by TotalDeathCount desc

-- Looking the death count continent wise

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null and continent <> ''
group by continent
order by TotalDeathCount desc

-- Showing the continents with highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null and continent <> ''
group by continent
order by TotalDeathCount desc


-- Global Numbers

select sum(cast(new_cases as int)) as NC, sum(cast(new_deaths as int)) as ND,
sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2 

-- Looking at the total poplation vs vaccinations

select * 
from [Portfolio Project]..CovidDeaths deaths
join [Portfolio Project]..CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date


select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
from [Portfolio Project]..CovidDeaths deaths
join [Portfolio Project]..CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date


select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
from [Portfolio Project]..CovidDeaths deaths
join [Portfolio Project]..CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null
order by 2,3


select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by deaths.location)
from [Portfolio Project]..CovidDeaths deaths
join [Portfolio Project]..CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null
order by 2,3


with PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as 
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by deaths.location order by 
deaths.location, deaths.date) as rollingpeoplevaccinated 
from [Portfolio Project]..CovidDeaths deaths
join [Portfolio Project]..CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null
--order by 2,3
)
select *
from PopvsVac

-- Temp Table

drop table if exists #PercentPopulationVaccination
create table #PercentPopulationVaccination
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccination
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by deaths.location order by 
deaths.location, deaths.date) as rollingpeoplevaccinated 
from [Portfolio Project]..CovidDeaths deaths
join [Portfolio Project]..CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date
--where deaths.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population) * 100
from #PercentPopulationVaccination


