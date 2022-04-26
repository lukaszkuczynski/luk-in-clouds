drop table if exists mydb.measurements;
CREATE table mydb.measurements (
    id bigint,
    value float,
    device varchar(20),
    ts timestamp
);