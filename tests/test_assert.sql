CALL ASSERT_SIGNALS('70001', 'CALL TEST_SIGNAL(''70001'')');

CALL ASSERT_SIGNALS(ASSERT_SQLSTATE, 'CALL ASSERT_SIGNALS(''70001'', ''CALL TEST_SIGNAL(''''70000'''')'')');

