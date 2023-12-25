describe hr;
#mengubah format birthdate
Select birthdate from hr;

set sql_safe_updates = 0;

update hr 
set birthdate = case
	when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    when birthdate like '%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
    else null
end;

alter table hr 
modify column birthdate date;

#mengubah format hire_date
update hr 
set hire_date = case
	when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
    else null
end;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

#mengubah format hire_date
select termdate from hr;
UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%sUTC')),
'0000-00-00')
WHERE true;

set sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;
DESCRIBE HR;

#membuat kolum age
alter table hr add column age int;

update hr
set age = timestampdiff(year, birthdate, curdate());

select
	min(age) As youngest,
    max(age) as oldest
from hr;

select count(*) from hr where age < 18;

select age from hr;

#Analysis

-- 1 what is the gender breakdown of employees in the company?
select gender, count(*) as count
from hr
where age >= 18 and termdate = '0000-00-00'
group by gender;
-- 2 what is the race/ethnicity breakdown of employees in the company?
select race,count(*) as count
from hr
where age >= 18 and termdate = '0000-00-00'
group by race
order by count(*) desc;
-- 3 what is the age distribution of employees in the company?
select
	min(age) As youngest,
    max(age) as oldest
from hr
where age >= 18 and termdate = '0000-00-00';

select 
case 
    when age >= 18 AND age <=24 then '18-24'
    when age >= 25 AND age <=34 then '25-34'
    when age >= 35 AND age <=44 then '35-44'
    when age >= 45 AND age <=54 then '45-54'
    when age >= 55 AND age <=64 then '55-64'
    else '65+'
end as age_group,gender,
count(*) as count
from hr
where age >= 18 and termdate = '0000-00-00'
group by age_group,gender
order by age_group,gender;
    
-- 4 how many emloyees work at headuartes versus remote location?
select location,count(*) from hr
where age >= 18 and termdate = '0000-00-00'
group by location;

-- 5 What is the average length of emploment for employees who have been terminated?
SELECT 
	round(avg(datediff(termdate,hire_date))/365,0) as avg_length_employment
from hr
where termdate<= curdate() and termdate <>'0000-00-00' and age >= 18;

-- 6 how does gender distribution vary across departments and job titles?
select department,gender,count(*) as count from hr
where age >= 18 and termdate = '0000-00-00'
group by department,gender
order by gender;

-- 7 what is distribution of job titles across the company
 select jobtitle,count(*) as count from hr
where age >= 18 and termdate = '0000-00-00'
group by jobtitle
order by jobtitle desc;

-- 8 witch department has the highest turnover rate?
select department,
	total_count,
	terminated_count,
	terminated_count/total_count as termination_rate
from(
	select department,
	count(*) as total_count,
    sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminated_count
	from hr 
	where age >= 18
	group by department
) as subquery
order by termination_rate desc;

-- 9 what th distribution of employes accros location by city and site?
select location_state,count(*) as count
from hr
where age >= 18 and termdate = '0000-00-00'
group by location_state;

select location_city,count(*) as count
from hr
where age >= 18 and termdate = '0000-00-00'
group by location_city;

-- 10 how has the company's employee count change over time based on hire and term dates?
select
	year,
    hires,
    terminations,
    hires - terminations as net_change,
    round((hires - terminations)/ hires*100, 2) as net_change_percent
from(
	select 
    year(hire_date) as year,
    count(*) as hires,
    sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminations
    from hr
    where age >= 18
    group by year(hire_date)
) as subquery
order by year asc;

-- 11 what is ternue distribution for each department?
select department, round(avg(datediff(termdate, hire_date)/365),0) as avg_ternue
from hr
where termdate <= curdate() and termdate <> '0000-00-00' and age >= 18
group by department;

    





