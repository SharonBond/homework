--week 7 
--1.	Create a new column called “status” in the rental table that uses a case statement to indicate if a 
--film was returned late, early, or on time. 
-- use case to create a new column that details whether early, late, on time, or not yet returned for rentals
select rental_id, f.title,  case when rental_duration > date_part('day', return_date - rental_date) then 'early'
when rental_duration < date_part('day', return_date - rental_date) then 'late'
when rental_duration  = date_part('day', return_date - rental_date) then 'on_time'
else 'not_yet_returned' end as status
from rental r
 join inventory i
on r.inventory_id = i.inventory_id
 join film f
on i.film_id = f.film_id
group by f.title, rental_id, rental_duration, return_date, rental_date
order by title;



#2

--we want to sum up the amount in the payment table that corresponds with customers who live in the specified cities
--we select the sum of amount from payment table and join with customer on customer id since that leads us to address where we 
--join on address_id which leads us to join city on city_id and it was probably overkill to do the subquery but the subquery 
--was to get the specified cities of St. Louis and Kansas City. This is assumming we want a total of both Kansas City and St. Louis. If we 
-- want them separate see the second query.

select sum(p.amount)
from payment p
join customer c1
on p.customer_id = c1.customer_id
join address a
on c1.address_id = a.address_id
join city c2
on c2.city_id = a.city_id 
where city in (select city from city
 where city in ('Kansas City', 'Saint Louis'))
 
 --version 2 where KC and St Louis are broken out
 
 select city, sum(amount) as amount
from payment p
join customer c1
on c1.customer_id=p.customer_id
join address a
on c1.address_id=a.address_id
join city c2
on c2.city_id=a.city_id
where city in ('Kansas City','Saint Louis')
Group by city
 
 # 3 - why is there a category table and a film_category table? My guess is that it is to keep the data from being too repetitive. If they were combined they'd have
 -- a lot of repeating info
 -- I wasn't sure exactly what this was asking for. I'm going to assume it is asking how
-- many films were in each of the categories. 

join film category to category on category_id to get the count of films associated with each category
 
 select  name, count(film_id)
from film_category f
join category c
on c.category_id=f.category_id
group by name
order by name
 
 
 4.	Show a roster for the staff that includes their email, address, city, and country (not ids)
 
 --concat the first and last name because I think it looks nice. Get that and email address from Staff table. Join 
--address to staff on address_id to get address field. Join city table to address table on city_id to get the city, then 
--join the country table to the city table to get the country. 


select s.first_name || ' ' || s.last_name as name, s.email, a.address, c1.city, c2.country
from staff s
join address a 
on s.address_id = a.address_id
join city c1
on a.city_id = c1.city_id
join country c2
on c1.country_id = c2.country_id

--5.	Show the film_id, title, and length for the movies that were returned from May 15 to 31, 2005
--I thought "between" was inclusive but it doesn't seem to be here so I had to go a day past the requested dates. Perhaps it is the format of the date. 
--We want to look at the rental tabe to show which movies were returned between those dates. Join inventory and film to get the title and length of the movies. 


select  f.film_id, title, length, return_date
from rental r
join inventory i
on i.inventory_id = r.inventory_id
join film f
on f.film_id = i.film_id
where return_date in (select return_date from rental 
where return_date between '2005-05-15' and '2005-06-01')
order by return_date desc



--6.

--I did this two ways. Not sure which way it went. This was my first try and then Alexis mentioned that "available" meant they're in inventory not just in the film table. 

select title, rental_rate, (select avg(rental_rate) from film as average)
from film
where rental_rate < (select avg(rental_rate) from film)

--assuming films are only available if they're in inventory and not just in the film table we need to join everything to 
--inventory usinging the film id
select distinct title,rental_rate, (select avg(rental_rate) from film as average)
from inventory i
 join film f
on  i.film_id = f.film_id
where rental_rate < (select avg(rental_rate) from film)
order by title


7.
-- I did this one without writing down my process so I'm not entirely sure why I chose cross join
-- but it seems to work.
-- selecting title, rental rate and average rental rate from film while cross joining a second 
--version of film, group it by title and rental rate. Using "having" to narrow it to those with a rental 
--rate lower than the average rental price. 
select f.title, f.rental_rate, round(avg(f1.rental_rate),2) as average
from film f
cross join film f1
group by f.title, f.rental_rate
having f.rental_rate < avg(f1.rental_rate)
order by title

--and here is the version where we are assuming "available and in inventory". 
select f.title, f.rental_rate, round(avg(f1.rental_rate),2) as average
from inventory i
join film f
on i.film_id = f.film_id
cross join film f1
group by f.title, f.rental_rate
having f.rental_rate < avg(f1.rental_rate)
order by title

8. 
Describe what you're seeing and how they differ
It looks like #7 is more expensive to run than #6. Since there are so many different ways to achieve the same results in SQL, it is important to know which 
tools are the best for the job to keep queries moving fast. 

explain plan on 6
	"Seq Scan on film  (cost=133.03..199.53 rows=333 width=53)"
"  Filter: (rental_rate < $1)"
"  InitPlan 1 (returns $0)"
"    ->  Aggregate  (cost=66.50..66.51 rows=1 width=32)"
"          ->  Seq Scan on film average  (cost=0.00..64.00 rows=1000 width=6)"
"  InitPlan 2 (returns $1)"
"    ->  Aggregate  (cost=66.50..66.51 rows=1 width=32)"
"          ->  Seq Scan on film film_1  (cost=0.00..64.00 rows=1000 width=6)"

explain plan on 7
"HashAggregate  (cost=20130.50..20145.50 rows=333 width=21)"
"  Group Key: f.title, f.rental_rate"
"  Filter: (f.rental_rate < avg(f1.rental_rate))"
"  ->  Nested Loop  (cost=0.00..12630.50 rows=1000000 width=27)"
"        ->  Seq Scan on film f  (cost=0.00..64.00 rows=1000 width=21)"
"        ->  Materialize  (cost=0.00..69.00 rows=1000 width=6)"
"              ->  Seq Scan on film f1  (cost=0.00..64.00 rows=1000 width=6)"


 
--9.	With a window function, write a query that shows the film, its duration, and what percentile the duration fits into. 
--This may help https://mode.com/sql-tutorial/sql-window-functions/#rank-and-dense_rank 



select title, length, NTILE(100)over(order by length)
from film

10.	In under 100 words, explain what the difference is between set-based and procedural programming. Be sure to specify which sql and python are. 

/*A procedural approach follows the paradigm of traditional languages used for applications. You perform a function then call another function and so on. - Python. 
 Set based (SQL) means that the operations are performed on a set of values. You are dictating the what, not the how. 