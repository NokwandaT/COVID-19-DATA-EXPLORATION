select *
from PortfolioProject1..CovidDeaths
where continent is  not null
order by 3,4

--select *
--from PortfolioProject1..CovidVaccinations
--order by 3,4

--select data we are going to be using 

select Location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject1..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying during different peaks of the virus 

select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where Location like '%africa%'
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid 
select Location, date, total_cases, population, (cast(total_deaths as float)/population)*100 as InfectionPercentage
from PortfolioProject1..CovidDeaths
where Location like '%africa%'
order by 1,2


--Looking at countries with highest infection rate compared to population

select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(((cast(total_cases as float)/population)))*100 as PercentagePopulationInfected
from PortfolioProject1..CovidDeaths
where continent is not null
group by location, population
--where Location like '%africa%'
order by PercentagePopulationInfected desc

--Showing Countries with Highest Death Count per Population

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is not null
group by location
--where Location like '%africa%'
order by TotalDeathCount desc

--Showing by Continent with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is null And location not like '%income%'
group by location
order by TotalDeathCount desc

-- Comparing death count according to economic classification

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is null And location like '%income%'
group by location
order by TotalDeathCount desc


--Global Numbers 

select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Death,
    case 
	  when SUM(new_cases)=0
	    then null 
		   else 
		      SUM(cast(new_deaths as int))/SUM(new_cases) *100
	end as DeathPercentage
from PortfolioProject1..CovidDeaths
where continent is not null
group by date 
order by 1,2

--Looking at total population vs vaccination


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
   dea.Date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3

--TEMP TABLE

drop table if exists #PercentPopuationVccinated
create Table #PercentPopuationVccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_vaccination bigint,
RollingPeopleVaccinated bigint
)

insert into #PercentPopuationVccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
   dea.Date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/Population)*100
from #PercentPopuationVccinated


--Creating view to store data visualizations later

Create view PercentPopuationVccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
   dea.Date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
