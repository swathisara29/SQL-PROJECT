1) Show the percentage of wins of each bidder in the order of highest to lowest percentage.
select * from ipl_bidding_details;
select BIDDER_ID,((sum(if(bid_status = 'won',1,0))/count(BIDDER_ID))*100) as percent 
from ipl_bidding_details group by BIDDER_ID order by percent desc;

-- 2) display the number of matches conducted at each stadium with stadium and city
select * from ipl_stadium;
select  stadium_name, city, count(match_id) as match_count 
from ipl_match_schedule iplms join ipl_stadium ipls
on iplms.STADIUM_ID = ipls.STADIUM_ID
group by STADIUM_NAME,city;

-- 3) In a given stadium , what is the percentage of wins by a team which has won the toss
select * from ipl_match;
select * from ipl_match_schedule;
with table1 as(
select stadium_id, sum(if(toss_winner=match_winner,1,0)) as winning_count, count(iplm.MATCH_ID) as total_matches
from ipl_match iplm join ipl_match_schedule iplms
on iplm.MATCH_ID=iplms.MATCH_ID
group by stadium_id
order by stadium_id)
select stadium_id,winning_count,total_matches, round((winning_count/total_matches)*100,2) as percent
from table1;

-- 4) show the total bids along with bid team and team name
select * from ipl_bidding_details;
select * from ipl_team;
select count(bidder_id) over() as total_bids,bid_team, team_name
from ipl_bidding_details join ipl_team 
on ipl_bidding_details.bid_team = ipl_team.TEAM_ID;

-- 5) show the team id who won the match as per the win details
select * from ipl_match;
select if(match_winner=1,team_id1,team_id2) as team_id, win_details from ipl_match
order by team_id;

-- 6) display total matches played , total matches won, and total matches lost by the team along with its team name
select * from ipl_team_standings;
select team_id,sum(matches_played) as matches_played,sum(matches_won) as matches_won,sum(matches_lost) as matches_lost
from ipl_team_standings
group by TEAM_ID;

-- 7) display the bowlers for the mumbai indians team
select * from ipl_team_players;
select * from ipl_team;
select player_id 
from ipl_team_players
where PLAYER_ROLE= 'bowler' and TEAM_ID = (
select team_id from ipl_team where team_name ='mumbai indians');

-- 8) how many all rounders are there in each team , display the teams with more than 4 all rounders in desc order
select * from ipl_team_players;
select team_id,count(player_role) as count_players 
from ipl_team_players
where player_role = 'all-rounder'
group by TEAM_ID
having count_players > 4
order by count_players desc;

-- 9) Write a query to get the total bidders points for each bidding status of those bidders who bid on CSK when it won the match in M. Chinnaswamy Stadium bidding year-wise.
-- Note the total bidders’ points in descending order and the year is bidding year.
  -- Display columns: bidding status, bid date as year, total bidder’s points
select bp.bidder_id,total_points,bid_status, year(bid_date) as year 
from ipl_bidder_points bp join ipl_bidding_details bd on bp.BIDDER_ID=bd.BIDDER_ID where bp.bidder_id = any(
select bidder_id from ipl_bidding_details where BID_TEAM = 
(
select team_id from ipl_team where team_name like '%chennai%') and schedule_id = any(
select schedule_id from ipl_match_schedule where stadium_id = any(
select stadium_id from ipl_stadium where stadium_name like '%chinna%'))) and bid_status = 'won'
group by bidder_id,total_points,bid_status,year(bid_date);

-- 10) Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
select (performance_dtls) from ipl_player;
with table2 as(
with table1 as(
select p.player_id,player_role ,convert(substring_index(substring_index(performance_dtls,' ',3),'-',-1),float) as wickets 
from ipl_player p join ipl_team_players tp
on p.player_id = tp.player_id
where player_role in ('bowler','all-rounder'))
select *, dense_rank() over(order by wickets desc) as ranking from table1)
select * from table2 
where ranking <= 5;

-- 11) show the percentage of toss wins of each bidder and display the results in descending order based on the percentage
with table3 as(
with table2 as(
with table1 as (
select ipl_bidding_details.BIDDER_ID, NO_OF_BIDS , bid_team,
if(toss_winner=1,team_id1,team_id2) as toss_win
from ipl_match join ipl_match_schedule
on ipl_match.MATCH_ID = ipl_match_schedule.MATCH_ID
join ipl_bidding_details 
on ipl_match_schedule.SCHEDULE_ID = ipl_bidding_details.SCHEDULE_ID
join ipl_bidder_points
on ipl_bidder_points.BIDDER_ID = ipl_bidding_details.BIDDER_ID)
select * from table1 where BID_TEAM = toss_win)
select bidder_id, round(((count(BIDDER_ID) over(partition by BIDDER_ID) / no_of_bids)*100),2) as win_percent from table2)
select * from table3 
group by bidder_id,win_percent
order by win_percent desc;

