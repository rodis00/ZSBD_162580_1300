-- 1
create or replace function getJobById(id in varchar2)
return varchar2
is
    jobTitle varchar2(255);
    jobNotFound exception;
begin
    select job_title into jobTitle
    from jobs
    where job_id = id;
    
    return jobTitle;
    
exception
    when no_data_found then
        raise jobNotFound;
    when jobNotFound then
        raise_application_error(-20001, 'job not found');
end;
/

set serveroutput on;

begin
    dbms_output.put_line(getjobbyid('IT_PROG'));
end;

-- 2
create or replace function yearSalaryByUserId(id in number)
return number
is
    v_salary number;
    v_commission_pct employees.commission_pct%type;
begin
    select salary, nvl(commission_pct, 0)
    into v_salary, v_commission_pct
    from employees
    where employee_id = id;
    
    v_salary := (v_salary * 12) + (v_salary * v_commission_pct);
    
    return v_salary;
end;
/

begin
    dbms_output.put_line(yearsalarybyuserid(100));
end;

-- 3
create or replace function convertPhoneNumber(number varchar2)
return varchar2
is
    v_area_code varchar2(10);
begin
    v_area_code := substr(number, 1, 2);
    return '(+' || v_area_code || ')';
end;
/

begin
    dbms_output.put_line(convertPhoneNumber('48112222333'));
end;

-- 4
create or replace function convertText(text varchar2)
return varchar2
is
    v_length number := length(text);
    v_result varchar2(255);
begin
    if v_length = 0 then
        return null;
    elsif v_length = 1 then
        return upper(text);
    else
        v_result :=
            UPPER(SUBSTR(text, 1, 1)) ||
            LOWER(SUBSTR(text, 2, v_length - 2)) ||
            UPPER(SUBSTR(text, -1)); 
        
        return v_result;    
    end if;
end;
/

begin
    dbms_output.put_line(convertText('aLLLa'));
end;

-- 5
create or replace function peselToBirthdate(pesel varchar2)
return varchar2
is
    v_year     number;
    v_month    number;
    v_day      number;
    v_century  number;
    v_date     date;
begin
    if length(pesel) != 11 then
        RAISE_APPLICATION_ERROR(-20001, 'Nieprawidłowy PESEL.');
    end if;

    v_year := to_number(substr(pesel, 1, 2));
    v_month := to_number(substr(pesel, 3, 2));
    v_day := to_number(substr(pesel, 5, 2));

    if v_month between 1 and 12 then
        v_century := 1900;
    elsif v_month between 21 and 32 then
        v_century := 2000;
        v_month := v_month - 20;
    elsif v_month between 41 and 52 then
        v_century := 2100;
        v_month := v_month - 40;
    elsif v_month between 61 and 72 then
        v_century := 2200;
        v_month := v_month - 60;
    elsif v_month between 81 and 92 then
        v_century := 1800;
        v_month := v_month - 80;
    else
        raise_application_error(-20002, 'Nieprawidłowy miesiąc w PESEL.');
    end if;

    v_date := to_date((v_century + v_year) || lpad(v_month, 2, '0') || lpad(v_day, 2, '0'), 'YYYYMMDD');

    return to_char(v_date, 'YYYY-MM-DD');
end;
/

begin
    dbms_output.put_line(peselToBirthdate('02270803628'));
end;

-- 6
create or replace function getCountryStats(p_country_name in varchar2)
return varchar2
is
    v_country_id   countries.country_id%type;
    v_dep_count   number := 0;
    v_emp_count    number := 0;

    country_not_found exception;
begin
    select country_id
    into v_country_id
    from countries
    where country_name = p_country_name;

    select count(*)
    into v_dep_count
    from departments d
    join locations l on d.location_id = l.location_id
    where l.country_id = v_country_id;

    select count(*)
    into v_emp_count
    from employees e
    join departments d on e.department_id = d.department_id
    join locations l on d.location_id = l.location_id
    where l.country_id = v_country_id;

    return 'Liczba pracowników: ' || v_emp_count || ', liczba departamentów: ' || v_dep_count;

exception
    when no_data_found then
        raise country_not_found;
    when country_not_found then
        raise_application_error(-20003, 'Kraj o podanej nazwie nie istnieje.');
end;
/

begin
    dbms_output.put_line(getCountryStats('United States of Americaa'));
end;

-- 7
create or replace function generateUniqueIdentifier(
    first_name varchar2, 
    last_name varchar2, 
    phone varchar2
)
return varchar2
is
    v_phone_length number := length(phone);
    result varchar2(50) := '';
begin
    result := 
        substr(last_name, 1, 3) || 
        substr(phone, v_phone_length - 3, v_phone_length) ||
        substr(first_name, 1, 1);
    
    return result;
end;
/

begin
    dbms_output.put_line(generateUniqueIdentifier('Mario', 'Kozak', '755344233'));
end;