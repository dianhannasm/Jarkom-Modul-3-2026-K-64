INSERT INTO db_shibuya_k64.request_logs
    (client_ip, request_path, status_code)
VALUES
    ('192.243.4.18', '/soal-13-test', 200);

SELECT * FROM db_shibuya_k64.request_logs;

--TEST INI TERAKHIR DI INUMAKI

--SHOW SLAVE STATUS\G
--SELECT * FROM db_shibuya_k64.request_logs;

