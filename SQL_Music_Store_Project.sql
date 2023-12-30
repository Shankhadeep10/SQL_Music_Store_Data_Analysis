use chinook;
-- ANALYSIS
-- Question Set 1 Easy

/* Q1: Who is the senior most employee, find name and job title */
select*from employee;
select LastName,FirstName,Title,min(HireDate)as previous_join from employee
group by LastName,FirstName,Title order by previous_join limit 1;

/* Q2: Which countries have the most Invoices? */
select*from invoice;
select BillingCountry, count(Total)as most_invoices from invoice 
group by BillingCountry order by most_invoices desc limit 1;
 
/* Q3: What are top 3 values of total invoice? */
select*from invoice;
select Total,dense_rank() over(order by Total desc)as Top_three 
from invoice limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select*from customer;
select*from invoice;
select Country,count(SupportRepId)as best_cus_count from customer group by Country order by best_cus_count desc;

select BillingCity,sum(Total) Highinvoice_tital from invoice 
group by BillingCity order by Highinvoice_tital desc limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select*from customer;
select*from invoice;
select concat(FirstName," ",LastName)as fullname,(select sum(Total) from invoice 
where customer.CustomerId=invoice.CustomerId)as total_spent
from customer order by total_spent desc limit 1;

-- Question Set 2 Moderate

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select*from customer;
select*from invoice;
select*from invoiceline;
select*from track;
select*from genre;
select distinct c.FirstName first_name,c.LastName last_name,c.Email email,g.Name name_ 
from customer c join invoice i on c.CustomerId=i.CustomerId join invoiceline il on i.InvoiceId=il.InvoiceId
join track t on t.TrackId=il.TrackId join genre g on g.GenreId=t.GenreId where g.Name like "Rock" order by email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
select*from album;
select*from track;
select*from artist;
select*from genre;
select a.ArtistId artist_id,a.Name name_,count(al.ArtistId)as total_track from artist a join album al
on a.ArtistId=al.ArtistId join track tr on al.AlbumId=tr.AlbumId join genre g on g.GenreId=tr.GenreId
where g.Name like "Rock" group by artist_id,name_ order by total_track desc limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select*from track;
select Name,Milliseconds from track where length(Name) >(select avg(length(Name)) from track)
order by length(Name) desc;

/* Question Set 3 - Advance */
/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
select*from customer;
select*from invoice;
select*from invoiceline;
select*from track;
select*from album;
select*from artist;
select concat(c.FirstName," ",c.LastName) customer_fullname,a.Name artist_name,sum(il.UnitPrice*il.Quantity) total_spent
from customer c join invoice i on c.CustomerId=i.CustomerId join invoiceline il on i.InvoiceId=il.InvoiceId
join track tr on tr.TrackId=il.TrackId join album al on al.AlbumId=tr.AlbumId join artist a on a.ArtistId=al.ArtistId
group by 1,2 order by 3 desc;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

select*from customer;
select*from invoice;
select*from invoiceline;
select*from track;
select*from genre;

with popular_genre as (select customer.Country,genre.Name, count(invoiceline.Quantity) as total_purchase,
row_number() over (partition by customer.Country order by count(invoiceline.Quantity) desc) as row_no
from customer join invoice on customer.CustomerId = invoice.CustomerId
join invoiceline on invoice.InvoiceId = invoiceline.InvoiceId   
join track on track.TrackId = invoiceline.TrackId
join genre on genre.GenreId = track.GenreId
group by 1, 2 order by total_purchase desc
)
select * from popular_genre where row_no=1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
select*from customer;
select*from invoice;

with customer_spent_onmusic as
(select customer.CustomerId,customer.FirstName,customer.LastName,invoice.BillingCountry,sum(invoice.Total)as most_spent,
row_number() over(partition by invoice.BillingCountry order by sum(invoice.Total) desc)as row_num
from customer join invoice on customer.CustomerId=invoice.CustomerId
group by 1,2,3,4 order by most_spent desc
)
select* from customer_spent_onmusic where row_num=1;




        
