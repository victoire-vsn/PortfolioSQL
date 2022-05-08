-- PROJETSQL 1 - Données Covid

-- Pourcentage de mort du Covid sur le nombre de cas recensés en France

SELECT location, date, (total_deaths/total_cases)*100 AS Percentage_deathCovid FROM CovidDeaths
WHERE location = 'France' AND continent IS NOT NULL
-- Je ne prends pas en compte les "location" qui n'ont pas de continent associé car cela crée une redondance et fausse les chiffres
ORDER BY location, date;

-- Nombre de cas Covid recensés en France par rapport à la population globale du pays

SELECT location, date, (total_cases/population)*100 AS Percentage_Covid_cases FROM CovidDeaths
WHERE location = 'France' AND continent IS NOT NULL
ORDER location, date;

-- Pays avec le taux de contamination le plus élevé

SELECT location, population, MAX(cast(total_cases as numeric)) AS Highest_Infection_Rate, MAX(cast(total_cases as numeric)/population)*100 AS Infection_Rate_Population FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Infection_Rate_Population desc;

-- Pays avec le nombre de mort du Covid le plus élevé

SELECT location, population, MAX(cast(total_deaths as numeric)) AS Total_deathCovid FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Total_deathCovid desc;

-- Continents avec le nombre de mort du Covid par population le plus élevé

SELECT continent, MAX(cast(total_deaths as numeric)) AS Total_deathCovid FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_deathCovid desc;

-- Evolution quotidienne de la pandémie de Covid

SELECT date, SUM(cast(new_deaths as numeric)) AS Total_deaths, SUM(cast(new_cases as numeric)) AS Total_cases, SUM(cast(new_deaths as numeric))/SUM(cast(new_cases as numeric)) AS Percentage_deathCovid
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY Percentage_deathCovid desc;

-- Nombre de cas de Covid, de mort et le pourcentage associé à travers le monde

SELECT SUM(cast(new_deaths as numeric)) AS Total_deaths, SUM(cast(new_cases as numeric)) AS Total_cases, SUM(cast(new_deaths as numeric))/SUM(cast(new_cases as numeric)) AS Percentage_deathCovid
WHERE continent IS NOT NULL
ORDER BY Percentage_deathCovid desc;

-- Option1 : Nombre de personnes vaccinées à travers le monde

SELECT dea.continent, dea.location, dea.date, dea.population, MAX(cast(vac.total_vaccinations as numeric)) AS Total_Vaccination FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY dea.continent, dea.location, dea.date;

-- Option 2 : Nombre de personnes vaccinées à travers le monde

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(cast(vac.total_vaccinations as numeric)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Accumulation_vaccination,
(Accumulation_vaccination/dea.population)*100 AS Percentage_vaccinated_population FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.continent, dea.location;

-- Création d'une table temporaire pour calculer le pourcentage de la population vaccinée par pays

DROP TABLE IF EXISTS #Accumulation_vaccination
CREATE TABLE #Accumulation_vaccination 
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_vaccinations numeric,
Accumulation_vaccination numeric,
)
INSERT INTO #Accumulation_vaccination
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(cast(vac.total_vaccinations as numeric)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Accumulation_vaccination FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location=vac.location AND dea.date=vac.date;

SELECT (Accumulation_vaccination/dea.population)*100 AS Percentage_vaccinated_population FROM #Accumulation_vaccination;

-- Création d'une vue pour visualiser les données dans un outil de data viz

CREATE VIEW Accumulation_vaccination AS
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(cast(vac.total_vaccinations as numeric)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Accumulation_vaccination FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL;

-- PROJETSQL2 - Tableau Données Covid

-- Evolution globale de la pandémie de Covid

SELECT SUM(cast(new_deaths as numeric)) AS Total_deaths, SUM(cast(new_cases as numeric)) AS Total_cases, SUM(cast(new_deaths as numeric))/SUM(cast(new_cases as numeric))*100 AS Percentage_deathCovid FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY Percentage_deathCovid desc;

-- Nombre de dèces du Covid par continent

SELECT location, SUM(cast(new_deaths as numeric)) AS Total_deathcountCovid FROM CovidDeaths
WHERE continent IS NULL AND location NOT IN ('World','European Union','International','Upper middle income','High income','Lower middle income','Low income')
GROUP BY location
ORDER BY Total_deathcountCovid desc;

-- Taux de contamination par pays

SELECT location, population, MAX(cast(total_cases as numeric)) AS Highest_Infection_Rate, (MAX(cast(total_cases as numeric))/population)*100 AS Infection_Rate_Population FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Infection_Rate_Population desc;

-- Evolution du taux de contamination par pays

SELECT location, population, date, MAX(cast(total_cases as numeric)) AS Highest_Infection_Rate, (MAX(cast(total_cases as numeric))/population)*100 AS Infection_Rate_Population FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY Infection_Rate_Population desc;