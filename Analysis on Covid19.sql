SELECT * 
FROM dbo.CovidDeaths
WHERE continent is not NULL

--SELECT * 
--FROM dbo.CovidVaccinations

-- Selecting the appropriate data for use
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	population
FROM dbo.CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2

-- calculating the total cases vs total deaths 
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)* 100 AS deathpercentage
FROM dbo.CovidDeaths
WHERE location = 'United States' AND continent is not NULL
ORDER BY 1, 2

--looking at total cases vs population
SELECT
	location,
	date,
	total_cases,
	population,
	(total_cases/population)* 100 AS deathpercentage
FROM dbo.CovidDeaths
WHERE location = 'kenya' AND continent is not NULL
ORDER BY 1, 2

-- Looking at continents with highest population affected
SELECT
    continent,
    MAX(total_cases) AS highestinfectioncount,
    MAX(total_cases * 1.0 / population) * 100 AS percentage_population_affected
FROM dbo.CovidDeaths
GROUP BY continent
ORDER BY percentage_population_affected DESC;

--Showing the continents with highest death count
SELECT
    continent,
    MAX(CAST(total_deaths AS int)) AS total_death_count
FROM dbo.CovidDeaths
--WHERE location = 'kenya'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

--BREAKING HINGS DOWNBY CONTNENTS

-- Showin the continents with the highest death counts per population
SELECT
    continent,
    MAX(CAST(total_deaths AS int)) AS total_death_count
FROM dbo.CovidDeaths
--WHERE location = 'kenya'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;


--GLOBAL NUMBERS

SELECT
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    (SUM(CAST(new_deaths AS INT)) * 1.0 / SUM(new_cases)) * 100 AS death_percentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY total_cases, total_deaths;


	-- Looking at total population vs vaccination
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cumulative_vaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;


--USING COMMON TABLE EXPRESSION
WITH popvsvac (cotnent, location, Date, Population, New_vaccinations, cumulative_vaccinations)
AS
(
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cumulative_vaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY dea.location, dea.date;
)

SELECT*, (cumulative_vaccinations/population)* 100
FROM 
	popvsvac


-- TEMP TABLE 
DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    New_Vaccinations NUMERIC,
    cumulative_vaccinations NUMERIC  -- Specify data type here
);

INSERT INTO #percentpopulationvaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS cumulative_vaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *,
       (cumulative_vaccinations / population) * 100 AS percent_population_vaccinated
FROM #percentpopulationvaccinated;

-- Optional: Drop the temporary table after use
DROP TABLE #percentpopulationvaccinated;



--Creating view to store data for later visualization
CREATE VIEW percentpopulationvaccinated AS 
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cumulative_vaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY dea.location, dea.date;


--
SELECT * 
FROM percentpopulationvaccinated