
select * from portfolio1.dbo.Table1;

select * from portfolio1.dbo.Table2;

-- number of rows in dataset

select count(*) from portfolio1..Table1;
select count(*) from portfolio1..Table2;

-- dataset for jharkhand and bihar

select * from  portfolio1..Table1
where state in ('jharkhand', 'bihar');

--population of india

select sum(population) as population from portfolio1..table2;

-- average growth of india

select AVG(growth)*100 as avg_growth from portfolio1..table1;

-- average by state

select state, AVG(growth)*100 as avg_by_state from portfolio1..table1 group by state;

-- sex_ratio avg by state

SELECT STATE, ROUND(AVG(SEX_RATIO),1) AS AVG_SEX_RATIO FROM portfolio1..Table1 GROUP BY STATE ORDER BY AVG_SEX_RATIO DESC;

-- AVG LITRACY RATE
SELECT STATE, ROUND(AVG(Literacy),1) AS AVG_LITRACY_RATIO FROM portfolio1..Table1 
GROUP BY STATE
HAVING ROUND(AVG(Literacy),1)>90
ORDER BY AVG_LITRACY_RATIO DESC;


-- TOP THREE STATES SHOWING HIGHEST GROWTH RATIO

SELECT TOP 3 STATE, AVG(GROWTH)*100 AS AVG_GROWTH FROM portfolio1..Table1 GROUP BY STATE ORDER BY AVG_GROWTH DESC;

-- TOP THREE STATES SHOWING HIGHEST GROWTH RATIO BY LIMIT FUNCTION

SELECT STATE, AVG(GROWTH)*100 AS AVG_GROWTH FROM portfolio1..Table1 GROUP BY STATE ORDER BY AVG_GROWTH DESC limit 3;


-- Bottom 3 states showing sex ratio
SELECT TOP 3 STATE, ROUND(AVG(SEX_RATIO),0) AS AVG_SEX_RATIO FROM PORTFOLIO1..TABLE1 GROUP BY STATE ORDER BY AVG_SEX_RATIO ASC;


-- TOP AND BOTTOM STATES IN LITRACY RATE USING NEW TABLE

DROP TABLE IF EXISTS #TOPSTATES;
CREATE TABLE #TOPSTATES
(STATE NVARCHAR(225),
TOPSTATE FLOAT
)

INSERT INTO #TOPSTATES
SELECT STATE, ROUND(AVG(Literacy),0) AS AVG_LITRACY_RATIO FROM portfolio1..Table1 GROUP BY STATE ORDER BY AVG_LITRACY_RATIO DESC;

SELECT TOP 3 * FROM #TOPSTATES ORDER BY #TOPSTATES.TOPSTATE DESC;


DROP TABLE IF EXISTS #BOTTOMSTATES;
CREATE TABLE #BOTTOMSTATES
(STATE NVARCHAR(225),
BOTTOMSTATE FLOAT
)

INSERT INTO #BOTTOMSTATES
SELECT STATE, ROUND(AVG(Literacy),0) AS AVG_LITRACY_RATIO FROM portfolio1..Table1 GROUP BY STATE ORDER BY AVG_LITRACY_RATIO DESC;

SELECT TOP 3 * FROM #BOTTOMSTATES ORDER BY #BOTTOMSTATES.BOTTOMSTATE ASC;


select * from 
(SELECT TOP 3 * FROM #TOPSTATES ORDER BY #TOPSTATES.TOPSTATE DESC) a

union

select * from 
(SELECT TOP 3 * FROM #BOTTOMSTATES ORDER BY #BOTTOMSTATES.BOTTOMSTATE ASC) b;


-- states starting with letter A

select distinct(state) from portfolio1..Table1 where lower(state) like 'a%' or lower(state) like 'b%';

select distinct(state) from portfolio1..Table1 where lower(state) like 'a%' or lower(state) like '%d';

select distinct(state) from portfolio1..Table1 where lower(state) like 'a%' and lower(state) like '%m';


-- joining both tables 



select * from portfolio1.dbo.Table1;
select * from portfolio1.dbo.Table2;

select a.District, a.State, a.Sex_Ratio, b.Population from portfolio1..Table1 a inner join portfolio1..Table2 b on a.District=b.District;

---- total males and females

select d.state, sum(d.males) total_males, sum(d.females) total_females from
(select c.district, c.state state, round(c.population/(c.sex_ratio +1),0) males, round((population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.District, a.State, a.Sex_Ratio/1000 sex_ratio, b.Population from portfolio1..Table1 a inner join portfolio1..Table2 b on a.District=b.District) c) d
group by d.state;


-- total literacy ratio

select d.state, sum(d.literate_people) total_literate_people, sum(d.iliterate_people) total_iliterate_people from
(select c.district, c.state, round(c.literacy_ratio*c.population,0) literate_people, round((1-c.literacy_ratio)*c.population,0) iliterate_people from
(select a.district, a.state, a.literacy/100 literacy_ratio, b.population 
from portfolio1..Table1 a inner join portfolio1..Table2 b on a.District=b.District) c) d
group by d.state;

--- population in previous census

select d.state, sum(d.previous_census_population) previous_census_population, sum(d.current_census_population) current_census_population from
(select c.district, c.state, round(c.population/(1+c.growth),0) previous_census_population, c.population current_census_population from
(select a.district, a.state, a.growth, b.population from portfolio1..Table1 a inner join portfolio1..Table2 b on a.district=b.district) c) d
group by d.state;

---- total current_census_population and total previous_census_population

select sum(e.previous_census_population) total_previous_census_population, sum(e.current_census_population) total_current_census_population from
(select d.state, sum(d.previous_census_population) previous_census_population, sum(d.current_census_population) current_census_population from
(select c.district, c.state, round(c.population/(1+c.growth),0) previous_census_population, c.population current_census_population from
(select a.district, a.state, a.growth, b.population from portfolio1..Table1 a inner join portfolio1..Table2 b on a.district=b.district) c) d
group by d.state) e


-- population vs area

  --- join tables 
select g.*, k.* from
(select '1' as keyy, f.* from
(select sum(e.previous_census_population) total_previous_census_population, sum(e.current_census_population) total_current_census_population from
(select d.state, sum(d.previous_census_population) previous_census_population, sum(d.current_census_population) current_census_population from
(select c.district, c.state, round(c.population/(1+c.growth),0) previous_census_population, c.population current_census_population from
(select a.district, a.state, a.growth, b.population from portfolio1..Table1 a inner join portfolio1..Table2 b on a.district=b.district) c) d
group by d.state) e) f) g

inner join

(select '1' as keyy, j.* from
(select sum(Area_km2) Area from portfolio1..Table2) j)k on g.keyy=k.keyy;


--- calculate reduced area

select m.area/m.total_previous_census_population as previous_census_population_vs_area, m.area/m.total_current_census_population as current_census_population_vs_area from
(select g.*, k.Area from
(select '1' as keyy, f.* from
(select sum(e.previous_census_population) total_previous_census_population, sum(e.current_census_population) total_current_census_population from
(select d.state, sum(d.previous_census_population) previous_census_population, sum(d.current_census_population) current_census_population from
(select c.district, c.state, round(c.population/(1+c.growth),0) previous_census_population, c.population current_census_population from
(select a.district, a.state, a.growth, b.population from portfolio1..Table1 a inner join portfolio1..Table2 b on a.district=b.district) c) d
group by d.state) e) f) g

inner join

(select '1' as keyy, j.* from
(select sum(Area_km2) Area from portfolio1..Table2) j)k on g.keyy=k.keyy) m