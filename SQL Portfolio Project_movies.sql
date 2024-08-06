-- Segment 1:


-- Total number of rows in each table of the schema

SELECT COUNT(*) AS number_of_rows FROM director_mapping;

-- number_of_rows: 3867

SELECT COUNT(*) AS number_of_rows FROM genre;

-- number_of_rows: 14662 

SELECT COUNT(*) AS number_of_rows FROM movie;

-- number_of_rows: 7997

SELECT COUNT(*) AS number_of_rows FROM names;

-- number_of_rows: 25735

SELECT COUNT(*) AS number_of_rows FROM ratings;

-- number_of_rows: 7997

SELECT COUNT(*) AS number_of_rows FROM role_mapping;

-- number_of_rows: 15615

-----------------------------------------------------------------------------------------------------------------------------------------------------

-- Columns with null values in Movies Table

SELECT
(SELECT count(*) FROM movie WHERE id is NULL) as id_nulls,
(SELECT count(*) FROM movie WHERE title is NULL) as title_nulls,
(SELECT count(*) FROM movie WHERE year is NULL) as year_nulls,
(SELECT count(*) FROM movie WHERE date_published is NULL) as date_published_nulls,
(SELECT count(*) FROM movie WHERE duration is NULL) as duration_nulls,
(SELECT count(*) FROM movie WHERE country is NULL) as country_nulls,
(SELECT count(*) FROM movie WHERE worlwide_gross_income is NULL) as worlwide_gross_income_nulls, 
(SELECT count(*) FROM movie WHERE languages is NULL) as languages_nulls,
(SELECT count(*) FROM movie WHERE production_company is NULL) as production_company_nulls;

-- four columns of the movie table has null values, the columns country,worlwide_gross_income,languages,production_company contain NULL values

--------------------------------------------------------------------------------------------------------------------------------------------------------
 
-- Total number of movies released each year. How does the trend look month wise?

SELECT year, COUNT(id) AS number_of_movies
FROM movie
GROUP BY year;

-- highest no. of movies were released in 2017 with 3052 

SELECT MONTH(date_published) AS month_num, COUNT(id) AS number_of_movies
FROM movie
GROUP BY MONTH(date_published)
ORDER BY MONTH(date_published);

-- March has highest and December has least no. of films released

------------------------------------------------------------------------------------------------------------------------------------------
  
-- No. of movies produced in the USA or India in the year 2019

SELECT year, Count(DISTINCT id) AS number_of_movies
FROM movie
WHERE ( upper(country) LIKE '%INDIA%'
         OR upper(country) LIKE '%USA%' )
AND year = 2019;

-- No. of movies produced in 2019 by USA or INDIA is 1059

------------------------------------------------------------------------------------------------------------------------------------------

-- Unique list of the genres present in the data set

SELECT DISTINCT genre
FROM genre
ORDER BY genre;

-----------------------------------------------------------------------------------------------------------------------------------------

-- Genre with the highest number of movies produced overall

SELECT g.genre, COUNT(m.id) AS number_of_movies 
FROM movie m
JOIN genre g
ON m.id = g.movie_id
GROUP BY g.genre
ORDER BY number_of_movies DESC;

-- Genre Drama has the highest no. of movies with 4285

SELECT genre, year, COUNT(movie_id) AS number_of_movies
FROM genre AS g
INNER JOIN movie AS m
ON g.movie_id = m.id
WHERE year = 2019
GROUP BY genre
ORDER BY number_of_movies DESC
LIMIT 1;

-- in 2019 Genre Drama has the highest no. of movies with 1078

----------------------------------------------------------------------------------------------------------------------------------------

-- How many movies belong to only one genre?

WITH genre_count 
AS (
	SELECT movie_id, COUNT(genre) AS count_of_genre
	FROM genre 
    GROUP BY movie_id
)
SELECT COUNT(movie_id) AS no_of_movies_with_one_genre 
FROM genre_count 
WHERE count_of_genre = 1;

-- 3289 movies have exactly one genre.

---------------------------------------------------------------------------------------------------------------------------------------

-- What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

SELECT g.genre, ROUND(AVG(m.duration), 0) AS avg_duration
FROM movie m
JOIN genre g
ON m.id = g.movie_id
GROUP BY g.genre
ORDER BY avg_duration DESC;

----------------------------------------------------------------------------------------------------------------------------------------

