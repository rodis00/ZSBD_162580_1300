set serveroutput on

-- 1
declare
    numer_max number;
    nazwa_dep departments.department_name%type := 'Education';
    nowy_id number;
begin
    select max(department_id) into numer_max from departments;
    DBMS_OUTPUT.PUT_LINE('max number: ' || numer_max);
    
    nowy_id := numer_max + 10;
    
    insert into departments (department_id, department_name) 
    values (nowy_id, nazwa_dep); 
end;

-- 2
declare
    numer_max number;
    nazwa_dep departments.department_name%type := 'Education';
    nowy_id number;
begin
    select max(department_id) into numer_max from departments;
    DBMS_OUTPUT.PUT_LINE('max number: ' || numer_max);
    
    nowy_id := numer_max + 10;
    
    insert into departments (department_id, department_name) 
    values (nowy_id, nazwa_dep); 
    
    -- change location id for new object
    update departments
    set location_id = 3000
    where department_id = nowy_id;
end;

-- 3
create table nowa(liczba varchar(10));

declare
 i number := 1;
begin
    while i <= 10 loop
        if i not in (4,6) then
            insert into nowa values (to_char(i));
        end if;
        i := i + 1;
    end loop;
end;


-- 4
declare
 country countries%rowtype;
begin
    select * into country
    from countries
    where country_id = 'CA';
    
    dbms_output.put_line('region: ' || country.region_id);
    dbms_output.put_line('name: ' || country.country_name);
end;

-- 5
DECLARE
    job_info jobs%ROWTYPE;
    updated_count NUMBER := 0;
BEGIN
    FOR job_info IN (SELECT * FROM jobs WHERE job_title LIKE '%Manager%') LOOP
        UPDATE jobs
        SET min_salary = job_info.min_salary * 1.05
        WHERE job_id = job_info.job_id;
        
        updated_count := updated_count + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Zaktualizowano rekordów: ' || updated_count);

    ROLLBACK;
END;

