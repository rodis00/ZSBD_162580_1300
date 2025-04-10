set SERVEROUTPUT on;
 
 -- 1
 create or replace procedure add_job(
  jobId in jobs.job_id%type,
  jobTitle in jobs.job_title%type
  ) as
  begin 
    insert into jobs (job_id, job_title) 
    values (jobId, jobTitle);  
    dbms_output.put_line('new job added');
  exception
    when others then
    dbms_output.put_line('error: ' || sqlerrm);
  end add_job;
  
  begin
  add_job('IT_DB', 'Test job');
  end;
  
-- 2
create or replace procedure modify_job_title (
    jobId in jobs.job_id%type,
    newTitle in jobs.job_title%type
) as
begin
    update jobs 
    set job_title = newTitle
    where job_id = jobId;
exception
    when others then
    dbms_output.put_line('no jobs updated: ' || sqlerrm);
    
end modify_job_title;

begin modify_job_title('IT_DB', 'SQL Developer');
end;

-- 3
create or replace procedure delete_job(
    jobId in jobs.job_id%type
 ) as
 begin 
    delete from jobs
    where job_id = jobId;
    
    if sql%rowcount = 0 then
        raise_application_error(-20002, 'job with id: ' || jobId || ' not found');
    end if;
exception
    when others then
    dbms_output.put_line('error: ' || sqlerrm);
 end;
 
 begin delete_job('IT_DB');
 end;
 
 -- 4
 create or replace procedure get_employee_info (
    employeeId in employees.employee_id%type,
    empLastName out employees.last_name%type,
    empSalary out employees.salary%type
 ) as
 begin
    select e.last_name, e.salary
    into empLastName, empSalary
    from employees e
    where e.employee_id = employeeId;
 end get_employee_info;
 
 
 declare
 empLastName varchar2(255);
 empSalary number;
 begin get_employee_info(100, empLastName, empSalary);
 dbms_output.put_line(empLastName ||' '|| empSalary);
 end;
 
 -- 5
 create sequence employees_seq start with 50 increment by 1;
 
 create or replace procedure add_employee(
    p_first_name in employees.first_name%TYPE DEFAULT 'John',
    p_last_name  in employees.last_name%TYPE DEFAULT 'Doe',
    p_email      in employees.email%TYPE DEFAULT 'jdoe@example.com',
    p_hire_date  in employees.hire_date%TYPE DEFAULT SYSDATE,
    p_job_id     in employees.job_id%TYPE DEFAULT 'IT_PROG',
    p_salary     in employees.salary%TYPE DEFAULT 5000
) as
    e_salary_too_high exception;
    pragma EXCEPTION_INIT(e_salary_too_high, -20010);
begin
    IF p_salary > 20000 then
        RAISE_APPLICATION_ERROR(-20010, 'salary can not be more than 20000.');
    end if;

    insert into employees (
        employee_id, first_name, last_name, email, hire_date, job_id, salary
    ) values (
        employees_seq.nextval, p_first_name, p_last_name, p_email, p_hire_date, p_job_id, p_salary
    );
exception
    when e_salary_too_high then
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
    when others then
        DBMS_OUTPUT.PUT_LINE('error: ' || SQLERRM);
end;