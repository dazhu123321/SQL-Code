Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Let's break things down by continent
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--showing continntents with the highest death count per population 

--Global numbers
Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases) *100 as DeathPercentageEvery
From CovidDeaths cd
Where continent is not null and new_cases <> 0
--Group by location
--Order by 4 asc

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(bigint,vac.new_vaccinations)) Over(Partition by dea.Location) --Order by dea.location,dea.date)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3 

--Use CTE
With PopvsVac(Continent,Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(bigint,vac.new_vaccinations)) Over(Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)

Select *, RollingPeopleVaccinated/(Population)*100
From PopvsVac
--Where Location = 'Afghanistan'
Order by 1,2,3




--Use TempTable
Drop Table if exists #PercentPopulationVaccincated 
Create Table #PercentPopulationVaccincated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccincated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(bigint,vac.new_vaccinations)) Over(Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 1,2,3


Select *, RollingPeopleVaccinated/(population)*100
From #PercentPopulationVaccincated

--Creating Viwe to store data for later visluation
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(bigint,vac.new_vaccinations)) Over(Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated