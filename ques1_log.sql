-- sequence used to generate log# whenever a new tuple is inserted
CREATE SEQUENCE log_seq
MINVALUE 10001
START WITH 10001
INCREMENT BY 1
CACHE 20;