-- Rank of the genre ‘thriller’ of movies among all the genres in terms of number of movies produced 

SELECT genre, COUNT(movie_id) AS movie_count, RANK()
OVER (ORDER BY COUNT(movie_id) DESC) AS genre_rank
FROM genre
GROUP BY genre
ORDER BY movie_count DESC;


WITH genre_rank AS
(
	SELECT genre, COUNT(movie_id) AS movie_count,
			RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS genre_rank
	FROM genre
	GROUP BY genre
)
SELECT *
FROM genre_rank
WHERE genre='thriller';


-- Thriller genre has 3rd rank with 1484 movies

---------------------------------------------------------------------------------------------------------------------------------------

-- Segment 2:


-- Minimum and Maximum values in  each column of the ratings table except the movie_id column

SELECT 
MIN(avg_rating) AS min_avg_rating,
MAX(avg_rating) AS max_avg_rating, 
MIN(total_votes) AS min_total_votes,
MAX(total_votes) AS max_total_votes,
MIN(median_rating) AS min_median_rating,
MAX(median_rating) AS max_median_rating
FROM ratings;

--------------------------------------------------------------------------------------------------------------------------------------    

-- Top 10 movies based on average rating

SELECT m.title, r.avg_rating, 
		DENSE_RANK() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM movie m
JOIN ratings r
ON m.id = r.movie_id
LIMIT 10;

--------------------------------------------------------------------------------------------------------------------------------------

-- Summarise the ratings table based on the movie counts by median ratings

SELECT median_rating, COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating;

-------------------------------------------------------------------------------------------------------------------------------------

-- Which production house has produced the most number of hit movies (average rating > 8)??

SELECT m.production_company, COUNT(m.id) AS movie_count, 
		DENSE_RANK() OVER(ORDER BY COUNT(r.movie_id)DESC) AS prod_company_rank
FROM movie m
JOIN ratings r
ON m.id = r.movie_id
WHERE avg_rating > 8
AND production_company IS NOT NULL
GROUP BY production_company;

-- Dream Warrior Pictures and National Theatre Live have the most number of hit movies (3 movies)

------------------------------------------------------------------------------------------------------------------------------------

-- How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

SELECT genre,
       COUNT(m.id) AS movie_count
FROM movie m
     INNER JOIN genre g
           ON g.movie_id = m.id
INNER JOIN ratings r  
           ON r.movie_id = m.id
WHERE year = 2017
      AND Month (date_published) = 3
      AND country LIKE '%USA%'
      AND total_votes > 1000
GROUP BY genre
ORDER BY movie_count DESC;

-----------------------------------------------------------------------------------------------------------------------------------

-- Movies of each genre that start with the word ‘The’ and which have an average rating > 8

SELECT m.title, r.avg_rating, g.genre
FROM movie m
JOIN genre g
ON g.movie_id = m.id
JOIN ratings r
ON r.movie_id = m.id
WHERE m.title LIKE 'The%'
AND r.avg_rating > 8
ORDER BY r.avg_rating DESC;

-----------------------------------------------------------------------------------------------------------------------------------

-- Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

SELECT r.median_rating, COUNT(m.id) AS movies_count
FROM movie m
JOIN ratings r 
ON r.movie_id = m.id
WHERE m.date_published BETWEEN '2018-04-01' AND '2019-04-01'
AND r.median_rating = 8
GROUP BY r.median_rating;

-- 361 movies have released between 1 April 2018 and 1 April 2019 with a median rating of 8

------------------------------------------------------------------------------------------------------------------------------------

-- Do German movies get more votes than Italian movies? 

-- Approach 1: By country column

SELECT m.country, SUM(r.total_votes) AS total_no_of_votes
FROM movie m
JOIN ratings r 
ON m.id = r.movie_id
WHERE m.country IN('Italy', 'Germany')
GROUP BY m.country;

-- From the output we can see that German movies have more votes than Italian movies

-- Approach 2: By language column

SELECT SUM(total_votes) AS total_votes, languages
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
WHERE languages LIKE 'German' OR languages LIKE 'Italian'
GROUP BY languages;



SELECT SUM(total_votes), languages
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
WHERE languages LIKE 'German' OR languages LIKE 'Italian'
GROUP BY languages;

-- Answer is Yes

------------------------------------------------------------------------------------------------------------------------------------
-- Segment 3:


