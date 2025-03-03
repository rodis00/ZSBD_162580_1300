create table regions (
    region_id number primary key,
    region_name varchar2(50)
);

create table countries (
    country_id number primary key,
    country_name varchar2(255),
    region_id number,
    constraint fk_country_region 
    foreign key (region_id) 
    references regions(region_id)
);

create table locations (
    location_id number primary key,
    street_address varchar2(255),
    postal_code varchar2(50),
    city varchar2(50),
    state_province varchar2(50),
    country_id number,
    constraint fk_location_country
    foreign key (country_id)
    references countries(country_id)
);

create table departments (
    department_id number primary key,
    department_name varchar2(50)
--    manager_id number,
--    location_id number
);

create table jobs (
    job_id number primary key,
    job_title varchar2(50),
    min_salary number(10, 2),
    max_salary number(10, 2),
    constraint check_salary 
    check (max_salary >= min_salary + 2000)
);

create table job_history (
    job_history_id number primary key,
--    employee_id number,
    start_date date,
    end_date date
--    job_id number,
--    department_id number
);

create table employees (
    employee_id number primary key,
    first_name varchar2(50),
    last_name varchar2(50),
    email varchar2(50),
    phone_number varchar2(9),
    hire_date date,
--    job_id number
    salary number(10, 2),
    commission_pct number(5, 2)
--    manager_id number
--    department_id number
);

alter table employees
add (
    job_id number,
    manager_id number,
    department_id number,

    constraint fk_employee_job 
    foreign key (job_id)
    references jobs(job_id),

    constraint fk_employee_manager 
    foreign key (manager_id)
    references employees(employee_id),

    constraint fk_employee_department
    foreign key (department_id)
    references departments(department_id)
);

alter table departments
add (
    manager_id number,
    location_id number,
    
    constraint fk_department_manager 
    foreign key (manager_id)
    references employees(employee_id),
    
    constraint fk_department_location
    foreign key (location_id)
    references locations(location_id)
);

alter table job_history
add (
    employee_id number,
    job_id number,
    department_id number,
    
    constraint fk_job_history_employee
    foreign key (employee_id)
    references employees(employee_id),
    
    constraint fk_job_history_job
    foreign key (job_id)
    references jobs(job_id),
    
    constraint fk_job_history_department
    foreign key (department_id)
    references departments(department_id)
);


-- 2
insert into jobs (job_id, job_title, min_salary, max_salary)
values (1, 'Java Developer', 6000, 8500);

insert into jobs (job_id, job_title, min_salary, max_salary)
values (2, 'Analityk', 5000, 7000);

insert into jobs (job_id, job_title, min_salary, max_salary)
values (3, 'PM', 8000, 10000);

insert into jobs (job_id, job_title, min_salary, max_salary)
values (4, 'SQL Developer', 6000, 9000);


--  3
insert into employees (employee_id, first_name, last_name, email, phone_number,
hire_date, job_id, salary, commission_pct, manager_id, department_id)
values (1, 'Marcin', 'Konieczny', 'marcin.konieczny@example.com', '666555444',
to_date('2020-03-12'), 1, 6000, 0.10, null, null);

insert into employees (employee_id, first_name, last_name, email, phone_number,
hire_date, job_id, salary, commission_pct, manager_id, department_id)
values (2, 'Natalia', 'Murańska', 'natalia.muranska@example.com', '654234069',
to_date('2019-12-03'), 2, 5500, 0.15, null, null);

insert into employees (employee_id, first_name, last_name, email, phone_number,
hire_date, job_id, salary, commission_pct, manager_id, department_id)
values (3, 'Janusz', 'Kozioł', 'janusz.koziol@example.com', '788923412',
to_date('2015-04-22'), 3, 9500, 0.10, 3, null);

insert into employees (employee_id, first_name, last_name, email, phone_number,
hire_date, job_id, salary, commission_pct, manager_id, department_id)
values (4, 'Magdalena', 'Zbik', 'magdalena.zbik@example.com', '503112998',
to_date('2018-07-13'), 4, 7000, 0.12, null, null);


--  4
update employees
set manager_id = 1
where employee_id in (2, 3);


--  5
update jobs
set 
    min_salary = min_salary + 500, 
    max_salary = max_salary + 500
where 
    lower(job_title) like '%b%'
or 
    lower(job_title) like '%s%';


--  6
delete from jobs
where max_salary > 9000;

--  7
drop table jobs cascade constraint;