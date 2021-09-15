-- Looking at the data

select *
from PortfolioProject..CovidDeaths
order by 3,4



-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2



-- Looking at total cases vs total deaths in India
-- Death rate of covid-19

select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2



-- Looking at Toal cases vs Population in India
-- Shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as infection_percentage
from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2



-- Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as positive_percentage
from PortfolioProject..CovidDeaths
group by location, population
order by 4 desc



-- Showing countries with highest death count vs population

select location, population, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 3 desc



-- CONTINENT NUMBERS

-- Highest death count by Continent

select continent, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc



-- GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2



-- Global death percentage

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



-- Vaccination
-- Looking at total vacconation vs total population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3



-- Using CTE

with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select * , (rolling_people_vaccinated/population)*100
from PopvsVac



-- Using Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccination numeric,
	Rolling_people_vaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (Rolling_People_Vaccinated/population)*100
from #PercentPopulationVaccinated



-- Creating view to store data for visualization later

create view DeathRate as
select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location = 'India'
--order by 1,2


create view InfectionRate as
select location, date, population, total_cases, (total_cases/population)*100 as infection_percentage
from PortfolioProject..CovidDeaths
where location = 'India'
--order by 1,2


create view CountryInfectionRate as
select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as positive_percentage
from PortfolioProject..CovidDeaths
group by location, population
--order by 4 desc


create view CountryDeathCount as
select location, population, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
--order by 3 desc


create view ContinentDeathCount as
select continent, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
--order by 2 desc


create view GlobalDeathPercentage as
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
--order by 1,2


create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
