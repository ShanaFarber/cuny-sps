drop table if exists public.movies;

create table public.movies (
movieID integer primary key,
movie_title varchar(100) not null,
release_date timestamp
)

copy public.movies (
movieID,
movie_title,
release_date
) from 'C:\Temp\movies.csv' delimiter ',' csv header;

drop table if exists public.raters;

create table public.raters (
raterID integer primary key,
name varchar(50) not null,
age integer
)

copy public.raters (
raterID,
name,
age
) from 'C:\Temp\raters.csv' delimiter ',' csv header;

drop table if exists public.movie_ratings;

create table public.movie_ratings (
raterID integer,
movieID integer,
rating integer,
foreign key (raterID) references raters (raterID),
foreign key (movieID) references movies (movieID)
)

copy public.movie_ratings (
raterID,
movieID,
rating
) from 'C:\Temp\movie_ratings.csv' delimiter ',' csv header;