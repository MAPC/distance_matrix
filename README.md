# Distance Matrix Crawler

> Finds transit directions between all grid cells in a given area.

## What is it?

The Distance Matrix Crawler crawls uses a spatial grid you provide, and traverses the grid, getting Google Maps travel times between a grid cell and all other grid cells.

## Yeah, but why?

For our youth employment lottery project, we faced a problem: how do we find all of the jobs within a certain commute time -- either public transit or walking -- from an applicant's home address? And then, how do we translate travel times into a travel score?

Constraints:

- We realized we couldn't use distance as a proxy, because distance does not correlate with travel time via public transit, and in places with inconsistent sidewalk access, overpasses, or large blocks, distance doesn't correlate with walking time. Example: From Central Square in Cambridge to Coolidge Corner, Brookline (2.4 miles) takes 33-42 minutes. From Central Square to Downtown Crossing (3.2 miles) takes 12 minutes.

- We also wanted to feed travel time into a function and convert travel times to potential jobs to a overall "match score".

- With about 4000 applicants and about 1000 jobs, we would have had to calculate 4 million travel times, we would have had to calculate 4 million

Solution:

- We broke Boston into a 250m grid. This resulted in TODO grid cells.

> TODO: Image of the grid.

- [This codebase.] We generate a Waitlist by running `rake task:setup`. This makes a list of all of the grid cells that need to be processed. The Waitlist helps us keep track of where we left off -- if an error occurs while processing an origin, we release it and keep it in the list to be worked on again.

- [This codebase.] We run the crawler. It grabs an origin grid cell ID, locking it so that if we're running the task in multiple processes, no other process tries to work on that origin. It then crawls the Google Distance Matrix API, getting public transit and walking times in bulk and saving them to the database.

- In our youth employment algorithm, we assign every applicant and job site to a grid cell. When we get travel times between an applicant and potential job sites, we get the travel times using the table we built up with this crawler. The 250m grid we use is close enough to be relatively accurate, and it saves us the time and API cost of having to look up exact directions between points.


## Setup

#### 1. Create the database

Run `rake db:create`, followed by `rake db:migrate`, to create migrate your database.

> We are using database-related Rake tasks from database.rake. This is not Rails, so you cannot run `rake db:create db:migrate` like you can with Rails.


#### 2. Add your API keys

In certain environments (more on that later), you can spin up as many crawler tasks as there are API keys. That means, if you have two Google API keys, you can spin up two containers to run in parallel, and have all of your data in half the time.


#### 3. Point your database configuration.

Set your DATABASE_URL environment variable to the location of your database.


#### 4. Pre-populate the database with grid cells.

The database must be pre-populated with all of the travel times.

> TODO: How to create the grid in the first place.

> TODO: How to create the travel time pairs for importing, and then how to import.

There will be one pair of input_id, target_id for directions between every grid cell. Every

All distances are in meters, and all coordinates are in WGS84 / SRID 4326 lat-long, i.e. 42.03857 (degrees).

  - input_id: The grid cell ID of the origin.
  - target_id: The grid cell ID of the destination.
  - g250m_id_origin: TODO
  - g250m_id_destination: TODO
  - distance: TODO
  - x_origin: The x-coordinate of the origin.
  - y_origin: The y-coordinate of the origin.
  - x_destination: The x-coordinate of the origin.
  - y_destination: The y-coordinate of the origin.
  - travel_mode: 'walking' or 'transit'
  - time: Time in seconds between grid cells for that transit mode.


#### 5. Set the date.

In `lib/lib/distance_matrix_client.rb`, we have a couple of lines that you should look at and alter before running.

```ruby
# lib/lib/distance_matrix_client.rb
ARRIVAL_TIME = 1456407900.freeze # 25 Feb 2016 8:45 AM -5:00 HOLIDAY
```

We set arrival time explicitly, because we wanted to get the travel times for a timeframe in which young people would get to work a little before 9 am. Google Maps directions are available only so far in the future, so while we would have ideally gotten travel times in July, we could only go a little forward.

```ruby
# lib/lib/distance_matrix_client.rb
def options
# ...
  opts.merge!({ arrival_time: ARRIVAL_TIME }) if opts[:mode] == :transit
# ...
end
```

If the travel mode we're looking at is public transit (not walking) we want to set the arrival time. If you are using this with a set departure time instead of a set arrival time, make sure to change this parameter.




## Usage

Before running the crawler task, set up the waitlist. The waitlist is a list of all of the pairs of grid cell IDs for which we don't yet have travel time information. The waitlist is used to make sure that if there are multiple crawler processes being run, that only one process is working on a given set of grid cell IDs.

Run `rake task:setup` to set up the waitlist. This only needs to be done once per run, regardless of how many processes will do the crawling. This sets up the database for all of the processes.

To run the crawler task, run `rake task:run`.

#### Deployed with a multi-container environment.

We recommend deploying this app to Docker Cloud to run multiple processes in parallel. We found six API keys, and therefore ran the rake task in six containers that all worked in parallel, conflict-free.

Get all of the API keys you can from personal email addresses, friends' email addresses, etc., and enable the Distance Matrix API for each one. If you enable billing for the first time on an account, it gets a significant amount of free credits which enable you to perform A LOT of API requests and get your data faster.

Load them all into your database via the command line, re: the instructions above.

Deploy the app to Docker Cloud, set the environment variables, and scale up to as many containers as you have API keys. (You could scale past the number of API keys you have, but all the containers that start up and can't find available API keys quickly exit.)

Follow the steps starting with [Introducing Docker Cloud](https://docs.docker.com/docker-cloud/getting-started/intro_cloud/) and read up on deploying an application.

#### Basic steps (please see the Docker Cloud documentation for more complete instructions):

- First, make sure you've linked a "cloud provider". Since we use Amazon AWS, we can link our account. Docker Cloud will then use AWS infrastructure for the containers we create on Docker Cloud.

- Next, push this repository to Docker Hub, and create a Service from it. A Service makes a repository runnable. Set up the environment variables (DATABASE_URL is the only one at present). Make sure the containers aren't set to auto-restart on exit, because we want them to die off once they're finished.

- From your local terminal, set the DATABASE_URL and run `rake task:setup`.

- To run the cralwer, scale the Docker Cloud service from 0 containers to a number equal to the number of API keys in the database (ApiKey.count).
