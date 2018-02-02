-- sequence used to generate pur# whenever a new tuple is inserted
CREATE SEQUENCE purchase_seq
MINVALUE 100015
START WITH 100015
INCREMENT BY 1
CACHE 20;
