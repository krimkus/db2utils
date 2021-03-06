-- The following CREATE SCHEMA will fail if QUUX already exists. We rely on
-- this to avoid clobbering any existing user schema of the same name. We don't
-- set the current schema as there's no way of restoring it after we're
-- finished
CREATE SCHEMA QUUX!

CREATE TABLE QUUX.FOO (ID INTEGER NOT NULL PRIMARY KEY, VALUE INTEGER NOT NULL)!

CREATE TABLE QUUX.BAR (ID INTEGER NOT NULL PRIMARY KEY, FOO_ID INTEGER REFERENCES QUUX.FOO(ID))!

CREATE ALIAS QUUX.BAZ FOR QUUX.BAR!

CREATE VIEW QUUX.QUUX AS
    SELECT QUUX.FOO.ID AS FOO_ID, QUUX.BAR.ID AS BAR_ID
    FROM QUUX.FOO
        JOIN QUUX.BAR
        ON QUUX.FOO.ID = QUUX.BAR.FOO_ID!

CREATE TRIGGER QUUX.FOO_UPDATE
    AFTER UPDATE ON QUUX.FOO
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
BEGIN
    IF NEW.VALUE = NEW.ID THEN
        SIGNAL SQLSTATE '80000';
    END IF;
END!

CREATE FUNCTION QUUX.BAZ_QUERY(A_ID INTEGER)
    RETURNS TABLE (BAZ_ID INTEGER, FOO_ID INTEGER)
    READS SQL DATA
    NO EXTERNAL ACTION
RETURN
    SELECT * FROM QUUX.BAZ WHERE ID = A_ID!

CREATE PROCEDURE QUUX.NEW_FOO (ID INTEGER, VALUE INTEGER)
    MODIFIES SQL DATA
    NO EXTERNAL ACTION
BEGIN
    INSERT INTO QUUX.FOO (ID, VALUE) VALUES (ID, VALUE);
END!

CALL DROP_SCHEMA('QUUX')!

VALUES ASSERT_EQUALS(0, (SELECT COUNT(*) FROM SYSCAT.SCHEMATA WHERE SCHEMANAME = 'QUUX'))!
