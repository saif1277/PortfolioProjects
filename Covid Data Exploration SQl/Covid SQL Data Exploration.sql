SELECT *
FROM covid_deaths
LIMIT 100;

SELECT *
FROM covid_vaccinations
LIMIT 10;

-- 1. Total Cases vs Total Deaths
-- Shows you the likelihood of dying if you contract covid in your country
WITH tc_vs_td (location, date, total_cases, total_deaths, death_percentage)
AS
(
SELECT location, date, total_cases, total_deaths,
(CAST(total_deaths AS FLOAT)/total_cases)*100 AS death_percentage
FROM covid_deaths
-- Removes continents from locations column
WHERE Continent IS NOT NULL
)
SELECT * 
FROM tc_vs_td;

-- 2. Total Cases vs Population
-- shows the percentage of the population who contracted covid per country
WITH tc_vs_pop (location, date, total_cases, population, covid_population_percentage)
AS
(
SELECT location, date, total_cases, population,
(CAST(total_cases AS FLOAT)/population)*100 AS covid_population_percentage
FROM covid_deaths
WHERE Continent IS NOT NULL
)
SELECT *
FROM tc_vs_pop;

-- 3.Looking at countries with the highest infection rates by location & population
WITH countries_infection_rates (location, population, highest_infection_count, percentage_population_infected)
AS
(
SELECT location, population, MAX(total_cases) AS highest_infection_count, 
MAX((CAST(total_cases AS FLOAT)/population))*100 AS percentage_population_infected
FROM covid_deaths
WHERE Continent IS NOT NULL
GROUP BY location, population
ORDER BY percentage_population_infected DESC
)
SELECT *
FROM countries_infection_rates;

-- 4. Showing countries with the highest death count per population
WITH death_count_per_pop (location, max_deaths, population, death_percentage)
AS
(
SELECT location, MAX(total_deaths) AS max_deaths, population, 
((CAST(MAX(total_deaths) AS FLOAT)/population)*100) AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NUll
GROUP BY location, population
ORDER BY max_deaths DESC
)
SELECT *
FROM death_count_per_pop;

-- 5. showing continents with the highest death count
WITH highest_death_by_continent (continent, max_deaths)
AS
(
SELECT continent, MAX(total_deaths) AS max_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY max_deaths DESC
)
SELECT *
FROM highest_death_by_continent;

-- 6. Global numbers
WITH global_number (date, new_cases_sum, new_deaths_sum, death_percentage)
AS
(
SELECT date, SUM(new_cases) AS new_cases_sum, SUM(new_deaths) AS new_deaths_sum, 
(CAST(SUM(new_deaths)AS FLOAT)/SUM(new_cases)*100) AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date ASC
)
SELECT *
FROM global_number;

-- Joining covid_deaths wit covid_vaccinations template
SELECT *
FROM covid_deaths AS cd
JOIN covid_vaccinations AS vc
ON cd.location = vc.location
AND cd.date = vc.date;

-- 7. Looking at total population vs vaccinations

-- USE CTE
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vac)
AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, vc.new_vaccinations, SUM(vc.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vac
FROM covid_deaths AS cd
JOIN covid_vaccinations AS vc
ON cd.location = vc.location
AND cd.date = vc.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (rolling_people_vac/population)*100 AS percentage_people_vac
FROM pop_vs_vac;
