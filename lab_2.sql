drop table regions cascade constraint;

select * from hr.countries;
select * from hr_countries;
select * from hr_sales;

-- create new tables
create table hr_countries as 
    select * from hr.countries;

create table hr_departments as
    select * from hr.departments;

create table hr_employees as
    select * from hr.employees;

create table hr_job_grades as
    select * from hr.job_grades;

create table hr_job_history as
    select * from hr.job_history;

create table hr_jobs as
    select * from hr.jobs;

create table hr_locations as
    select * from hr.locations;

create table hr_products as
    select * from hr.products;
    
create table hr_regions as 
    select * from hr.regions;

create table hr_sales as
    select * from hr.sales;


-- insert data from old to new table
insert into hr_countries
    select * from hr.countries;

insert into hr_departments
    select * from hr.departments;

insert into hr_employees
    select * from hr.employees;

insert into hr_job_history
    select * from hr.job_history;

insert into hr_job_grades
    select * from hr.job_grades;

insert into hr_jobs
    select * from hr.jobs;

insert into hr_locations
    select * from hr.locations;

insert into hr_products
    select * from hr.products;

insert into hr_regions
    select * from hr.regions;

insert into hr_sales
    select * from hr.sales;


-- zadania
-- 1
select last_name || ' ' || salary as wynagrodzenie
from hr_employees
where department_id in (20, 50)
and salary between 2000 and 7000
order by last_name;

-- 2
select hire_date, last_name, salary
from hr_employees
where manager_id is not null
and extract (year from hire_date) = 2005
order by salary;

-- 3
select first_name || ' ' || last_name as full_name,
salary, phone_number
from hr_employees
where substr(last_name, 3, 1) = 'e'
and first_name like '%' || 'en' || '%'
order by full_name desc, salary asc;

-- 4
select first_name, last_name, 
round(months_between(sysdate, hire_date)) as liczba_miesiecy,
case
    when round(months_between(sysdate, hire_date)) < 150
    then salary * 0.10
    when round(months_between(sysdate, hire_date)) between 150 and 200
    then salary * 0.20
    else salary * 0.30
end as wysokosc_dodatku
from hr_employees
order by liczba_miesiecy;

-- 5
select department_id,
sum(salary) as suma_zarobkow,
round(avg(salary)) as srednia_zarobkow
from hr_employees
where department_id in (
    select department_id
    from hr_employees
    group by department_id
    having min(salary) > 5000
)
group by department_id;

-- 6
select
    e.last_name,
    e.department_id,
    d.department_name,
    e.job_id
from hr_employees e
join hr_departments d on e.department_id = d.department_id
join hr_locations l on d.location_id = l.location_id
where l.city = 'Toronto';

-- 7
select
    e.first_name || ' ' || e.last_name as jennifer,
    e2.first_name || ' ' || e2.last_name as wspolpracownik
from hr_employees e
join hr_employees e2 on e.department_id = e2.department_id
where e.first_name = 'Jennifer'
and e.employee_id <> e2.employee_id;

-- 8
select d.department_id
from hr_departments d
left join hr_employees e on d.department_id = e.department_id
where e.department_id is null;

-- 9
select
    e.first_name,
    e.last_name,
    e.job_id,
    d.department_name,
    e.salary,
    g.grade
from hr_employees e
join hr_departments d on e.department_id = d.department_id
join hr_job_grades g on e.salary between g.min_salary and g.max_salary
order by e.salary desc;

-- 10
select distinct
    e.first_name,
    e.last_name,
    e.salary
from hr_employees e
where e.salary > (select avg(salary) from hr_employees)
order by salary desc;

-- 11
select
    e.employee_id,
    e.first_name,
    e.last_name
from hr_employees e
where e.department_id in (
    select department_id
    from hr_employees
    where last_name like '%u%'
);

-- 12
select 
    e.first_name,
    e.last_name,
    e.hire_date,
    months_between(sysdate, e.hire_date) as months
from hr_employees e
where months_between(sysdate, e.hire_date) > 
    (select avg(months_between(sysdate, e.hire_date)) from hr_employees)
order by months desc;

-- 13
select 
    d.department_name,
    count(e.employee_id) as employee_count,
    round(avg(e.salary), 2) as avg_salary
from hr_departments d
left join hr_employees e on d.department_id = e.department_id
group by d.department_name
order by employee_count desc;

-- 14
select 
    first_name,
    last_name,
    salary
from hr_employees
where salary < (
    select min(salary) 
    from hr_employees 
    where department_id in (
        select department_id 
        from hr_departments 
        where department_name = 'IT'
    )
);

-- 15
select distinct
    d.department_id,
    d.department_name
from hr_departments d
join hr_employees e on d.department_id = e.department_id
where e.salary > (
    select avg(salary) 
    from hr_employees
);

-- 16
select 
    job_id,
    round(avg(salary), 2) as avg_salary
from hr_employees
group by job_id
order by avg_salary desc
fetch first 5 rows only;

-- 17
select 
    r.region_name,
    count(c.country_id) as country_count,
    count(e.employee_id) as employee_count
from hr_regions r
join hr_countries c on r.region_id = c.region_id
left join hr_locations l on c.country_id = l.country_id
left join hr_departments d on l.location_id = d.location_id
left join hr_employees e on d.department_id = e.department_id
group by r.region_name
order by employee_count desc;

-- 18
select 
    e.first_name,
    e.last_name,
    e.salary as employee_salary,
    m.first_name as manager_f_name,
    m.last_name as manager_l_name,
    m.salary as manager_salary
from hr_employees e
join hr_employees m on e.manager_id = m.employee_id
where e.salary > m.salary;

-- 19
select
    to_char(hire_date, 'MM') as month_number,
    to_char(hire_date, 'Month') as month_name,
    count(*) as employee_count
from hr_employees
group by to_char(hire_date, 'MM'), to_char(hire_date, 'Month')
order by month_number;

-- 20
select 
    d.department_name,
    round(avg(e.salary), 2) as avg_salary
from hr_departments d
join hr_employees e on d.department_id = e.department_id
group by d.department_name
order by avg_salary desc
fetch first 3 row only;
