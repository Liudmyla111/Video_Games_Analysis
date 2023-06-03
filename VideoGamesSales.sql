USE VideoGamesSales

-- Find the ten best-selling video games

Select Top 10 * 
From games_sales
Order by Games_sold Desc;

-- Determine how many games in the game_sales table are missing both a user_score and a critic_score

Select Count (g.Game)
From games_sales g
Left join reviews r
On g.Game=r.Game
Where Critic_Score Is null and User_Score Is null;

-- Find the years with the highest average critic_score

SELECT Top 10
    g.Year AS release_year,
    ROUND(AVG(r.Critic_Score), 2) AS avg_critic_score
FROM
    games_sales g
JOIN
    reviews r ON g.game = r.game
GROUP BY
    g.Year
ORDER BY
    avg_critic_score DESC;

-- Find game critics' ten favorite year

SELECT Top 10
    g.Year AS release_year,
	Count(*) as num_games,
    ROUND(AVG(r.Critic_Score), 2) AS avg_critic_score
FROM
    games_sales g
JOIN
    reviews r ON g.game = r.game
GROUP BY
    g.Year
HAVING
	Count(*) > 4
ORDER BY
    avg_critic_score DESC;

-- Find years that dropped off the critics' favorites list

With top_critic_years AS (
SELECT Top 10
    g.Year AS release_year,
    ROUND(AVG(r.Critic_Score), 2) AS avg_critic_score
FROM
    games_sales g
JOIN
    reviews r ON g.game = r.game
GROUP BY
    g.Year
ORDER BY
    avg_critic_score DESC
),
top_critic_years_more_than_four_games As (
SELECT Top 10
    g.Year AS release_year,
	Count(*) as num_games,
    ROUND(AVG(r.Critic_Score), 2) AS avg_critic_score
FROM
    games_sales g
JOIN
    reviews r ON g.game = r.game
GROUP BY
    g.Year
HAVING
	Count(*) > 4
ORDER BY
    avg_critic_score DESC
)
SELECT release_year, avg_critic_score
FROM top_critic_years
EXCEPT
SELECT release_year, avg_critic_score
FROM top_critic_years_more_than_four_games
ORDER BY avg_critic_score DESC;

-- Find years video game players loved

SELECT Top 10
    g.Year AS release_year,
	Count(g.game) as num_games,
    ROUND(AVG(r.User_Score), 2) AS avg_user_score
FROM
    games_sales g
JOIN
    reviews r ON g.game = r.game
GROUP BY
    g.Year
HAVING
	Count(g.game) > 4
ORDER BY
    avg_user_score DESC;

-- Find years that both players and critics loved

With top_user_years_more_than_four_games As (
SELECT Top 10
    g.Year AS release_year,
	Count(g.game) as num_games,
    ROUND(AVG(r.User_Score), 2) AS avg_user_score
FROM
    games_sales g
JOIN
    reviews r ON g.game = r.game
GROUP BY
    g.Year
HAVING
	Count(g.game) > 4
ORDER BY
    avg_user_score DESC
),
top_critic_years_more_than_four_games As (
SELECT Top 10
    g.Year AS release_year,
	Count(*) as num_games,
    ROUND(AVG(r.Critic_Score), 2) AS avg_critic_score
FROM
    games_sales g
JOIN
    reviews r ON g.game = r.game
GROUP BY
    g.Year
HAVING
	Count(*) > 4
ORDER BY
    avg_critic_score DESC
)
SELECT release_year
FROM top_user_years_more_than_four_games
INTERSECT
SELECT release_year
FROM top_critic_years_more_than_four_games;

-- Find sales in the best video game years

With top_user_years_more_than_four_games As (
SELECT Top 10
    g.Year AS release_year,
	Count(g.game) as num_games,
    ROUND(AVG(r.User_Score), 2) AS avg_user_score
FROM
    games_sales g
JOIN
    reviews r ON g.game = r.game
GROUP BY
    g.Year
HAVING
	Count(g.game) > 4
ORDER BY
    avg_user_score DESC
),
top_critic_years_more_than_four_games As (
SELECT Top 10
    g.Year AS release_year,
	Count(*) as num_games,
    ROUND(AVG(r.Critic_Score), 2) AS avg_critic_score
FROM
    games_sales g
JOIN
    reviews r ON g.game = r.game
GROUP BY
    g.Year
HAVING
	Count(*) > 4
ORDER BY
    avg_critic_score DESC
)
SELECT g.Year, SUM(g.games_sold) AS total_games_sold
FROM games_sales g
WHERE g.Year IN (SELECT release_year
FROM top_user_years_more_than_four_games
INTERSECT
SELECT release_year
FROM top_critic_years_more_than_four_games)
GROUP BY g.Year
ORDER BY total_games_sold DESC;