-- Columns in the names table with null values

SELECT
  SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls,
  SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
  SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
  SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
FROM names;

-- no Null value in the column 'name'
-------------------------------------------------------------------------------------------------------------------------------------

-- Top three directors in the top three genres whose movies have an average rating > 8

WITH top_3_genres AS
(
           SELECT     genre,
                      COUNT(m.id)                            AS movie_count ,
                      RANK() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
           FROM       movie m
           JOIN genre g
           ON         g.movie_id = m.id
           JOIN ratings r
           ON         r.movie_id = m.id
           WHERE      avg_rating > 8
           GROUP BY   genre 
           LIMIT 3
)
SELECT     n.name            AS director_name ,
           COUNT(d.movie_id) AS movie_count
FROM       director_mapping d
JOIN genre g
USING     (movie_id)
JOIN names n
ON         n.id = d.name_id
JOIN top_3_genres
USING     (genre)
JOIN ratings
USING      (movie_id)
WHERE      avg_rating > 8
GROUP BY   name
ORDER BY   movie_count DESC 
LIMIT 3 ;

-----------------------------------------------------------------------------------------------------------------------------------

-- Top two actors whose movies have a median rating >= 8

SELECT DISTINCT name AS actor_name, COUNT(r.movie_id) AS movie_count
FROM ratings AS r
JOIN role_mapping AS rm
ON rm.movie_id = r.movie_id
JOIN names AS n
ON rm.name_id = n.id
WHERE median_rating >= 8 AND category = 'actor'
GROUP BY name
ORDER BY movie_count DESC
LIMIT 2;

------------------------------------------------------------------------------------------------------------------------------------

-- Top three production houses based on the number of votes received by their movies

SELECT m.production_company, 
		SUM(r.total_votes) AS vote_count, 
		RANK() OVER(ORDER BY SUM(r.total_votes)DESC) AS prod_comp_rank
FROM movie m
JOIN ratings r 
ON m.id = r.movie_id
WHERE production_company IS NOT NULL
GROUP BY production_company
LIMIT 3;

-- Marvel Studios, Twentieth Century Fox and Warner Bros. are the top producers

-------------------------------------------------------------------------------------------------------------------------------------

-- Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 


WITH top_actor
     AS (SELECT b.NAME AS actor_name,
                Sum(c.total_votes) AS total_votes,
                Count(DISTINCT a.movie_id) AS movie_count,
                Round(Sum(c.avg_rating * c.total_votes) / Sum(c.total_votes), 2) AS actor_avg_rating
         FROM   role_mapping a
                INNER JOIN names b
                        ON a.name_id = b.id
                INNER JOIN ratings c
                        ON a.movie_id = c.movie_id
                INNER JOIN movie d
                        ON a.movie_id = d.id
         WHERE  a.category = 'actor'
                AND d.country LIKE '%India%'
         GROUP  BY b.NAME
         HAVING Count(DISTINCT a.movie_id) >= 5)
SELECT *,
       Rank()
         OVER (ORDER BY actor_avg_rating DESC) AS actor_rank
FROM   top_actor; 


-- Top actor is Vijay Sethupathi

-------------------------------------------------------------------------------------------------------------------------------------

-- Top five actresses in Hindi movies released in India based on their average ratings
-- Note: The actresses should have acted in at least three Indian movies. 

WITH top_actress
     AS (SELECT b.NAME AS actress_name,
                Sum(c.total_votes) AS total_votes,
                Count(DISTINCT a.movie_id) AS movie_count,
                Round(Sum(c.avg_rating * c.total_votes) / Sum(c.total_votes), 2) AS actress_avg_rating
         FROM   role_mapping a
                INNER JOIN names b
                        ON a.name_id = b.id
                INNER JOIN ratings c
                        ON a.movie_id = c.movie_id
                INNER JOIN movie d
                        ON a.movie_id = d.id
         WHERE  a.category = 'actress'
                AND d.country LIKE '%India%'
				AND languages LIKE '%Hindi%'
         GROUP  BY b.NAME
         HAVING Count(DISTINCT a.movie_id) >= 3)
SELECT *,
       Rank()
         OVER (ORDER BY actress_avg_rating DESC) AS actress_rank
FROM   top_actress; 

-------------------------------------------------------------------------------------------------------------------------------------

/* Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies */

