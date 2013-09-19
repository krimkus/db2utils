-- We can't call SIGNAL from EXECUTE IMMEDIATE so instead we wrap it in a
-- procedure which we can call from EXECUTE IMMEDIATE
CREATE PROCEDURE TEST_SIGNAL(STATE CHAR(5))
    SPECIFIC TEST_SIGNAL
    NO EXTERNAL ACTION
BEGIN ATOMIC
    SIGNAL SQLSTATE STATE;
END!

CALL ASSERT_SIGNALS('70001', 'CALL TEST_SIGNAL(''70001'')')!

-- For some bizarre reason, ASSERT_SIGNALS doesn't like being nested; DB2
-- 9.7FP8 bizarrely complains about a non-existent SAVEPOINT (probably a bug)
-- so again we use a stored proc to test things here
CREATE PROCEDURE TEST_ASSERT()
    SPECIFIC TEST_ASSERT
    NO EXTERNAL ACTION
BEGIN ATOMIC
    DECLARE EXIT HANDLER FOR SQLSTATE '90001' BEGIN END;
    CALL ASSERT_SIGNALS('70001', 'CALL TEST_SIGNAL(''70000'')');
END!

CALL TEST_ASSERT()!

-- We can't execute SELECT or VALUES from EXECUTE IMMEDIATE so again we wrap it
-- in a procedure which we can call from EXECUTE IMMEDIATE. The procedure
-- simply takes some SQL, bungs it on the end of a VALUES statement and
-- executes it, expecting to get a single integer back in return, which is the
-- calling convention of all the ASSERT_* functions
CREATE PROCEDURE TEST_VALUES(SQL CLOB(64K))
    SPECIFIC TEST_VALUES
    NO EXTERNAL ACTION
    DYNAMIC RESULT SETS 1
BEGIN ATOMIC
    DECLARE R INTEGER;
    DECLARE S STATEMENT;
    DECLARE C CURSOR FOR S;
    PREPARE S FROM 'VALUES ' || SQL;
    OPEN C;
    FETCH C INTO R;
END!

VALUES ASSERT_EQUALS(0, 0)!
VALUES ASSERT_EQUALS(0.0, 0.0)!
VALUES ASSERT_EQUALS(CURRENT DATE, CURRENT DATE)!
VALUES ASSERT_EQUALS(CURRENT TIMESTAMP, CURRENT TIMESTAMP)!
VALUES ASSERT_EQUALS(CURRENT TIME, CURRENT TIME)!
VALUES ASSERT_EQUALS('foo', 'foo')!
CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL TEST_VALUES(''ASSERT_EQUALS(0, 1)'')')!
CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL TEST_VALUES(''ASSERT_EQUALS(0.0, 1.0)'')')!
CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL TEST_VALUES(''ASSERT_EQUALS(CURRENT DATE, CURRENT DATE - 1 DAY)'')')!
CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL TEST_VALUES(''ASSERT_EQUALS(CURRENT TIMESTAMP, CURRENT TIMESTAMP + 1 MICROSECOND)'')')!
CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL TEST_VALUES(''ASSERT_EQUALS(CURRENT TIME, CURRENT TIME - 1 HOUR)'')')!
CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL TEST_VALUES(''ASSERT_EQUALS(''''foo'''', ''''bar'''')'')')!

VALUES ASSERT_NOT_EQUALS(0, 1)!
VALUES ASSERT_NOT_EQUALS(0.0, 1.0)!
VALUES ASSERT_NOT_EQUALS(CURRENT DATE, CURRENT DATE - 1 DAY)!
VALUES ASSERT_NOT_EQUALS(CURRENT TIMESTAMP, CURRENT TIMESTAMP + 1 MICROSECOND)!
VALUES ASSERT_NOT_EQUALS(CURRENT TIME, CURRENT TIME - 1 HOUR)!
VALUES ASSERT_NOT_EQUALS('foo', 'bar')!
CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL TEST_VALUES(''ASSERT_NOT_EQUALS(0, 0)'')')!
CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL TEST_VALUES(''ASSERT_NOT_EQUALS(0.0, 0.0)'')')!
CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL TEST_VALUES(''ASSERT_NOT_EQUALS(CURRENT DATE, CURRENT DATE)'')')!
CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL TEST_VALUES(''ASSERT_NOT_EQUALS(CURRENT TIMESTAMP, CURRENT TIMESTAMP)'')')!
CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL TEST_VALUES(''ASSERT_NOT_EQUALS(CURRENT TIME, CURRENT TIME)'')')!
CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL TEST_VALUES(''ASSERT_NOT_EQUALS(''''foo'''', ''''foo'''')'')')!

CREATE TABLE FOO (I INTEGER NOT NULL)!

VALUES ASSERT_TABLE_EXISTS('FOO')!
VALUES ASSERT_TABLE_EXISTS(CURRENT SCHEMA, 'FOO')!
CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL TEST_VALUES(''ASSERT_TABLE_EXISTS(''''BAR'''')'')')!

VALUES ASSERT_COLUMN_EXISTS('FOO', 'I')!
VALUES ASSERT_COLUMN_EXISTS(CURRENT SCHEMA, 'FOO', 'I')!
CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL TEST_VALUES(''ASSERT_COLUMN_EXISTS(''''FOO'''', ''''J'''')'')')!

DROP TABLE FOO!
DROP SPECIFIC PROCEDURE TEST_VALUES!
DROP SPECIFIC PROCEDURE TEST_ASSERT!
DROP SPECIFIC PROCEDURE TEST_SIGNAL!