-- 12) find the IPL season which has min duration and max duration.
-- Output columns should be like the below:
-- Tournment_ID, Tourment_name, Duration column, Duration
select * from ipl_tournament;
with table1 as(
select tournmt_id, tournmt_name , datediff(to_date,from_date) as Duration_days, min(datediff(to_date,from_date)) over() as min_duration, 
max(datediff(to_date,from_date)) over() as max_duration
from ipl_tournament)
select tournmt_name,duration_days,min_duration,max_duration from table1
where duration_days in (min_duration,max_duration);

-- 13)Write a query to display to calculate the total points month-wise for the 2017 bid year. 
-- sort the results based on total points in descending order and month-wise in ascending order.
-- Note: Display the following columns:
-- 1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
-- Only use joins for the above query queries.
select * from ipl_bidder_points;
select * from ipl_bidding_details;
select * from ipl_bidder_details;
select ipl_bidder_points.bidder_id, bidder_name, year(bid_Date) as 'year', monthname(bid_date) as 'month', total_points
from ipl_bidder_points join ipl_bidding_details
on ipl_bidder_points.bidder_id = ipl_bidding_details.bidder_id
join ipl_bidder_details 
on ipl_bidder_details.bidder_id = ipl_bidding_details.bidder_id
where year(bid_date)=2017
group by ipl_bidder_points.bidder_id,bidder_name,year,month,TOTAL_POINTS
order by 'month' asc, total_points desc;

-- 14) )Write a query to display to calculate the total points month-wise for the 2017 bid year. 
-- sort the results based on total points in descending order and month-wise in ascending order.
-- Note: Display the following columns:
-- 1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
-- using sub queries by having the same constraints as the above question.
select * from ipl_bidder_points;
select * from ipl_bidding_details;
select bidder_id, (select bidder_name from ipl_bidder_details where ipl_bidder_details.bidder_id=ipl_bidding_details.bidder_id) as bidder_name,
year(bid_date) as `year`, monthname(bid_date) as `month`, 
(select total_points from ipl_bidder_points where ipl_bidder_points.bidder_id=ipl_bidding_details.bidder_id) as total_points from ipl_bidding_details
where year(bid_date)=2017
group by bidder_id,bidder_name,year,month,total_points
order by total_points desc;

-- 15) Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
-- Output columns should be:
-- like: Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;
select * from ipl_bidder_points;
with table3 as(
with table2 as(
with table1 as(
select ipl_bidder_details.bidder_id,bidder_name ,total_points , bid_date,
dense_rank() over(order by total_points desc) as ranking
from ipl_bidder_points join ipl_bidder_details
on ipl_bidder_details.BIDDER_ID = ipl_bidder_points.BIDDER_ID 
join ipl_bidding_details 
on ipl_bidding_details.BIDDER_ID = ipl_bidder_points.BIDDER_ID
where TOTAL_POINTS <> 0 and year(bid_date)=2018)
select *, max(ranking) over() as max_ranking from table1)
select *, (max_ranking-1) as no_2, (max_ranking-2) as no_3 from table2)
select bidder_id, bidder_name, total_points, ranking
from table3
where ranking in (1,2,3,max_ranking,no_2,no_3)
group by BIDDER_ID,bidder_name,total_points;
select * from ipl_bidding_details
;

-- 16) Create two tables called Student_details and Student_details_backup.
create table student_details (student_id int,
student_name varchar(30),
mail_id varchar(50),
mobile_no int);

create table student_details_backup (student_id int,
student_name varchar(30),
mail_id varchar(50),
mobile_no int);

delimiter //
create trigger insert_backup 
after insert on student_details 
for each row
begin 
insert into student_details_backup values (new.student_id,new.student_name,new.mail_id,new.mobile_no);
end//
delimiter ;

insert into student_details values (1,'Abrar',null,null);
insert into student_details values (2,'Kutty','kutty7115@gmail.com',1234);

set sql_safe_updates=0;
update student_details set mail_id='abrarz7115@gmail.com' where student_id =1;
select * from student_details;
select * from student_details_backup;