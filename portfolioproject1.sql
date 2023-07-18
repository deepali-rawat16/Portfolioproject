select * 
from portfolioproject..covid_deaths
where continent is not null
order by 3,4

--select  data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population 
from portfolioproject..covid_deaths
where continent is not null
order by 1,2

--looking at totalcases vs total deaths
--shows likelihood of dying if you could contract in your country
SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS FLOAT) / total_cases AS death_ratio
FROM portfolioproject..covid_deaths
where location like '%india%'
and continent is not null
order by 1,2
--looking at total cases vs population
SELECT location, date, population,total_cases, (total_cases  / population)*100 AS infected_percentage
FROM portfolioproject..covid_deaths
--where location like '%india%'
where continent is not null
order by 1,2


--looking at countries with higher infection rate
SELECT location, population,max(total_cases) as highestinfection, max((total_cases/population))*100 AS highestinfectedcount
FROM portfolioproject..covid_deaths
--where location like '%india%'
where continent is not null
group by location,population
order by highestinfectedcount desc

--showing the countries with highest deathcount per population
SELECT location, MAX(cast(total_deaths as int)) as highestdeathcount 
FROM portfolioproject..covid_deaths
--where location like '%india%'
where continent is not null
group by location
order by highestdeathcount desc

--Let's break things down by continent

SELECT location, MAX(cast(total_deaths as int)) as highestdeathcount 
FROM portfolioproject..covid_deaths
--where location like '%india%'
where continent is null
group by location
order by highestdeathcount desc

SELECT continent, MAX(cast(total_deaths as int)) as highestdeathcount 
FROM portfolioproject..covid_deaths
--where location like '%india%'
where continent is  null
group by continent
order by highestdeathcount desc



--showing the continent with highest death count per population

SELECT continent,population, MAX(cast(total_deaths as int)) as highestdeathcount,MAX(cast(total_deaths as int))/population as deathcountperpopulation
FROM portfolioproject..covid_deaths
--where location like '%india%'
where continent is not null
group by continent,population
order by highestdeathcount desc

--Global Numbers

SELECT date, SUM(new_cases), SUM(new_deaths), (SUM(new_deaths) / SUM(new_cases))*100 AS death_ratio
FROM portfolioproject..covid_deaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2

SELECT
  SUM(new_cases) as total_cases,
  SUM(new_deaths) as total_deaths,
  CASE
    WHEN SUM(new_cases)  IS NULL OR SUM(new_deaths) IS NULL OR SUM(new_cases) = 0 THEN NULL
    ELSE SUM(new_deaths) / SUM(new_cases)
  END AS death_ratio

FROM
  portfolioproject..covid_deaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2

select * 
from portfolioproject..covid_deaths dea
join portfolioproject..covidvaccination vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2


--looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location Order by dea.location
 ,dea.date) as Rollingpeoplevaccinated
from portfolioproject..covid_deaths dea
join portfolioproject..covidvaccination vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2


--use CTE
with popvsvac(continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location Order by dea.location
,dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from portfolioproject..covid_deaths dea
join portfolioproject..covidvaccination vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2
)
select *,(Rollingpeoplevaccinated/population)*100
from popvsvac





--Temp table
DROP table if exists #percentpopulation 
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)


insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location Order by dea.location
,dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from portfolioproject..covid_deaths dea
join portfolioproject..covidvaccination vac
	on dea.location =vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2
select *,(Rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--creating view to store data for later data visualisation
create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location Order by dea.location
,dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from portfolioproject..covid_deaths dea
join portfolioproject..covidvaccination vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2


select * 
from percentpopulationvaccinated