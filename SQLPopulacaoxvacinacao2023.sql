--Probabilidade de morte por covid até o final de abril de 2021

Select location, date, total_cases, total_deaths, new_cases, (total_deaths/total_cases)*100 as 'Mortality %'
FROM PortfolioProject..CovidDeaths
where location like 'Brazil'
order by 1,2

--Frequencia de casos comparado com a população

Select location, date, total_cases, population, new_cases, (total_cases/population)*100 as 'Cases by Pop'
FROM PortfolioProject..CovidDeaths
where location like 'Brazil'
order by 1,2

--Países com maiores taxas de infecção

Select location, MAX(total_cases) as Highestinfectioncount, population, max(total_cases/population)*100 as CasesbyPop
FROM PortfolioProject..CovidDeaths
group by location, population
order by CasesbyPop desc

--Países com maiores taxas de morte

Select location, MAX(total_cases) as Highestinfectioncount, MAX(cast(total_deaths as int)) as HighestDeathCount, population, max(total_deaths/population)*100 as DeathsbyPop
FROM PortfolioProject..CovidDeaths
Where continent is not Null
group by location, population
order by HighestDeathCount desc

-- Por continente

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is Null
group by location
order by TotalDeathCount desc

-- Casos mundiais por dia
Select date, SUM(new_cases) as TotalCaseCount, SUM(cast(new_deaths as int)) as TotalDeathCount, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPerc
FROM PortfolioProject..CovidDeaths
Where continent is not Null
group by date 
order by 1,2

-- Casos mundiais geral
Select SUM(new_cases) as TotalCaseCount, SUM(cast(new_deaths as int)) as TotalDeathCount, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPerc
FROM PortfolioProject..CovidDeaths
Where continent is not Null
--group by date 
order by 1,2

-- Vacinas x População

Select dea.continent, dea.location, dea.date, dea.population, dea.new_cases, vac.new_vaccinations, SUM(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as TotalVaccinated
From dbo.CovidDeaths as dea
Join dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not Null
where dea.location like 'Brazil'
--group by date 
order by 1,2,3

-- Total de vacinados

Select dea.continent, dea.location, dea.date, dea.population, dea.new_cases, vac.new_vaccinations, SUM(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as TotalVaccinated, (TotalVaccinated/dea.population)
From dbo.CovidDeaths as dea
Join dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not Null
where dea.location like 'Brazil'
--group by date 
order by 1,2,3

-- CTE para proximos calculos
With PopvsVacs (Continent, location, date, population, new_cases, new_vaccinations, TotalVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, dea.new_cases, vac.new_vaccinations, SUM(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as TotalVaccinated
From dbo.CovidDeaths as dea
Join dbo.CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not Null
where dea.location like 'Brazil'
--group by date 
--order by 1,2,3
)

Select *, (TotalVaccinated/Population)*100 as PercVacc
From PopvsVacs

--Criando Views para adicionar ao Tableau

Create View PercentagePopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, dea.new_cases, dea.new_vaccinations, SUM(convert (int, dea.new_vaccinations)) over (partition by dea.location order by dea.date) as TotalVaccinated
From dbo.CovidDeaths as dea
Where dea.continent is not Null
--where dea.location like 'Brazil'
--group by date 
--order by 1,2,3
