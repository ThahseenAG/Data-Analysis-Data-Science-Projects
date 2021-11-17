/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select *
FROM [Protfolio Project]..Covid_Deaths
order by 3,4


--select *
--FROM [Protfolio Project]..Covide_Vaccinations
--order by 3,4

--Extratcting Data Required for Analysis
Select Location, date , total_cases , new_cases, total_deaths, population
FROM [Protfolio Project]..Covid_Deaths
order by 1,2

----Total cases vs Total Deaths in a Country
--Likelyhood of death if contracted with Covid in each country
Select Location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 as DeathRatio
FROM [Protfolio Project]..Covid_Deaths
order by 1,2
--Total cases vs Total Deaths in India
Select Location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 as DeathRatio
FROM [Protfolio Project]..Covid_Deaths
where location like 'India'
order by 1,2
--Total cases vs Total Deaths in Unites States
Select Location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 as DeathRatio
FROM [Protfolio Project]..Covid_Deaths
where location = 'United States'
order by 1,2

--Total cases vs Population in a Country
--Percentage of Popualtion Infected with Covid
Select Location, date , total_cases, population,  (total_cases/population)*100 as CasebyPopulation
FROM [Protfolio Project]..Covid_Deaths
order by 1,2
--Total cases vs Population in India
Select Location, date , total_cases, population,  (total_cases/population)*100 as CasebyPopulation
FROM [Protfolio Project]..Covid_Deaths
where location like 'India'
order by 1,2

--Countries with Highest Infection rate compared to Population
Select Location , Max(total_cases) as HighestInfectionCount, population,  Max((total_cases/population))*100 as CasebyPopulation
FROM [Protfolio Project]..Covid_Deaths
group by Location, population
order by CasebyPopulation desc

--Countries with highest death rate by population
select Location, max(cast(total_deaths as int)) as TotalDeathCount
FROM [Protfolio Project]..Covid_Deaths
where continent is not null
group by location
order by TotalDeathCount desc

--Continents with highest death rate by population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM [Protfolio Project]..Covid_Deaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Total Death rate in the World
select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathRatio
FROM [Protfolio Project]..Covid_Deaths
where continent is not null
order by 1,2

-- Joining 2 Tables of Covid Death and Covid Vaccination  on death and location
select *
from [Protfolio Project]..Covid_Deaths deaths
Join [Protfolio Project]..Covide_Vaccinations vaccinations
	on deaths.location = vaccinations.location and deaths.date = vaccinations.date

--Total World Vaccination rate
select deaths.continent,deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
from [Protfolio Project]..Covid_Deaths deaths
Join [Protfolio Project]..Covide_Vaccinations vaccinations
	on deaths.location = vaccinations.location and deaths.date = vaccinations.date
where deaths.continent is not null
order by 1,2,3

--Calculating the total number of vaccination of country on a given day
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	sum(convert(bigint,vaccinations.new_vaccinations)) OVER (Partition by deaths.Location order by deaths.location,deaths.date) TotalVaccinations
from [Protfolio Project]..Covid_Deaths deaths
Join [Protfolio Project]..Covide_Vaccinations vaccinations
	on deaths.location = vaccinations.location and deaths.date = vaccinations.date
where deaths.continent is not null
order by 2,3

--Ratio of People Vaccinated to Population

--Using CTE
WITH VaccinationVsPopulation (continent, location,date,population,new_vaccinations,TotalVaccinations)
as
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	sum(convert(bigint,vaccinations.new_vaccinations)) OVER (Partition by deaths.Location order by deaths.location,deaths.date) TotalVaccinations
from [Protfolio Project]..Covid_Deaths deaths
Join [Protfolio Project]..Covide_Vaccinations vaccinations
	on deaths.location = vaccinations.location and deaths.date = vaccinations.date
where deaths.continent is not null
)
select * , (TotalVaccinations/population)*100 as VaccinationRate
from VaccinationVsPopulation

--Country with Maximum Vaccination Rate
--using Temp Table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccination numeric,
	TotalVaccinations numeric
)

Insert into #PercentPopulationVaccinated
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	sum(convert(bigint,vaccinations.new_vaccinations)) OVER (Partition by deaths.Location order by deaths.location,deaths.date) TotalVaccinations
from [Protfolio Project]..Covid_Deaths deaths
Join [Protfolio Project]..Covide_Vaccinations vaccinations
	on deaths.location = vaccinations.location and deaths.date = vaccinations.date
where deaths.continent is not null

--Country with maximum vaccination count
select location,MAX(TotalVaccinations) as Total
FROM #PercentPopulationVaccinated
group by location
order by 2 desc


--Countries with max Vaccination rate compared to population
select location, (MAX(TotalVaccinations/population))*100 as Total
FROM #PercentPopulationVaccinated
group by location
order by 2 desc

--Creating View for Visualizations

Create View PercentPopulationVaccinated as
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	sum(convert(bigint,vaccinations.new_vaccinations)) OVER (Partition by deaths.Location order by deaths.location,deaths.date) TotalVaccinations
from [Protfolio Project]..Covid_Deaths deaths
Join [Protfolio Project]..Covide_Vaccinations vaccinations
	on deaths.location = vaccinations.location and deaths.date = vaccinations.date
where deaths.continent is not null



