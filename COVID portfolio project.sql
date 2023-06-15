select*
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select*
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total case vs total death
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
where continent is not null
order by 1,2

--looking at total cases vs population

select location, date, population,total_cases,(total_cases/population)*100 as infectedpopulationpercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population,max(total_cases) as highestinfection,max((total_cases/population))*100 as
 infectedpopulationpercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location,population
order by infectedpopulationpercentage desc

--showing countries with highest death count per population

select location,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by totaldeathcount desc

--break things by continent

select continent,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by totaldeathcount desc

--showing continents with highest death count per population

select continent,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by totaldeathcount desc

--global numbers

select  sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/
sum(new_cases)*100 deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccination
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as
rollingpeoplevaccinated--(rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
order by 2,3

--use CTE

with popvsvac(contient,population,location,date,new_vaccinations, rollingpeoplevaccinated)
as 
(
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
)
select*,(rollingpeoplevaccinated/population)*100
from popvsvac


--temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
mew_vaccination numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
-- where dea.continent is not null

 select*,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data for later visualizations

create view percentpopulationsvaccinateds as
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
