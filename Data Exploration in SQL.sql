select *
from [portfolio project].dbo.CovidDeaths$
order by 3,4

--select *
--from [portfolio project].dbo.['covid vaccinations$']
--order by 3,4

--selcting data we are going to use and ordering 

select location,date,total_cases,new_cases,total_deaths,population
from [portfolio project].dbo.CovidDeaths$
order by 1,3

--looking at total cases vs total deaths and finding the death percentage

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from [portfolio project].dbo.CovidDeaths$
where location = 'india'
order by 1,3  

--looking at the total cases vs population
--shows the percentage of people affected by covid

select location,date,total_cases,population,(total_cases/population)*100 as affected_percentage
from [portfolio project].dbo.CovidDeaths$
where location = 'india'

--countries with high infection rate compared to population

select location,max(total_cases) as highest_infection_count,population,max((total_cases/population))*100 as affected_percentage
from [portfolio project].dbo.CovidDeaths$
group by location,population
order by affected_percentage desc

--countries with high death rate 

select location,max(total_deaths) as highest_death_count,population,max((total_deaths/population))*100 as death_percentage
from [portfolio project].dbo.CovidDeaths$
group by location,population
order by death_percentage desc

--countires with high death count

select location,max(cast(total_deaths as int)) as highest_death_count
from [portfolio project].dbo.CovidDeaths$
where continent is not null
group by location
order by highest_death_count desc

--let's break things down by continent but used location to get proper data
--total death cases by continent

select location,max(cast(total_deaths as int)) as death_count
from [portfolio project].dbo.CovidDeaths$
where continent is null
group by location
order by death_count desc

--things by continent

select continent,max(cast(total_deaths as int)) as death_count
from [portfolio project].dbo.CovidDeaths$
where continent is not null
group by continent
order by death_count desc 

--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathpercentage
from [portfolio project].dbo.CovidDeaths$
where continent is not null
order by deathpercentage desc

--looking at total population vs vaccination

select death.location,max(death.population) as total_population,max(vaccination.people_vaccinated ) as total_vaccinated,(max(vaccination.people_vaccinated)/max(death.population))*100 as people_vaccinated_fully
from [portfolio project].dbo.CovidDeaths$ as death
join [portfolio project].dbo.CovidVaccinations$ as vaccination
     on death.location=vaccination.location
	 and death.date=vaccination.date
group by death.location
order by people_vaccinated_fully desc

--Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project]..CovidDeaths$ dea
Join [portfolio project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--use CTE

WITH populationvsvaccination (continent, location, date, population,new_vaccinations, Rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project]..CovidDeaths$ dea
Join [portfolio project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *,(Rollingpeoplevaccinated/population)*100 as percentage
from populationvsvaccination

--using temptable

drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingpeopleVaccinated numeric
)
insert into #percentagepopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project]..CovidDeaths$ dea
Join [portfolio project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *,(Rollingpeoplevaccinated/population)*100 as percentage
from #percentagepopulationvaccinated


--creating view to store data for later visualizations

create view percentagepopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project]..CovidDeaths$ dea
Join [portfolio project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select*
from percentagepopulationvaccinated 