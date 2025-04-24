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
CREATE OR REPLACE FUNCTION peselToBirthdate(pesel VARCHAR2)
RETURN VARCHAR2
IS
    v_year     NUMBER;
    v_month    NUMBER;
    v_day      NUMBER;
    v_century  NUMBER;
    v_date     DATE;
BEGIN
    IF LENGTH(pesel) != 11 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nieprawidłowy PESEL.');
    END IF;

    v_year := TO_NUMBER(SUBSTR(pesel, 1, 2));
    v_month := TO_NUMBER(SUBSTR(pesel, 3, 2));
    v_day := TO_NUMBER(SUBSTR(pesel, 5, 2));

    IF v_month BETWEEN 1 AND 12 THEN
        v_century := 1900;
    ELSIF v_month BETWEEN 21 AND 32 THEN
        v_century := 2000;
        v_month := v_month - 20;
    ELSIF v_month BETWEEN 41 AND 52 THEN
        v_century := 2100;
        v_month := v_month - 40;
    ELSIF v_month BETWEEN 61 AND 72 THEN
        v_century := 2200;
        v_month := v_month - 60;
    ELSIF v_month BETWEEN 81 AND 92 THEN
        v_century := 1800;
        v_month := v_month - 80;
    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Nieprawidłowy miesiąc w PESEL.');
    END IF;

    v_date := TO_DATE((v_century + v_year) || LPAD(v_month, 2, '0') || LPAD(v_day, 2, '0'), 'YYYYMMDD');

    RETURN TO_CHAR(v_date, 'YYYY-MM-DD');
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(peselToBirthdate('02270803628'));
END;

