-- Lab SQL Advanced Queries
-- 1. List each pair of actors that have worked together.
with cte_pair_of_actors as
(
select fa1.actor_id as actor_id_1, fa2.actor_id as actor_id_2, fa1.film_id
from sakila.film_actor fa1
join sakila.film_actor fa2 on fa1.film_id = fa2.film_id and fa1.actor_id <> fa2.actor_id
where fa1.actor_id < fa2.actor_id
order by 1
)
select  actor_id_1, concat(a1.first_name, ' ', a1.last_name) as actor_1,
		actor_id_2, concat(a2.first_name, ' ', a2.last_name) as actor_2,
        film.title
from cte_pair_of_actors
join sakila.actor a1 on cte_pair_of_actors.actor_id_1 = a1.actor_id
join sakila.actor a2 on cte_pair_of_actors.actor_id_2 = a2.actor_id
join sakila.film on cte_pair_of_actors.film_id = film.film_id
order by 1;


-- 2. For each film, list actor that has acted in more films.
select  film.film_id, film.title, actor.actor_id, concat(actor.first_name, ' ', actor.last_name) as actor_name,
		sub.films_acted, sub.ranks_
from (
	select  fa1.film_id, fa1.actor_id, count(distinct fa2.film_id) as films_acted,
			rank() over(partition by film_id order by count(distinct fa2.film_id) desc) as ranks_
	from sakila.film_actor fa1
	join sakila.film_actor fa2 on fa1.actor_id = fa2.actor_id
	group by 1, 2
)sub
join sakila.actor on actor.actor_id = sub.actor_id
join sakila.film on film.film_id = sub.film_id
where ranks_ = 1;

-- The next solution is a little more elegant

create temporary table actor_rank_by_film
with cte_number_of_films_by_actor as 
(
select actor_id, count(distinct film_id) films_acted
from sakila.film_actor
group by 1
)
select fa.film_id, fa.actor_id, cte.films_acted, rank() over(partition by film_id order by films_acted desc) as ranks_
from cte_number_of_films_by_actor cte
join sakila.film_actor fa on fa.actor_id = cte.actor_id
;

select film.film_id, film.title, actor.actor_id, concat(actor.first_name, ' ', actor.last_name) as actor_name,
		actor_rank_by_film.films_acted
from actor_rank_by_film
join sakila.actor on actor.actor_id = actor_rank_by_film.actor_id
join sakila.film on actor_rank_by_film.film_id = film.film_id
where ranks_ = 1;