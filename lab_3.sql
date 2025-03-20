-- 1
create view v_wysokie_pensje as
select *
from employees
where salary > 6000;


-- 2
create or replace view v_wysokie_pensje as
select *
from employees
where salary > 12000;


-- 3
drop view v_wysokie_pensje;

-- 4
create view v_employees_finance as
select 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
from employees e
join departments d on e.department_id = d.department_id
where d.department_name = 'Finance';

-- 5
create view v_salary_between as
select 
    e.employee_id,
    e.last_name,
    e.first_name,
    e.salary,
    e.job_id,
    e.email,
    e.hire_date
from employees e
where e.salary between 5000 and 12000;

-- 6
-- nie zadziala bo join blokuje insert
insert into v_employees_finance (
    employee_id,
    first_name,
    last_name,
    salary,
    job_id,
    department_id
)
values (207, 'John', 'Doe', 5000, 1, 100);

-- dziala
update v_employees_finance
set first_name = 'john'
where employee_id = 108;

-- ?
delete constraint from v_employees_finance
where employee_id = 108;

-- 7
create view v_employees_salary as
select
    d.department_id,
    d.department_name,
    count (e.employee_id) as employees_count,
    round(avg(e.salary), 2) as avg_salary,
    max(e.salary) as max_salary
from departments d
join employees e on d.department_id = e.department_id
group by d.department_id, d.department_name
having count(e.employee_id) >= 4;

-- 7a
-- nie mozna dodac danych do funkcji agregujacych

