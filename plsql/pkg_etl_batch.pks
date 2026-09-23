create or replace package pkg_etl_batch as

    function start_batch(
        p_batch_name in varchar2
    ) return number;

    function start_job(
        p_batch_id in number,
        p_job_name in varchar2
    ) return number;

    procedure finish_job(
        p_job_run_id    in number,
        p_status        in varchar2,
        p_rows_read     in number default 0,
        p_rows_inserted in number default 0,
        p_rows_updated  in number default 0,
        p_rows_rejected in number default 0
    );

    procedure finish_batch(
        p_batch_id in number,
        p_status   in varchar2
    );

    procedure log_error(
        p_batch_id   in number,
        p_job_run_id in number,
        p_module     in varchar2,
        p_error_code in number,
        p_error_msg  in varchar2,
        p_backtrace  in varchar2 default null
    );

    procedure reject_row(
        p_batch_id       in number,
        p_job_run_id     in number,
        p_source_key     in varchar2,
        p_reject_reason  in varchar2,
        p_source_payload in clob default null
    );

end pkg_etl_batch;
/
