select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select the data that we are going to use

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1;

--Total cases vs Total deaths
--chnaces of dying if you contract with covid-19 in your country


select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as percen_of_total_deaths_per_total_cases
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2;

--Total cases vs population
--chances of getting infection in your country

select location,date,population,total_cases,(total_cases/population)*100 as percent_of_infection_per_population
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--looking at countries with highest infection compared to its size of population

select location,population,MAX(total_cases) as total_count_of_infection,MAX((total_cases/population))*100 as percent_of_infection
from PortfolioProject..CovidDeaths
where location like '%india%'
group by location,population
--order by percent_of_infection desc;



--countries with highest death count per size of its population

select location,MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by total_death_count desc;

--breaking things by continent

--showing continents with highest death counts

select continent,MAX(CAST(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by total_death_count desc;

--global numbers


select sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as percent_of_fatality
--total_cases,total_deaths,(total_deaths/total_cases)*100 as percen_of_total_deaths_per_total_cases
from PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
--group by date
order by 1;

---total poplulation vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date) as total_vaccinations_count
--,(total_vaccinations_counts/dea.population)*100 --this will run into error  so we use cte
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
      --and dea.location like '%india%'
order by 2,3;

--using cte

with popVSvac 
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date) as total_vaccinations_count
--,(total_vaccinations_counts/dea.population)*100 --this will run into error  so we use cte
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *,
(total_vaccinations_count/population)*100 as percent_of_vaccinations_per_population
from popVSvac
--where location like '%india%'
order by 2,3;


--Temp table

drop table if exists #percentpopulationvaccinated

create table #percentpopulationvaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_vaccinations_count numeric
)


insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date) as total_vaccinations_count
--,(total_vaccinations_counts/dea.population)*100 --this will run into error  so we use cte
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select  *,
(total_vaccinations_count/population)*100 as percent_of_vaccinations_per_population
from #percentpopulationvaccinated
where Location like '%india%'

--ceating view to store data for later visualization

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date) as total_vaccinations_count
--,(total_vaccinations_counts/dea.population)*100 --this will run into error  so we use cte
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



select *
from percentpopulationvaccinated;
