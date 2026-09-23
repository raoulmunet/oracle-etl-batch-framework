select *
from etl_batch
order by batch_id desc;

select r.job_run_id,
       r.batch_id,
       j.job_name,
       r.status,
       r.rows_read,
       r.rows_inserted,
       r.rows_updated,
       r.rows_rejected
from etl_job_run r
join etl_job j on j.job_id = r.job_id
order by r.job_run_id desc;

select *
from etl_error_log
order by error_id desc;

select *
from etl_rejected_row
order by reject_id desc;
