use sakila;

#1a Display the first and last names of all actors from the table actor.
SELECT first_name, last_name from actor;

#1b Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' FROM actor;

#2a You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
#The WHERE query is most useful here.
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Joe"; 

#2b Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name FROM actor WHERE last_name like "%GEN%"; 

#2c Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name FROM actor WHERE last_name like "%LI%" ORDER BY first_name, last_name; 

#2d Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

#3a You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB
#ALTER TABLE actor 
#ADD COLUMN description BLOB AFTER last_name;
#Select * from actor;

#3b Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
#ALTER TABLE actor 
#DROP COLUMN description;
#Select * from actor;

#4a List the last names of actors, as well as how many actors have that last name.
Select last_name, count(last_name) FROM actor GROUP BY last_name;

#4b List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
Select last_name, count(last_name) FROM actor 
GROUP BY last_name
HAVING count(last_name) > 1;

#4c The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' and last_name = 'WILLIAMS';

#4d Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor SET first_name = 'HARPO' WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';

#5a You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

#6a Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, staff.address_id FROM staff 
JOIN address ON staff.address_id = address.address_id;

#6b Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, staff.staff_id, sum(payment.amount) as 'Total Amount'
FROM staff
JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment_date like "%2005-08%"
GROUP BY staff_id;

#6c List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select film.title, film.film_id, count(film_actor.actor_id) as 'Total Actors'
from film
join film_actor on film.film_id = film_actor.film_id
GROUP BY film_id;

#6d How many copies of the film Hunchback Impossible exist in the inventory system?
select count(inventory.film_id) as '# of copies'
from film
join inventory on film.film_id = inventory.film_id
WHERE film.title like "Hunchback Impossible";

#6e Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select customer.first_name, customer.last_name, sum(payment.amount) as 'Total Amount Paid', customer.customer_id
from customer
join payment on payment.customer_id = customer.customer_id
GROUP BY customer_id
ORDER BY customer.last_name;

#7a The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE language_id = "1" IN
(
  SELECT language_id
  FROM language
  WHERE title like "Q%" 
  OR title like "K%"
);

#7b Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
    SELECT film_id
    FROM film
	WHERE title like "Alone Trip"
  )
);

#7c You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select customer.first_name, customer.last_name, customer.email, district
from customer
join address on customer.address_id = address.address_id 
where district IN ('Alberta', 'British Colombia', 'Manitoba', 'New Brunswick', 'Newfoundland', 'Nova Scotia', 'Nunavut', 'Ontario', 'Prince Edward Island', 'Qubec', 'Saskatchewan', 'Yukon');

#7d Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title from film
where film_id in
(
  SELECT film_id
  FROM film_category
  WHERE category_id IN
  (
    SELECT category_id
    FROM film_category
	Where category_id = '8'
  )
);

#7e Display the most frequently rented movies in descending order.
select count(film.title), film.title from film
join inventory 
on film.film_id = inventory.film_id
join rental 
on rental.inventory_id = inventory.inventory_id
GROUP BY film.title
ORDER BY count(film.title) DESC;

#7f Write a query to display how much business, in dollars, each store brought in.
select sum(payment.amount) as 'sales', store.store_id from payment
join rental
on payment.rental_id = rental.rental_id
join inventory
on inventory.inventory_id = rental.inventory_id
join store
on store.store_id = inventory.store_id
group by store.store_id;

#7g Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country from store
join address 
on store.address_id = address.address_id
join city
on city.city_id = address.city_id
join country
on city.country_id = country.country_id;

#7h List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select sum(payment.amount) as 'sales', category.name from payment
join rental 
on payment.rental_id = rental.rental_id
join inventory
on rental.inventory_id = inventory.inventory_id
join film_category
on film_category.film_id = inventory.film_id
join category
on category.category_id = film_category.category_id
group by category.name
order by sum(payment.amount) DESC;

#8a In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_5_genres AS
select sum(payment.amount) as 'sales', category.name from payment
join rental 
on payment.rental_id = rental.rental_id
join inventory
on rental.inventory_id = inventory.inventory_id
join film_category
on film_category.film_id = inventory.film_id
join category
on category.category_id = film_category.category_id
group by category.name
order by sum(payment.amount) DESC;

#8b How would you display the view that you created in 8a?
select * from top_5_genres;

#8c You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_5_genres;