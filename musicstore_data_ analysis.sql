-- Q1:Who is the senior most employee based on the job jitle?
      SELECT * FROM musicdata.employee 
      ORDER BY levels DESC LIMIT 1:
-- Q2:Which country has the most invoices?
	  SELECT billing_country,count(billing_country)AS mostinvoices_country 
      FROM musicdata.invoice GROUP BY billing_country;
-- Q3:What are the top three values of total invoice?
	  SELECT total AS top3_invoices FROM musicdata.invoice
	  ORDER BY total DESC LIMIT 3;
-- Q4:Which city has the best coustomer?Return both the city name & sum of all invoice totals?
	   SELECT billing_city,
       round(sum(total),1)AS total_invoice 
       FROM musicdata.invoice
       GROUP BY 
        billing_city ORDER BY total_invoice DESC;
-- Q5:Who is best customer? Write a query that returns the person who spent the most money? 
        SELECT 
           customer.first_name, 
		   customer.last_name, sum(invoice.total)as sumtotal 
        FROM musicdata.customer
         INNER JOIN invoice ON customer.customer_id=invoice.customer_id
		GROUP BY  
		   customer.first_name,customer.last_name
        ORDER BY 
           sumtotal DESC LIMIT 1;
-- Q1:Write a query to return aemail,firstname,lastname & genre of all rock music listeners list order alphabetically email?
        SELECT DISTINCT 
              email,
              first_name,
              last_name 
		FROM musicdata.customer
          JOIN invoice ON customer.customer_id=invoice.invoice_id
          JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
		WHERE track_id IN (
	     SELECT track_id FROM track 
         JOIN genre ON track.genre_id=genre.genre_id
         WHERE genre.name LIKE "Rock"
        )  
       ORDER BY 1;
-- Q2:Write a query that returns the artist name and total track count of the top 10 rock bands?      
       SELECT 
           artist.name,
		   count(album.album_id)AS total_songs 
	  FROM track
	    JOIN album ON album.album_id=track.track_id
        JOIN artist ON artist.artist_id=album.artist_id
        JOIN genre ON genre.genre_id=track.genre_id
         WHERE genre.name LIKE "Rock"
	  GROUP BY 
		artist.name
	  ORDER BY 
		total_songs DESC
         LIMIT 10;
-- Q3:Return the name milliseconds for each track having a song length longer than the average song length? 
       SELECT 
           name,
           milliseconds 
	   FROM musicdata.track
           WHERE milliseconds > (
           SELECT avg(milliseconds)AS avglen FROM track)
	   ORDER BY 
             milliseconds DESC;
-- Q1:We want to find out the most popular music genre for each country?
   (we determine the most popular genre as the genre with the hightest amount of purchaes)
       WITH popular_genre AS(
        SELECT 
           count(invoice_line.quantity)AS purchases,
           customer.country,genre.name,
           ROW_NUMBER() OVER(PARTITION BY customer.country)AS row_no 
		FROM 
            invoice_line
			JOIN invoice ON invoice.invoice_id=invoice_line.invoice_id
            JOIN customer ON customer.customer_id=invoice.customer_id
            JOIN track ON track.track_id=invoice_line.track_id
            JOIN genre ON genre.genre_id=track.genre_id
        GROUP BY 
           2,3
        ORDER BY 
           2 , 1 DESC
   )
   SELECT * FROM popular_genre WHERE row_no <=1;
   
-- Q2:Write a query that determines the customer that spent the most on music for each country?
        WITH customer_with_country AS (
    SELECT
        customer.first_name,
        customer.last_name,
        invoice.billing_country,
        SUM(invoice.total) AS total_spending,
        ROW_NUMBER() OVER (PARTITION BY invoice.billing_country ORDER BY SUM(invoice.total) DESC) AS row_no
    FROM
        invoice
        JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY
        customer.first_name,
        customer.last_name,
        invoice.billing_country
    ORDER BY
        invoice.billing_country, total_spending DESC
)
SELECT * FROM customer_with_country WHERE row_no<=1;


