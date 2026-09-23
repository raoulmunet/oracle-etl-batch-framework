create or replace package body pkg_etl_batch as

    procedure assert_status(p_status varchar2) is
    begin
        if p_status not in ('RUNNING','SUCCESS','FAILED','PARTIAL') then
            raise_application_error(-20001, 'Invalid ETL status: ' || p_status);
        end if;
    end;

    function start_batch(
        p_batch_name in varchar2
    ) return number
    is
        l_batch_id number;
    begin
        insert into etl_batch(batch_name, status)
        values (p_batch_name, 'RUNNING')
        returning batch_id into l_batch_id;

        commit;
        return l_batch_id;
    end;

    function start_job(
        p_batch_id in number,
        p_job_name in varchar2
    ) return number
    is
        l_job_id     etl_job.job_id%type;
        l_job_run_id etl_job_run.job_run_id%type;
    begin
        select job_id
          into l_job_id
          from etl_job
         where job_name = p_job_name
           and enabled_flag = 'Y';

        insert into etl_job_run(batch_id, job_id, status)
        values (p_batch_id, l_job_id, 'RUNNING')
        returning job_run_id into l_job_run_id;

        commit;
        return l_job_run_id;
    end;

    procedure finish_job(
        p_job_run_id    in number,
        p_status        in varchar2,
        p_rows_read     in number default 0,
        p_rows_inserted in number default 0,
        p_rows_updated  in number default 0,
        p_rows_rejected in number default 0
    )
    is
        l_batch_id number;
    begin
        assert_status(p_status);

        update etl_job_run
           set status        = p_status,
               finished_at   = systimestamp,
               rows_read     = p_rows_read,
               rows_inserted = p_rows_inserted,
               rows_updated  = p_rows_updated,
               rows_rejected = p_rows_rejected
         where job_run_id = p_job_run_id
        returning batch_id into l_batch_id;

        update etl_batch
           set rows_read     = rows_read + p_rows_read,
               rows_inserted = rows_inserted + p_rows_inserted,
               rows_updated  = rows_updated + p_rows_updated,
               rows_rejected = rows_rejected + p_rows_rejected
         where batch_id = l_batch_id;

        commit;
    end;

    procedure finish_batch(
        p_batch_id in number,
        p_status   in varchar2
    )
    is
    begin
        assert_status(p_status);

        update etl_batch
           set status      = p_status,
               finished_at = systimestamp
         where batch_id = p_batch_id;

        commit;
    end;

    procedure log_error(
        p_batch_id   in number,
        p_job_run_id in number,
        p_module     in varchar2,
        p_error_code in number,
        p_error_msg  in varchar2,
        p_backtrace  in varchar2 default null
    )
    is
        pragma autonomous_transaction;
    begin
        insert into etl_error_log(
            batch_id, job_run_id, module,
            error_code, error_message, backtrace
        )
        values (
            p_batch_id, p_job_run_id, p_module,
            p_error_code, substr(p_error_msg,1,4000), substr(p_backtrace,1,4000)
        );
        commit;
    end;

    procedure reject_row(
        p_batch_id       in number,
        p_job_run_id     in number,
        p_source_key     in varchar2,
        p_reject_reason  in varchar2,
        p_source_payload in clob default null
    )
    is
        pragma autonomous_transaction;
    begin
        insert into etl_rejected_row(
            batch_id, job_run_id, source_key,
            reject_reason, source_payload
        )
        values (
            p_batch_id, p_job_run_id, p_source_key,
            p_reject_reason, p_source_payload
        );
        commit;
    end;

end pkg_etl_batch;
/
