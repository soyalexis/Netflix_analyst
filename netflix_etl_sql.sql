-- CREATE DATABASE IF NOT EXISTS netflix;
USE netflix;

DROP TABLE IF EXISTS netflix;
CREATE TABLE IF NOT EXISTS netflix (
    show_id VARCHAR(255),
    type VARCHAR(255),
    title VARCHAR(255),
    director VARCHAR(255),
    cast TEXT,
    country VARCHAR(255),
    date_added VARCHAR(255),
    release_year INT,
    rating VARCHAR(255),
    duration VARCHAR(255),
    listed_in TEXT,
    description TEXT
);

-- cargamos los datos
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 9.0\\Uploads\\netflix_limpio.csv'
INTO TABLE netflix
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- vemos la estructura
DESCRIBE netflix;

-- muestreo
SELECT * FROM netflix LIMIT 15;

-- buscamos valores vacíos y los reemplazamos con NULL
SET SQL_SAFE_UPDATES = 0;
UPDATE netflix SET director = NULL WHERE director = '';
UPDATE netflix SET cast = NULL WHERE cast = '';
UPDATE netflix SET country = NULL WHERE country = '';
UPDATE netflix SET date_added = NULL WHERE date_added = '';
UPDATE netflix SET rating = NULL WHERE rating = '';
UPDATE netflix SET duration = NULL WHERE duration = '';

-- contamos y quitamos las filas con valores nulos en la columna 'country'
DELETE FROM netflix WHERE country IS NULL;

-- tratamos los datos aninados en country que vimos en el muestreo
DROP TEMPORARY TABLE IF EXISTS country_split;
CREATE TEMPORARY TABLE country_split (
    country VARCHAR(255)
);

INSERT INTO country_split (country)
SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', numbers.n), ',', -1)) AS country
FROM netflix
JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
    UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
) numbers ON CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) >= numbers.n - 1;

-- Completar con la consulta adecuada para obtener los 10 países con más títulos en Netflix
SELECT country, COUNT(*) AS count
FROM country_split
GROUP BY country
ORDER BY count DESC
LIMIT 10;

-- Completar con la consulta adecuada para obtener los géneros más populares en Netflix

-- creamos y cargamos la tabla temporal genre_split
DROP TEMPORARY TABLE IF EXISTS genre_split;
CREATE TEMPORARY TABLE genre_split (
    genre VARCHAR(255)
);

INSERT INTO genre_split (genre)
-- con SUBSTRING_INDEX divimos el texto usando (,) y con TRIM quitamos espacios al principio y al final
SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) AS genre
FROM netflix
JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
) numbers ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= numbers.n - 1;

--  generos mas populares
SELECT genre, COUNT(*) AS count
FROM genre_split
GROUP BY genre
ORDER BY count DESC;

-- Completar con la consulta adecuada para obtener la cantidad de títulos lanzados por año en Netflix

-- quitamos las filas con valores nulos en la columna date_added
DELETE FROM netflix
WHERE date_added IS NULL;
-- sacamos la cantidad de titulos lanzados por año
SELECT 
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year_add,
    COUNT(*) AS title_count
FROM netflix
GROUP BY year_add
ORDER BY year_add;


--
--
-- tabla temporal para mejorar el grafico de generos mas populares

-- DROP TEMPORARY TABLE IF EXISTS genre_split;

-- CREATE TEMPORARY TABLE genre_split (
--     year_add INT,
--     genre VARCHAR(255)
-- );

-- INSERT INTO genre_split (year_add, genre)
-- SELECT 
--     YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year_add,
--     TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) AS genre
-- FROM netflix
-- JOIN (
--     SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
--     UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
-- ) numbers ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= numbers.n - 1
-- WHERE date_added IS NOT NULL;

-- creamos una tabla temporal para los generos mas populares pero por año
-- DROP TEMPORARY TABLE IF EXISTS popular_genres_by_year;

-- CREATE TEMPORARY TABLE popular_genres_by_year AS
-- SELECT 
--     year_add,
--     genre,
--     COUNT(*) AS genre_count
-- FROM genre_split
-- GROUP BY year_add, genre
-- ORDER BY year_add, genre_count DESC;

-- SELECT * FROM popular_genres_by_year;





