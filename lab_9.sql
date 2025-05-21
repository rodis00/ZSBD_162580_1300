-- 1
CREATE OR REPLACE PACKAGE employee_pkg AS
    PROCEDURE add_employee(
        p_first_name IN employees.first_name%TYPE DEFAULT 'John',
        p_last_name  IN employees.last_name%TYPE DEFAULT 'Doe',
        p_email      IN employees.email%TYPE DEFAULT 'jdoe@example.com',
        p_hire_date  IN employees.hire_date%TYPE DEFAULT SYSDATE,
        p_job_id     IN employees.job_id%TYPE DEFAULT 'IT_PROG',
        p_salary     IN employees.salary%TYPE DEFAULT 5000
    );

    PROCEDURE add_job(
        jobId IN jobs.job_id%TYPE,
        jobTitle IN jobs.job_title%TYPE
    );
    
    PROCEDURE delete_job(
        jobId in jobs.job_id%type
    );
    
    PROCEDURE get_employee_info (
        employeeId in employees.employee_id%type,
        empLastName out employees.last_name%type,
        empSalary out employees.salary%type
    );
    
    procedure modify_job_title (
        jobId in jobs.job_id%type,
        newTitle in jobs.job_title%type
    );

    function convertPhoneNumber(number varchar2) return varchar2;
    function convertText(text varchar2) return varchar2;
    function generateUniqueIdentifier(
        first_name varchar2, 
        last_name varchar2, 
        phone varchar2
    )return varchar2;
    function getCountryStats(p_country_name in varchar2) return varchar2;
    function getJobById(id in varchar2) return varchar2;
    function obliczPodatek(salary in number) return number;
    function peselToBirthdate(pesel varchar2) return varchar2;
    function yearSalaryByUserId(id in number) return number;
    
END employee_pkg;
/

CREATE OR REPLACE PACKAGE BODY employee_pkg AS
    PROCEDURE add_employee(
        p_first_name IN employees.first_name%TYPE,
        p_last_name  IN employees.last_name%TYPE,
        p_email      IN employees.email%TYPE,
        p_hire_date  IN employees.hire_date%TYPE,
        p_job_id     IN employees.job_id%TYPE,
        p_salary     IN employees.salary%TYPE
    ) AS
        e_salary_too_high EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_salary_too_high, -20010);
    BEGIN
        IF p_salary > 20000 THEN
            RAISE_APPLICATION_ERROR(-20010, 'salary can not be more than 20000.');
        END IF;

        INSERT INTO employees (
            employee_id, first_name, last_name, email, hire_date, job_id, salary
        ) VALUES (
            employees_seq.NEXTVAL, p_first_name, p_last_name, p_email, p_hire_date, p_job_id, p_salary
        );

        DBMS_OUTPUT.PUT_LINE('Employee added successfully.');

    EXCEPTION
        WHEN e_salary_too_high THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('error: ' || SQLERRM);
    END add_employee;

    PROCEDURE add_job(
        jobId IN jobs.job_id%TYPE,
        jobTitle IN jobs.job_title%TYPE
    ) AS
    BEGIN
        INSERT INTO jobs (job_id, job_title)
        VALUES (jobId, jobTitle);
        DBMS_OUTPUT.PUT_LINE('New job added');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('error: ' || SQLERRM);
    END add_job;
    
    procedure delete_job(
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
    end delete_job;
    
    procedure get_employee_info (
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
    
    procedure modify_job_title (
        jobId in jobs.job_id%type,
        newTitle in jobs.job_title%type
    ) as
    begin
        update jobs set job_title = newTitle
        where job_id = jobId;
    end modify_job_title;

    FUNCTION convertPhoneNumber(number VARCHAR2)
        RETURN VARCHAR2
    IS
        v_area_code VARCHAR2(10);
    BEGIN
        v_area_code := SUBSTR(number, 1, 2);
        RETURN '(+' || v_area_code || ')';
    END convertPhoneNumber;
    
    function convertText(text varchar2)
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
    end convertText;
    
    function generateUniqueIdentifier(
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
    end generateUniqueIdentifier;
    
    function getCountryStats(p_country_name in varchar2)
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
    end getCountryStats;
    
    function getJobById(id in varchar2)
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
    end getJobById;
    
    function obliczPodatek(salary in number)
    return number
    is
    begin
        return salary * 0.2;
    end obliczPodatek;
    
    FUNCTION peselToBirthdate(pesel VARCHAR2)
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
    END peselToBirthdate;
    
    function yearSalaryByUserId(id in number)
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
    end yearSalaryByUserId;

END employee_pkg;
/

-- 2
CREATE OR REPLACE PACKAGE region_pkg AS
    -- CREATE
    PROCEDURE add_region(p_region_id IN regions.region_id%TYPE, p_region_name IN regions.region_name%TYPE);

    -- READ
    FUNCTION get_region_name(p_region_id IN regions.region_id%TYPE) RETURN VARCHAR2;
    PROCEDURE get_all_regions;
    PROCEDURE get_regions_by_name(p_partial_name IN VARCHAR2);

    -- UPDATE
    PROCEDURE update_region_name(p_region_id IN regions.region_id%TYPE, p_new_name IN regions.region_name%TYPE);

    -- DELETE
    PROCEDURE delete_region(p_region_id IN regions.region_id%TYPE);
    
    -- Logging
    PROCEDURE log_error(p_procedure_name IN VARCHAR2, p_error_message IN VARCHAR2);
END region_pkg;
/

CREATE OR REPLACE PACKAGE BODY region_pkg AS

    region_name_exists EXCEPTION;
    region_has_countries EXCEPTION;

    PRAGMA EXCEPTION_INIT(region_name_exists, -20001);
    PRAGMA EXCEPTION_INIT(region_has_countries, -20002);

    PROCEDURE log_error(p_procedure_name IN VARCHAR2, p_error_message IN VARCHAR2) IS
    BEGIN
        INSERT INTO region_errors_audit(procedure_name, error_message)
        VALUES (p_procedure_name, p_error_message);
    END log_error;

    PROCEDURE add_region(p_region_id IN regions.region_id%TYPE, p_region_name IN regions.region_name%TYPE) AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM regions WHERE LOWER(region_name) = LOWER(p_region_name);
        IF v_count > 0 THEN
            RAISE region_name_exists;
        END IF;

        INSERT INTO regions(region_id, region_name)
        VALUES (p_region_id, p_region_name);
        DBMS_OUTPUT.PUT_LINE('Region added: ' || p_region_name);

    EXCEPTION
        WHEN region_name_exists THEN
            log_error('add_region', 'Region name "' || p_region_name || '" already exists.');
            DBMS_OUTPUT.PUT_LINE('Error: Region with this name already exists.');
        WHEN OTHERS THEN
            log_error('add_region', SQLERRM);
            DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
    END add_region;

    FUNCTION get_region_name(p_region_id IN regions.region_id%TYPE)
    RETURN VARCHAR2 IS
        v_name regions.region_name%TYPE;
    BEGIN
        SELECT region_name INTO v_name
        FROM regions
        WHERE region_id = p_region_id;
        RETURN v_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'No region found for ID: ' || p_region_id;
        WHEN OTHERS THEN
            log_error('get_region_name', SQLERRM);
            RETURN 'Error: ' || SQLERRM;
    END get_region_name;

    PROCEDURE get_all_regions IS
    BEGIN
        FOR r IN (SELECT * FROM regions ORDER BY region_id) LOOP
            DBMS_OUTPUT.PUT_LINE('ID: ' || r.region_id || ', Name: ' || r.region_name);
        END LOOP;
    END get_all_regions;

    PROCEDURE get_regions_by_name(p_partial_name IN VARCHAR2) IS
    BEGIN
        FOR r IN (
            SELECT * FROM regions
            WHERE LOWER(region_name) LIKE LOWER('%' || p_partial_name || '%')
            ORDER BY region_name
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('ID: ' || r.region_id || ', Name: ' || r.region_name);
        END LOOP;
    END get_regions_by_name;

    PROCEDURE update_region_name(p_region_id IN regions.region_id%TYPE, p_new_name IN regions.region_name%TYPE) AS
    BEGIN
        UPDATE regions
        SET region_name = p_new_name
        WHERE region_id = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No region found with ID: ' || p_region_id);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Region updated successfully.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            log_error('update_region_name', SQLERRM);
            DBMS_OUTPUT.PUT_LINE('Error updating region: ' || SQLERRM);
    END update_region_name;

    PROCEDURE delete_region(p_region_id IN regions.region_id%TYPE) AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM countries WHERE region_id = p_region_id;
        IF v_count > 0 THEN
            RAISE region_has_countries;
        END IF;

        DELETE FROM regions WHERE region_id = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No region found with ID: ' || p_region_id);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Region deleted successfully.');
        END IF;

    EXCEPTION
        WHEN region_has_countries THEN
            log_error('delete_region', 'Region ID ' || p_region_id || ' has assigned countries.');
            DBMS_OUTPUT.PUT_LINE('Cannot delete region: it has assigned countries.');
        WHEN OTHERS THEN
            log_error('delete_region', SQLERRM);
            DBMS_OUTPUT.PUT_LINE('Error deleting region: ' || SQLERRM);
    END delete_region;

END region_pkg;
/


SET SERVEROUTPUT ON;
DECLARE
    v_title VARCHAR2(255);
BEGIN
    v_title := employee_pkg.getJobById('IT_PROG');
    DBMS_OUTPUT.PUT_LINE('Job title: ' || v_title);
END;
/

-- 3
CREATE TABLE region_errors_audit (
    id            NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    error_time    TIMESTAMP DEFAULT SYSTIMESTAMP,
    procedure_name VARCHAR2(100),
    error_message  VARCHAR2(4000)
);


BEGIN
    region_pkg.add_region(6, 'Europe');
END;
/

BEGIN
    region_pkg.delete_region(1);
END;
/

select * from region_errors_audit;


-- 4
CREATE OR REPLACE PACKAGE dept_stats_pkg AS
    FUNCTION get_avg_salary(
        p_dept_id IN employees.department_id%TYPE
    ) RETURN NUMBER;

    PROCEDURE get_min_max_salary_by_job(
        p_job_id IN employees.job_id%TYPE,
        p_min OUT NUMBER,
        p_max OUT NUMBER
    );

    PROCEDURE generate_salary_report(
        p_dept_id IN employees.department_id%TYPE
    );
END dept_stats_pkg;
/

CREATE OR REPLACE PACKAGE BODY dept_stats_pkg AS

    FUNCTION get_avg_salary(p_dept_id IN employees.department_id%TYPE)
    RETURN NUMBER IS
        v_avg_salary NUMBER;
    BEGIN
        SELECT AVG(salary)
        INTO v_avg_salary
        FROM employees
        WHERE department_id = p_dept_id;

        RETURN v_avg_salary;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in get_avg_salary: ' || SQLERRM);
            RETURN NULL;
    END get_avg_salary;

    PROCEDURE get_min_max_salary_by_job(
        p_job_id IN employees.job_id%TYPE,
        p_min OUT NUMBER,
        p_max OUT NUMBER
    ) IS
    BEGIN
        SELECT MIN(salary), MAX(salary)
        INTO p_min, p_max
        FROM employees
        WHERE job_id = p_job_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_min := NULL;
            p_max := NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in get_min_max_salary_by_job: ' || SQLERRM);
            p_min := NULL;
            p_max := NULL;
    END get_min_max_salary_by_job;

    PROCEDURE generate_salary_report(p_dept_id IN employees.department_id%TYPE) IS
        v_avg_salary NUMBER;
        v_dept_name  departments.department_name%TYPE;
        v_employee   employees%ROWTYPE;
    BEGIN
        SELECT department_name INTO v_dept_name
        FROM departments
        WHERE department_id = p_dept_id;

        v_avg_salary := get_avg_salary(p_dept_id);

        DBMS_OUTPUT.PUT_LINE('==== Salary Report for Department: ' || v_dept_name || ' ====');
        DBMS_OUTPUT.PUT_LINE('Average Salary: ' || NVL(TO_CHAR(v_avg_salary, '99999.99'), 'N/A'));
        DBMS_OUTPUT.PUT_LINE('Employees:');

        FOR emp IN (
            SELECT first_name || ' ' || last_name AS full_name, salary, job_id
            FROM employees
            WHERE department_id = p_dept_id
            ORDER BY salary DESC
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('- ' || emp.full_name || ' | Job: ' || emp.job_id || ' | Salary: ' || emp.salary);
        END LOOP;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No data found for department ID: ' || p_dept_id);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in generate_salary_report: ' || SQLERRM);
    END generate_salary_report;

END dept_stats_pkg;
/

DECLARE
    avg_sal NUMBER;
BEGIN
    avg_sal := dept_stats_pkg.get_avg_salary(60);
    DBMS_OUTPUT.PUT_LINE('Średnia pensja: ' || avg_sal);
END;
/

DECLARE
    min_sal NUMBER;
    max_sal NUMBER;
BEGIN
    dept_stats_pkg.get_min_max_salary_by_job('IT_PROG', min_sal, max_sal);
    DBMS_OUTPUT.PUT_LINE('Min: ' || min_sal || ', Max: ' || max_sal);
END;
/

BEGIN
    dept_stats_pkg.generate_salary_report(60);
END;
/


-- 5
CREATE OR REPLACE PACKAGE data_cleanup_pkg AS
    PROCEDURE fix_phone_numbers;

    PROCEDURE update_salary_by_job(
        p_job_id IN employees.job_id%TYPE, p_percent IN NUMBER
    );
END data_cleanup_pkg;
/

CREATE OR REPLACE PACKAGE BODY data_cleanup_pkg AS

    PROCEDURE fix_phone_numbers IS
        CURSOR phone_cursor IS
            SELECT employee_id, phone_number
            FROM employees
            WHERE REGEXP_LIKE(phone_number, '[^0-9]');

        v_new_phone employees.phone_number%TYPE;
    BEGIN
        FOR rec IN phone_cursor LOOP
            v_new_phone := REGEXP_REPLACE(rec.phone_number, '[^0-9]', '');

            IF LENGTH(v_new_phone) = 9 THEN
                v_new_phone := SUBSTR(v_new_phone, 1, 3) || '-' ||
                               SUBSTR(v_new_phone, 4, 3) || '-' ||
                               SUBSTR(v_new_phone, 7, 3);
            END IF;

            UPDATE employees
            SET phone_number = v_new_phone
            WHERE employee_id = rec.employee_id;
        END LOOP;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Phone numbers corrected.');
    END fix_phone_numbers;

    PROCEDURE update_salary_by_job(p_job_id IN employees.job_id%TYPE, p_percent IN NUMBER) IS
        v_count NUMBER;
    BEGIN
        UPDATE employees
        SET salary = salary * (1 + p_percent / 100)
        WHERE job_id = p_job_id;

        v_count := SQL%ROWCOUNT;
        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Updated ' || v_count || ' salaries for job ID: ' || p_job_id);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error during salary update: ' || SQLERRM);
            ROLLBACK;
    END update_salary_by_job;

END data_cleanup_pkg;
/


BEGIN
    data_cleanup_pkg.fix_phone_numbers;
END;
/


BEGIN
    data_cleanup_pkg.update_salary_by_job('IT_PROG', 10);
END;
/



