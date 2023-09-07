--Select location, date, total_cases, new_cases, total_deaths, population
--from CovidDeaths
--where continent is not null
--order by 1,2

--Total Cases vs Total Deaths
----Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
----from CovidDeaths
----where location = 'Nigeria' and continent is not null
----order by 1,2

--Total Cases vs Population
--Select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
--from CovidDeaths
----where location = 'Nigeria' and continent is not null
--order by 1,2 

--Highest Infection Rate compared to Population

--Select location, population, max(total_cases) HighestInfectionCount, max(total_cases/population)*100 as PercentofPopulationInfected
--from CovidDeaths
--where continent is not null
--group by location, population
--order by PercentofPopulationInfected DESC

--Countries with highest death count per population

--Select location, max(cast(total_deaths as int)) as TotalDeathCount
--from CovidDeaths
--where continent is not null
--group by location
--order by TotalDeathCount desc

--By Continent
--Continents with the highest death count per population

--Select continent, max(cast(total_deaths as int)) as TotalDeathCount
--from CovidDeaths
--where continent is not null
--group by continent
--order by TotalDeathCount desc

--Global Numbers
--Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))* 100 as DeathPercentage
--from CovidDeaths
--where continent is not null
----group by date
--order by 1,2

--select death.continent, 
--		death.location, 
--		death.date, death.population, 
--		Vac.new_vaccinations,
--		sum(convert(int, vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as RollingVaccinatedPeople
--from CovidDeaths as death
--join CovidVaccinations as Vac
--	on death.location=Vac.location
--	and death.date=Vac.date
--	where death.continent is not null
--order by 2,3

--USE CTE

--With PopvsVac (continent, location, date, population, new_vaccinations, rollingVaccinatedPeople) as 
--(
--select death.continent, 
--		death.location, 
--		death.date, death.population, 
--		Vac.new_vaccinations,
--		sum(convert(int, vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as RollingVaccinatedPeople
--from CovidDeaths as death
--join CovidVaccinations as Vac
--	on death.location=Vac.location
--	and death.date=Vac.date
--	where death.continent is not null
----order by 2,3
--)
--select *, (rollingVaccinatedPeople/population)*100
--from PopvsVac

--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinatedPeople numeric
)


Insert into #PercentPopulationVaccinated
select death.continent, 
		death.location, 
		death.date, death.population, 
		Vac.new_vaccinations,
		sum(convert(int, vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as RollingVaccinatedPeople
from CovidDeaths as death
join CovidVaccinations as Vac
	on death.location=Vac.location
	and death.date=Vac.date
	where death.continent is not null
order by 2,3

select *, (RollingVaccinatedPeople/Population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated AS 
select death.continent, 
		death.location, 
		death.date, death.population, 
		Vac.new_vaccinations,
		sum(convert(int, vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as RollingVaccinatedPeople
from CovidDeaths as death
join CovidVaccinations as Vac
	on death.location=Vac.location
	and death.date=Vac.date
	where death.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated