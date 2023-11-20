-- Checking Each Table
use movies;

-- Analyzing Number of Rows & Columns
select * from actor;                         -- 1238 rows & 7 columns
select * from certificate;                   -- 7 rows & 2 columns
select * from country;                       -- 203 rows & 2 columns
select * from director;                      -- 487 rows & 7 columns
select * from film;                          -- 1199 rows & 15 columns
select * from genre;                         -- 24 rows & 2 columns
select * from language;                      -- 15 rows & 2 columns                
select * from role;                          -- 4 columns
select * from studio;                        -- 262 rows & 2 columns


-- Analyzing Each table
DESCRIBE actor;               -- Primary Key ActorID (columns - ActorID FirstName FamilyName FullName DoB DoD Gender)
DESCRIBE certificate;         -- Primary Key CertificateID (columns - CertificateID Certificate)
DESCRIBE country;             -- Primary Key CountryID (columns - CountryID Country)
DESCRIBE director;            -- Primary Key DirectorID (columns - DirectorID FirstName FamilyName FullName DoB DoD Gender)
DESCRIBE film;                -- Primary Key FilmID (columns - FilmID Title ReleaseDate DirectorID StudioID Review CountryID LanguageID GenreID RunTimeMinutes CertificateID BudgetDollars BoxOfficeDollars OscarNominations OscarWins)
DESCRIBE genre;               -- Primary Key GenreID (columns - GenreID Genre)
DESCRIBE language;            -- Primary Key LanguageID (columns - LanguageID Language)
DESCRIBE role;                -- Primary Key RoleID (columns - RoleID Role FilmID ActorID)
DESCRIBE studio;              -- Primary Key StudioID (columns - StudioID Studio)


-- Updating the FullName column by concatenating FirstName and FamilyName
-- Using the COALESCE function to handle null values in FirstName
SET SQL_SAFE_UPDATES = 0;

UPDATE actor
SET FullName = CONCAT(COALESCE(FirstName, ''), ' ', FamilyName);

UPDATE director
SET FullName = CONCAT(COALESCE(FirstName, ''), ' ', FamilyName);


-- Dropping Some Unnecessary Columns
ALTER TABLE actor
DROP COLUMN DoD;

ALTER TABLE director
DROP COLUMN DoD;


## Data Analysis
# 1) total number of movies in the database
SELECT COUNT(*) AS TotalMovies                        -- 1199 movies
FROM film;

# 2) average runtime of movies
SELECT Round(AVG(RunTimeMinutes)) AS AverageRuntime         -- 120 minutes
FROM film;

# 3) total box office earnings for all movies
SELECT Round(SUM(BoxOfficeDollars) / 1000000000, 2) AS TotalEarningsInBillions      -- 253.49 Billions
FROM film;

# 4) Year wise Movies Count
SELECT YEAR(ReleaseDate) AS ReleaseYear, COUNT(*) AS MovieCount
FROM film
GROUP BY ReleaseYear
ORDER BY MovieCount DESC;

# 5) Year with the Most Movie Releases
SELECT YEAR(ReleaseDate) AS ReleaseYear, COUNT(*) AS MovieCount
FROM film
GROUP BY ReleaseYear
ORDER BY MovieCount DESC
LIMIT 1;

# 6) Director-wise Movie Count
SELECT d.DirectorID, d.FullName AS DirectorName, COUNT(*) AS MovieCount
FROM director d
JOIN film f ON d.DirectorID = f.DirectorID
GROUP BY DirectorID, DirectorName
ORDER BY MovieCount DESC;

# 7) Director with the Most Movies
SELECT d.DirectorID, d.FullName AS DirectorName, COUNT(*) AS MovieCount
FROM director d
JOIN film f ON d.DirectorID = f.DirectorID
GROUP BY DirectorID, DirectorName
ORDER BY MovieCount DESC
LIMIT 1;

# 8) Genre wise Movies
SELECT g.Genre, COUNT(*) AS MovieCount
FROM genre g
JOIN film f ON g.GenreID = f.GenreID
GROUP BY Genre
ORDER BY MovieCount DESC;

# 9) Genre with the Most Movies
SELECT g.Genre, COUNT(*) AS MovieCount
FROM genre g
JOIN film f ON g.GenreID = f.GenreID
GROUP BY Genre
ORDER BY MovieCount DESC
LIMIT 1;

# 10) Studios with the Highest Budget Movies
SELECT s.StudioID, s.Studio, COUNT(*) AS HighBudgetMovieCount
FROM studio s
JOIN film f ON s.StudioID = f.StudioID
WHERE f.BudgetDollars > (SELECT AVG(BudgetDollars) FROM film)
GROUP BY StudioID, Studio
ORDER BY HighBudgetMovieCount DESC;

# 11) Movies with Highest Box Office Earnings
SELECT Title, BoxOfficeDollars
FROM film
ORDER BY BoxOfficeDollars DESC
LIMIT 10;

# 12) Directors with Longest Average Movie Runtimes
SELECT d.DirectorID, d.FullName AS DirectorName, AVG(f.RunTimeMinutes) AS AvgMovieRuntime
FROM director d
JOIN film f ON d.DirectorID = f.DirectorID
GROUP BY DirectorID, DirectorName
ORDER BY AvgMovieRuntime DESC
LIMIT 5;

# 13) Display the list of hit films which won oscars also
Select
Title,BoxOfficeDollars,BudgetDollars,OscarWins
from movies.film 
where BoxofficeDollars > BudgetDollars and OscarWins > 0 ;

# 14) Display the list of films which is second part of that movie series
Select
Title
from movies.film 
Where Title like '% 2%' or (Title like '% II%' and Title not like '% III%') ;

# 15) Display as classic blockbuster if boxofficedollars more than 1e9 and oscarwins more than zero,else others
Select
Title
,BoxofficeDollars
,OscarWins
,If(BoxofficeDollars > 1e9 and OscarWins >0,'Classic Blockbuster','Others') as MovieType
from movies.film ;

# 16) Display Short Film if RunTimeMinutes less than 100,Avg Length Film if RunTimeMinutes 100-160,else Long Film
SELECT
  Title,
  RunTimeMinutes,
  CASE
    WHEN RunTimeMinutes < 100 THEN 'Short Film'
    WHEN RunTimeMinutes >= 100 AND RunTimeMinutes < 160 THEN 'Avg Length Film'
    ELSE 'Long Film'
  END AS MovieType
FROM movies.film;


# 17) Display Old Actor if actor dob before 1970,middle aged actor if actor dob 1970-1990,else young actor
SELECT
  CONCAT(FirstName, ' ', FamilyName) AS FullName,
  Dob,
  CASE
    WHEN Dob < '1970-01-01' THEN 'Old Actor'
    WHEN Dob >= '1970-01-01' AND Dob < '1990-01-01' THEN 'Middle Aged Actor'
    ELSE 'Young Actor'
  END AS ActorType
FROM movies.actor;

# 18) Sort by highest to lowest oscars and then by Boxoffice Dollars in desc
SELECT
  Title,
  BoxofficeDollars,
  OscarWins
FROM movies.film
ORDER BY OscarWins DESC, BoxofficeDollars DESC;

# 19) Film Statistics Overview
SELECT
  Count(*) AS Number_of_Films,
  Count(BoxofficeDollars) AS CountBO,
  Count(CASE WHEN BoxofficeDollars > BudgetDollars THEN 1 END) AS Hits,
  Count(CASE WHEN BoxofficeDollars < BudgetDollars THEN 1 END) AS Flops,
  Count(CASE WHEN BoxofficeDollars IS NULL OR BudgetDollars IS NULL THEN 1 END) AS CountNulls,
  Count(CASE WHEN OscarWins > 0 THEN 1 END) AS CountOscars,
  Avg(BoxofficeDollars) AS AvgBO,
  Max(BoxofficeDollars) AS MaxBO,
  Sum(OscarWins) AS TotalOscars,
  Count(OscarWins) AS Countall
FROM Movies.Film;

# 20) Display Director Name ,Total Oscars won by Director,Avg Boxoffice of his movies
Select
FullName
,Sum(OscarWins) as TotalOscars
,Avg(BoxOfficeDollars) as AvgBO
from movies.film f inner join movies.Director d on f.DirectorId = d.DirectorId
Group by FullName;

# 21) Display Avg runtime of each genre films ,Sort by highest avg to lowest avg
Select
Genre
,Avg(RunTimeMinutes) as AvgRunTime
from movies.film f inner join movies.Genre g on f.GenreId = g.GenreId
Group by Genre 
Order by AvgRunTime desc;

# 22) Which Director and Studio combination has more number of films together
select FullName as Director, Studio, count(*) As Number_of_Films
from movies.film f
join movies.Director D on f.DirectorID = D.DirectorID
join movies.Studio s on f.StudioId = S.StudioID
group by Director, Studio
Order by Number_of_Films Desc;

# 23) Which Director is more versatile (he should have done movies on different genres)
#      Director ,count of different genres he has directed
Select 
FullName
,Count(Distinct g.GenreId) as GenreCount
,Group_concat(Distinct Genre) as GenreList
from movies.film f inner join movies.Director d on f.DirectorId = d.DirectorId
inner join movies.Genre g on f.GenreId = g.GenreId
Group by FullName
Order by GenreCount desc;

# 24) Display 3 longest runtime films in every genre
with DRRTM as 
(
Select
Genre
,Title
,Runtimeminutes
,Row_number() over (Partition by Genre order by Runtimeminutes desc) as Rw
from movies.film f inner join movies.genre g
on f.genreID = g.GenreID
)
Select * from DRRTM Where Rw <=3;

# 25) Film_Statistics_Overview_View
CREATE VIEW FilmStatisticsOverview AS
SELECT
  'Number of Films' AS Number_of_Films,
  'Count BO' AS CountBO,
  'Hits' AS Hits,
  'Flops' AS Flops,
  'Count Nulls' AS CountNulls,
  'Count Oscars' AS CountOscars,
  'Average Box Office' AS AvgBO,
  'Max Box Office' AS MaxBO,
  'Total Oscars' AS TotalOscars,
  'Count Oscars All' AS Countall
UNION
SELECT
  Count(*) AS Number_of_Films,
  Count(BoxofficeDollars) AS CountBO,
  Count(CASE WHEN BoxofficeDollars > BudgetDollars THEN 1 END) AS Hits,
  Count(CASE WHEN BoxofficeDollars < BudgetDollars THEN 1 END) AS Flops,
  Count(CASE WHEN BoxofficeDollars IS NULL OR BudgetDollars IS NULL THEN 1 END) AS CountNulls,
  Count(CASE WHEN OscarWins > 0 THEN 1 END) AS CountOscars,
  AVG(BoxofficeDollars) AS AvgBO,
  MAX(BoxofficeDollars) AS MaxBO,
  SUM(OscarWins) AS TotalOscars,
  Count(OscarWins) AS Countall
FROM Movies.Film;

SELECT * FROM FilmStatisticsOverview;

