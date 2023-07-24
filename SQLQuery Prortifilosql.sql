
SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
order by location,date

--SELECT * 
--FROM PortfolioProject.dbo.CovidVaccinations
--order by location,date

--Task one -- select/filter data that we are to be using  

SELECT location,date,total_cases,new_cases, total_deaths, population 
FROM PortfolioProject.dbo.CovidDeaths
order by location,date

--Task two -- looking at Total cases vs Total Deaths on the table
     --change the nvarchar datat types to operan used in divion
  -- Alter the table and change the data type of the columns
--ALTER TABLE PortfolioProject.dbo.CovidDeaths
--ALTER COLUMN total_cases FLOAT;
--ALTER TABLE PortfolioProject.dbo.CovidDeaths
--ALTER COLUMN total_deaths FLOAT;
--look at total_cases vs total_deaths
SELECT location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
order by location,date

--Task 3: look at total_cases vs populations
--Shows what percentage of population are got covid
SELECT location,date,total_cases, population, (total_deaths/population)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
order by location,date

--Task 4: look at the countries with heighest infection rate compared to thier population

SELECT location,population,MAX(total_cases) AS HighestInfectionRate,  MAX((total_deaths/population))*100 as PercentagePopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
Group by location,population
order by PercentagePopulationInfected desc

--Task 5: showing countries with heighest death count per population
SELECT location,MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc
--Task 5.1 : showing countries with heighest death count per population
-- breaking by continent
SELECT continent,MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

 --Task 6: showing continent with highest death per population
SELECT SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths / NULLIF(population, 0)) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2
--Task 7: implenting join to 
--look at the Total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT (float, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
 as PeopleVaccinated -- (PeopleVaccinated/population)*100 as 
 FROM PortfolioProject.dbo.CovidDeaths dea
 join PortfolioProject.dbo.CovidsVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 WHERE dea.continent IS NOT NULL
order by 2,3
--Last Task: Use CTE
with PopvsVac(Continent,location,date,population,New_Vaccinations, PeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT (float, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
 as PeopleVaccinated -- (PeopleVaccinated/population)*100 as 
 FROM PortfolioProject.dbo.CovidDeaths dea
 join PortfolioProject.dbo.CovidsVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 WHERE dea.continent IS NOT NULL
--order by 2,3
)
select * , (PeopleVaccinated/population)*100 
FROM PopvsVac

---Create View to store data for visualization
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT (float, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
   as PeopleVaccinated -- (PeopleVaccinated/population)*100 as 
 FROM PortfolioProject.dbo.CovidDeaths dea
 join PortfolioProject.dbo.CovidsVaccinations vac
    on dea.location=vac.location
    and dea.date=vac.date
 WHERE dea.continent IS NOT NULL
 -- order by 2,3

 select * 
 FROM PercentPopulationVaccinated