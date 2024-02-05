Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4


-- Looking at Total Cases vs. Total Deaths
-- Shows the likelyhood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1, 2


--Looking at the total cases vs. population
-- Shows percentage of population that got covid

Select location, date, total_cases, population, (total_cases/population)*100 as covid_percentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2



-- Looking at countries with highest infection rate compared to population
Select location, population, max((total_cases/population)*100) as covid_percentage
From PortfolioProject..CovidDeaths
Group by location, population
order by 3 DESC


--Let's break things down by continent

Select continent, MAX(cast(total_deaths as Int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by HighestDeathCount DESC


-- Showing the continent with the highest death count per population

Select continent, MAX(cast(total_deaths as Int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by HighestDeathCount DESC


--Global Numbers

Select date,SUM(new_cases) as total_cases, SUM (cast(new_deaths as int)) as total_deaths, SUM (cast(new_deaths as int))/sum(new_cases)*100 as covid_percentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1, 2

--Look at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, 
dea.date) as rolling_people_vaccinated, --rolling_people_vaccinated/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3


-- Use CTE
With PopvsVAC (Continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, 
dea.date) as rolling_people_vaccinated
--, rolling_people_vaccinated/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
SELECT *, (rolling_people_vaccinated/population)*100
From PopvsVAC


-- TEMP TABLE

DROP TABLE  if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, 
dea.date) as rolling_people_vaccinated
--, rolling_people_vaccinated/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2, 3

SELECT *, (rolling_people_vaccinated/population)*100
From #PercentagePopulationVaccinated





-- Creating View to store data for later vizualization

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, 
dea.date) as rolling_people_vaccinated
--, rolling_people_vaccinated/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

Select *
From PercentagePopulationVaccinated