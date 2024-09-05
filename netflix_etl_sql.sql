-- Uso de la base de datos
USE netflix_titles_release;

-- Eliminación y creación de la tabla principal
DROP TABLE IF EXISTS netflix_titles;
CREATE TABLE netflix_titles (
    show_id VARCHAR(255),
    type VARCHAR(255),
    title VARCHAR(255),
    director VARCHAR(255),
    cast TEXT,
    country VARCHAR(255),
    date_added DATE,  
    release_year INT,
    rating VARCHAR(255),
    duration VARCHAR(255),
    listed_in TEXT,
    description TEXT
);

-- Eliminación y creación de la tabla temporal
DROP TABLE IF EXISTS netflix_titles_temp;
CREATE TABLE netflix_titles_temp (
    show_id VARCHAR(255),
    type VARCHAR(255),
    title VARCHAR(255),
    director VARCHAR(255),
    cast TEXT,
    country VARCHAR(255),
    date_added VARCHAR(255),  -- Temporalmente como VARCHAR
    release_year INT,
    rating VARCHAR(255),
    duration VARCHAR(255),
    listed_in TEXT,
    description TEXT
);

-- Carga de datos en la tabla temporal
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 9.0\\Uploads\\netflix_limpio.csv' 
INTO TABLE netflix_titles_temp 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- Inserción de datos en la tabla principal convirtiendo date_added a DATE
INSERT INTO netflix_titles (show_id, type, title, director, cast, country, date_added, release_year, rating, duration, listed_in, description)
SELECT show_id, type, title, director, cast, country, 
    CASE 
        WHEN date_added != '' THEN STR_TO_DATE(date_added, '%M %d, %Y')
        ELSE NULL
    END,
    release_year, rating, duration, listed_in, description
FROM netflix_titles_temp;

-- Eliminación de la tabla temporal si ya no se necesita
DROP TABLE netflix_titles_temp;

-- Visualización de la estructura de la tabla
DESCRIBE netflix_titles;

-- Muestreo de datos
SELECT * FROM netflix_titles LIMIT 15;

-- Búsqueda y reemplazo de valores vacíos con NULL
SET SQL_SAFE_UPDATES = 0;
UPDATE netflix_titles SET director = NULL WHERE director = '';
UPDATE netflix_titles SET cast = NULL WHERE cast = '';
UPDATE netflix_titles SET country = NULL WHERE country = '';
-- Búsqueda y reemplazo de valores vacíos en 'date_added'
UPDATE netflix_titles 
SET date_added = NULL 
WHERE date_added IS NULL;

UPDATE netflix_titles SET rating = NULL WHERE rating = '';
UPDATE netflix_titles SET duration = NULL WHERE duration = '';

-- Eliminación de filas con valores nulos en la columna 'country'
DELETE FROM netflix_titles WHERE country IS NULL;

-- Tratamiento de datos anidados en 'country'
DROP TEMPORARY TABLE IF EXISTS country_split;
CREATE TEMPORARY TABLE country_split (
    country VARCHAR(255)
);

INSERT INTO country_split (country)
SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', numbers.n), ',', -1)) AS country
FROM netflix_titles
JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
    UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
) numbers ON CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) >= numbers.n - 1;

-- Consulta para obtener los 10 países con más títulos en Netflix
SELECT country, COUNT(*) AS count
FROM country_split
GROUP BY country
ORDER BY count DESC
LIMIT 10;

-- Tratamiento de datos anidados en 'listed_in' (géneros)
DROP TEMPORARY TABLE IF EXISTS genre_split;
CREATE TEMPORARY TABLE genre_split (
    genre VARCHAR(255)
);

INSERT INTO genre_split (genre)
SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) AS genre
FROM netflix_titles
JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
) numbers ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= numbers.n - 1;

-- Consulta para obtener los géneros más populares en Netflix
SELECT genre, COUNT(*) AS count
FROM genre_split
GROUP BY genre
ORDER BY count DESC;

-- Eliminación de filas con valores nulos en la columna 'date_added'
DELETE FROM netflix_titles WHERE date_added IS NULL;

-- Consulta para obtener la cantidad de títulos lanzados por año en Netflix
SELECT 
    release_year AS year_add,
    COUNT(*) AS title_count
FROM netflix_titles
GROUP BY year_add
ORDER BY year_add;






