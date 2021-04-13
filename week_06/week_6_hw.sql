--	Show all customers whose last names start with T. Order them by first name from A-Z.

-- select all from table 'customer' where customer last name starts with T. Then put them in order by first name. 
select * 
from customer
where last_name like 'T%'
order by first_name



---2.	Show all rentals returned from 5/28/2005 to 6/1/2005
--select everything from table 'rental' where the return date is between the two dates given
select * from rental
where return_date between '2005-05-28' and '2005-06-01'







--3.	How would you determine which movies are rented the most?

-- join rental and film on the inventory id and film id. Select title from 
--film, and count on the rental date - assuming that each rental date was a new 
--instance of it being rented so it can be considered counting how many times it has 
--been rented. 
--group by title and then order by the count of times rented descending
select  f.title, count(rental_date) as times_rented
from rental r, film  f
where r.inventory_id = f.film_id
group by  f.title
order by times_rented desc




--4.	Show how much each customer spent on movies (for all time) . Order them from least to most.
-- join tables customer and payment on the customer id field
-- concat first and last name to get name, select that, customer id, and sum up the amount from the payment
--table as total
--group by name and customer id and order by total ascending
select c.first_name || ' ' ||c.last_name as name, c.customer_id, sum(p.amount) as total
from customer c, payment p
where c.customer_id = p.customer_id
group by name, c.customer_id
order by total 




--5.	Which actor was in the most movies in 2006 (based on this dataset)? Be sure to alias the actor name and count as a more descriptive name. Order the results from most to least.

-- we are working with three tables - the actor table for the name, the film_actor table which is the bridge between the name of the actor
-- and the name of the movie. We join actor to film_actor with actor_id and film_actor to film with film_id
--we are looking film count and need actor id (because there seem to be some actors with the same name) and actor name 
-- because id just doesn't do it for me. 
--make sure to specify year of 2006 (which doesn't actually appear to be necessary since the only release year in this database is 2006
-- group it by actor id and actor name and order by film count descending

select a.actor_id,  a.first_name || ' '|| a.last_name as actor_name, count(f.film_id) as film_count
from film f, actor a, film_actor fa
where f.film_id = fa.film_id
and fa.actor_id = a.actor_id
and f.release_year = 2006
group by  a.actor_id, actor_name
order by 3 desc; 







--6.	Write an explain plan for 4 and 5. Show the queries and explain what is happening in each one. Use the following link to understand how this works http://postgresguide.com/performance/explain.html 

--For 4 - concat first name from customer and last name from customer, get the customer id from customer, and sum the payment amount as total. 
--Join customer and payment on customer_id and group them by concat name and customer id. Order by total
--For 5 -- 
	--Select actor id from actor, concat first and last name from actor name, get count of film id from film. Join film ids for film and film actor, join 
	--film actor actor id with actor actor id and set release year to 2009. Group by actor id and name and order by film count. 


--7.	What is the average rental rate per genre?
--Relevant data is in film, film_category, and category tables. We alias category's name column as genre. We need to cast 
--the average rental rate to decimal and alias as average_rental_rate. Not doing so results in a very strange number. We join film and film category on film_id
-- and join category and film_category on category_id. 
--order by genre
select c.name as genre,  CAST(AVG(f.rental_rate) AS DECIMAL(10,2)) as average_rental_rate
from film f, film_category fc, category c
where f.film_id = fc.film_id
and c.category_id = fc.category_id
group by genre




--8.	How many films were returned late? Early? On time?
--I probably made this far more convuluted than it needed to be. 
--film rental dates were in the rental table and rental duration is film table. We want to count the rental ids based on what
--group they fall in late, on time, or early. To determine if they are late, on time or early we need to subtract the rental date
-- from the return date and compare to the rentual duration. The time is included in the return and rental dates so we 
-- case those as date and then subtract. Use CASE to set up the conditions of when days out are greater than rental duration
--making it late, days out equal to rental duration making it on time, and days out less than rental duration making it early.
--make sure to account for those that have been rented but not yet returned
--join inventory table to rental table using inventory_id and film to inventory with film_id. 
--Group by the entire case

select count( r.rental_id), 
Case  when (cast(return_date as date) -  cast(rental_date as date)) >  f.rental_duration then 'late'
when (cast(r.return_date as date) -  cast(r.rental_date as date)) =  f.rental_duration then 'on time'
when (cast(return_date as date) -  cast(rental_date as date)) <  f.rental_duration then 'early'
else 'not yet returned' end
from film f, rental r, inventory i
where i.inventory_id = r.inventory_id
and f.film_id = i.film_id
group by Case  when (cast(return_date as date) -  cast(rental_date as date)) >  f.rental_duration then 'late'
when (cast(r.return_date as date) -  cast(r.rental_date as date)) =  f.rental_duration then 'on time'
when (cast(return_date as date) -  cast(rental_date as date)) <  f.rental_duration then 'early'
else 'not yet returned' end



--9.	What categories are the most rented and what are their total sales?

--I originally tried editing the sales_by_film_category view but just couldn't get it right. There was something I was missing and couldn't get it. So I 
--borrowed from the view, rental, film_category, inventory, and category tables to select category, total sales, and times rented (count of rental id). 
--I joined using inventory_id, category/name, film id, and category_id. Group by category and total sales. Order by total sales. 


select s.category, s.total_sales, count(rental_id) as Times_rented

from public.sales_by_film_category s, rental r, film_category f, inventory i, category c
where r.inventory_id = i.inventory_id
and s.category = c.name
and f.film_id = i.film_id
and c.category_id = f.category_id
group by s.category, s.total_sales
order by 3 desc

--10.	Create a view for 8 and a view for 9. Be sure to name them appropriately. 

create view rental_by_category as select s.category, s.total_sales, count(rental_id) as Times_rented
from public.sales_by_film_category s, rental r, film_category f, inventory i, category c
where r.inventory_id = i.inventory_id
and s.category = c.name
and f.film_id = i.film_id
and c.category_id = f.category_id
group by s.category, s.total_sales
order by 3 desc

create view rental_details as select s.category, s.total_sales, count(rental_id) as Times_rented
from public.sales_by_film_category s, rental r, film_category f, inventory i, category c
where r.inventory_id = i.inventory_id
and s.category = c.name
and f.film_id = i.film_id
and c.category_id = f.category_id
group by s.category, s.total_sales
order by 3 desc

--Bonus:
--Write a query that shows how many films were rented each month. Group them by category and month. 

--get month isolated by doing extract month from rental date. Select that, name, and count of rental id from rental, category, film category, and inventory. 
--join film category film id to inventory film id, category category id to film category category id, and inventory's inventory id to rental's inventory id
--group them by month and name and put them in a pleasing order. 

SELECT  EXTRACT(month from rental_date) as month, c.name, count(r.rental_id) as qty_rented

from rental r, category c, film_category fc, inventory i
where c.category_id = fc.category_id
and fc.film_id = i.film_id 
and i.inventory_id = r.inventory_id
group by 1,2
order by 1,3