SELECT title,
		CASE WHEN avg_rating > 8 THEN 'Superhit movies'
			 WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
             WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
			 WHEN avg_rating < 5 THEN 'Flop movies'
		END AS avg_rating_category
FROM movie m
JOIN genre g
ON m.id = g.movie_id
JOIN ratings r
ON m.id = r.movie_id
WHERE genre='thriller';

------------------------------------------------------------------------------------------------------------------------------------

-- Segment 4:

-- Genre-wise running total and moving average of the average movie duration

SELECT genre,
		ROUND(AVG(duration),0) AS avg_duration,
        SUM(ROUND(AVG(duration),1)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
        ROUND(AVG(AVG(duration)) OVER (ORDER BY genre ROWS 10 PRECEDING),2) AS moving_avg_duration
FROM movie m 
INNER JOIN genre g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;

-----------------------------------------------------------------------------------------------------------------------------------
-- Top 5 movies of each year with top 3 genres

-- five highest-grossing movies of each year that belong to the top three genres

-- Top 3 Genres based on most number of movies

WITH top_3_genre AS
( 	
	SELECT genre, COUNT(movie_id) AS number_of_movies
    FROM genre g
    INNER JOIN movie m
    ON g.movie_id = m.id
    GROUP BY genre
    ORDER BY COUNT(movie_id) DESC
    LIMIT 3
),
top_5 AS
(
	SELECT genre,
			year,
			title AS movie_name,
            CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10)) AS worlwide_gross_income ,
			DENSE_RANK() OVER(partition BY year ORDER BY CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10)) DESC) AS movie_rank
	FROM movie m 
    INNER JOIN genre g 
    ON m.id= g.movie_id
	WHERE genre IN (SELECT genre FROM top_3_genre)
)
SELECT *
FROM top_5
WHERE movie_rank <= 5;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies

SELECT production_company,
		COUNT(m.id) AS movie_count,
        ROW_NUMBER() OVER(ORDER BY count(id) DESC) AS prod_comp_rank
FROM movie m 
JOIN ratings r 
ON m.id=r.movie_id
WHERE median_rating >= 8 
AND production_company IS NOT NULL 
AND POSITION(',' IN languages)>0
GROUP BY production_company
LIMIT 2;


-- Star Cinema and Twentieth Century Fox are the top two production houses that have produced the highest number of hits among multilingual movies

--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre

SELECT name, 
		SUM(total_votes) AS total_votes,
		COUNT(rm.movie_id) AS movie_count,
		avg_rating AS actress_avg_rating,
        DENSE_RANK() OVER(ORDER BY avg_rating DESC) AS actress_rank
FROM names AS n
INNER JOIN role_mapping AS rm
ON n.id = rm.name_id
INNER JOIN ratings AS r
ON r.movie_id = rm.movie_id
INNER JOIN genre AS g
ON r.movie_id = g.movie_id
WHERE category = 'actress' 
AND avg_rating > 8 
AND genre = 'drama'
GROUP BY name, avg_rating
LIMIT 3;

-----------------------------------------------------------------------------------------------------------------------------------------------------


/* Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations*/

WITH next_date_published_summary AS
(
           SELECT     d.name_id,
                      NAME,
                      d.movie_id,
                      duration,
                      r.avg_rating,
                      total_votes,
                      m.date_published,
                      Lead(date_published,1) OVER(partition BY d.name_id ORDER BY date_published,movie_id ) AS next_date_published
           FROM       director_mapping d
           INNER JOIN names n
           ON         n.id = d.name_id
           INNER JOIN movie m
           ON         m.id = d.movie_id
           INNER JOIN ratings r
           ON         r.movie_id = m.id ), 
top_director_summary AS
(
       SELECT *,
              Datediff(next_date_published, date_published) AS date_difference
       FROM   next_date_published_summary )
SELECT   name_id                       AS director_id,
         NAME                          AS director_name,
         Count(movie_id)               AS number_of_movies,
         Round(Avg(date_difference),0) AS avg_inter_movie_days,
         Round(Avg(avg_rating),2)      AS avg_rating,
         Sum(total_votes)              AS total_votes,
         Min(avg_rating)               AS min_rating,
         Max(avg_rating)               AS max_rating,
         Sum(duration)                 AS total_duration
FROM     top_director_summary
GROUP BY director_id
ORDER BY number_of_movies DESC, avg_rating
DESC limit 9;

